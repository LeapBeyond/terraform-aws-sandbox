# --------------------------------------------------------------------------------------------------------------
# various data lookups
# --------------------------------------------------------------------------------------------------------------
data "aws_ami" "target_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.ec2_ami_name}"]
  }
}

data "aws_iam_policy_document" "ssm-service-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }
  }
}

data "aws_vpc" "bastion_vpc" {
  id = "${var.bastion_vpc_id}"
}

data "aws_subnet" "bastion_subnet" {
  id = "${var.bastion_subnet_id}"
}

data "aws_subnet" "nexus_subnet" {
  id = "${var.nexus_subnet_id}"
}

# --------------------------------------------------------------------------------------------------------------
# VPC definition
# --------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "test_vpc" {
  cidr_block           = "${var.test_vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name    = "test-vpc"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

resource "aws_route_table" "test-rt" {
  vpc_id = "${aws_vpc.test_vpc.id}"

  tags {
    Name    = "test-rt"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

resource "aws_vpc_peering_connection" "bastion_to_test" {
  vpc_id      = "${data.aws_vpc.bastion_vpc.id}"
  peer_vpc_id = "${aws_vpc.test_vpc.id}"
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name    = "bastion_to_test"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

resource "aws_route" "test_to_bastion" {
  route_table_id            = "${aws_route_table.test-rt.id}"
  destination_cidr_block    = "${data.aws_vpc.bastion_vpc.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_to_test.id}"
}

resource "aws_route" "bastion_to_test" {
  route_table_id            = "${var.bastion_rt_id}"
  destination_cidr_block    = "${var.test_vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_to_test.id}"
}

resource "aws_default_network_acl" "test_nacl" {
  default_network_acl_id = "${aws_vpc.test_vpc.default_network_acl_id}"

  tags {
    Name    = "test_default"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

resource "aws_network_acl" "test_nacl_main" {
  vpc_id     = "${aws_vpc.test_vpc.id}"
  subnet_ids = ["${aws_subnet.test_subnet.id}"]

  tags {
    Name    = "test_main"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

resource "aws_network_acl_rule" "test_ephemeral_to_bastion" {
  network_acl_id = "${aws_network_acl.test_nacl_main.id}"
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${data.aws_subnet.bastion_subnet.cidr_block}"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "test_ssh_from_bastion" {
  network_acl_id = "${aws_network_acl.test_nacl_main.id}"
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${data.aws_subnet.bastion_subnet.cidr_block}"
  from_port      = 22
  to_port        = 22
}

/*
 * TODO: this is suboptimal and should be fixed - it's open to the port range so that the nexus box listening on 8081
 * can reply to requests from the "secure" vpc. rather than opening to the entire "bastion" subnet, we should be narrowing
 * it down to just the nexus box or a subnet the nexus box is in.
 */
resource "aws_network_acl_rule" "test_http_from_nexus" {
  network_acl_id = "${aws_network_acl.test_nacl_main.id}"
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${data.aws_subnet.nexus_subnet.cidr_block}"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "test_http_to_nexus" {
  network_acl_id = "${aws_network_acl.test_nacl_main.id}"
  rule_number    = 110
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${data.aws_subnet.nexus_subnet.cidr_block}"
  from_port      = 8081
  to_port        = 8081
}

# --------------------------------------------------------------------------------------------------------------
# subnets within the VPC
# --------------------------------------------------------------------------------------------------------------

resource "aws_subnet" "test_subnet" {
  vpc_id                  = "${aws_vpc.test_vpc.id}"
  cidr_block              = "${var.test_subnet_cidr}"
  map_public_ip_on_launch = true

  tags {
    Name    = "test-subnet"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

resource "aws_route_table_association" "test-rta" {
  subnet_id      = "${aws_subnet.test_subnet.id}"
  route_table_id = "${aws_route_table.test-rt.id}"
}

resource "aws_default_security_group" "default" {
  vpc_id = "${aws_vpc.test_vpc.id}"

  tags {
    Name    = "test_default"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

# --------------------------------------------------------------------------------------------------------------
# roles to assign to the EC2 instance(s)
# --------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "test_ssm_role" {
  name_prefix           = "testssm"
  path                  = "/"
  description           = "roles polices the test can use"
  force_detach_policies = true
  assume_role_policy    = "${data.aws_iam_policy_document.ssm-service-role-policy.json}"
}

resource "aws_iam_instance_profile" "test_ssm_profile" {
  name_prefix = "testssm"
  role        = "${aws_iam_role.test_ssm_role.name}"
}

# --------------------------------------------------------------------------------------------------------------
# the EC2 instance(s) inside the subnet
# --------------------------------------------------------------------------------------------------------------
resource "aws_instance" "ssmtest" {
  associate_public_ip_address = false
  ami                         = "${data.aws_ami.target_ami.id}"
  instance_type               = "${var.ec2_instance_type}"
  key_name                    = "${var.test_key}"
  subnet_id                   = "${aws_subnet.test_subnet.id}"
  vpc_security_group_ids      = ["${aws_security_group.test_ssh.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.test_ssm_profile.name}"

  # user_data = "${file("${path.module}/install_ssh_agent.sh")}"

  root_block_device = {
    volume_type = "gp2"
    volume_size = "${var.root_vol_size}"
  }
  tags {
    Name    = "ssmtest"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
  volume_tags {
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

resource "aws_security_group" "test_ssh" {
  name        = "test_ssh"
  description = "allows ssh access to test"
  vpc_id      = "${aws_vpc.test_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.ssh_inbound}"
  }

  egress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = "${var.ssh_inbound}"
  }
}

// TODO: 8081 to nexus subnet.
