# --------------------------------------------------------------------------------------------------------------
# lock down the default security group and NACL
# --------------------------------------------------------------------------------------------------------------

resource "aws_default_vpc" "default" {
  tags {
    Name = "Default VPC"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = "${aws_default_vpc.default.id}"

  tags {
    Name    = "default_sg"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = "${aws_default_vpc.default.default_network_acl_id}"

  tags {
    Name    = "default_nacl"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

# --------------------------------------------------------------------------------------------------------------
# define the bastion VPC
# --------------------------------------------------------------------------------------------------------------

resource "aws_vpc" "bastion_vpc" {
  cidr_block           = "${var.bastion_vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name    = "Bastion-vpc"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

# seal off the default security group
resource "aws_default_security_group" "bastion_default" {
  vpc_id = "${aws_vpc.bastion_vpc.id}"

  tags {
    Name    = "bastion_default"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

resource "aws_internet_gateway" "bastion_gateway" {
  vpc_id = "${aws_vpc.bastion_vpc.id}"

  tags {
    Name    = "bastion_gateway"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

# ---------------------------------------
# define the bastion subnet
# ---------------------------------------

resource "aws_subnet" "bastion_subnet" {
  vpc_id                  = "${aws_vpc.bastion_vpc.id}"
  cidr_block              = "${var.bastion_subnet_cidr}"
  map_public_ip_on_launch = true

  tags {
    Name    = "Bastion-subnet"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

# ---------------------------------------
# define the proxy subnet
# ---------------------------------------
resource "aws_subnet" "proxy_subnet" {
  vpc_id                  = "${aws_vpc.bastion_vpc.id}"
  cidr_block              = "${var.proxy_subnet_cidr}"
  map_public_ip_on_launch = true

  tags {
    Name    = "proxy-subnet"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

# ---------------------------------------
# route tables associated with the subnets
# ---------------------------------------
resource "aws_route_table" "bastion_rt" {
  vpc_id = "${aws_vpc.bastion_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.bastion_gateway.id}"
  }

  tags {
    Name    = "Bastion-rt"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

resource "aws_route_table_association" "bastion_rta" {
  subnet_id      = "${aws_subnet.bastion_subnet.id}"
  route_table_id = "${aws_route_table.bastion_rt.id}"
}

resource "aws_route_table_association" "proxy_rta" {
  subnet_id      = "${aws_subnet.proxy_subnet.id}"
  route_table_id = "${aws_route_table.bastion_rt.id}"
}

# --------------------------------------------------------------------------------------------------------------
# define the test VPC
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

# lock down the default security group
resource "aws_default_security_group" "test_default" {
  vpc_id = "${aws_vpc.test_vpc.id}"

  tags {
    Name    = "test_default"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

# ---------------------------------------
# peering connections
# ---------------------------------------
resource "aws_vpc_peering_connection" "bastion_to_test" {
  vpc_id      = "${aws_vpc.bastion_vpc.id}"
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

# ---------------------------------------
# subnets in the test VPC
# ---------------------------------------

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

# ---------------------------------------
# route tables associated with the subnets
# ---------------------------------------
resource "aws_route_table" "test_rt" {
  vpc_id = "${aws_vpc.test_vpc.id}"

  tags {
    Name    = "test_rt"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

resource "aws_route_table_association" "test_rta" {
  subnet_id      = "${aws_subnet.test_subnet.id}"
  route_table_id = "${aws_route_table.test_rt.id}"
}

resource "aws_route" "test_to_bastion" {
  route_table_id            = "${aws_route_table.test_rt.id}"
  destination_cidr_block    = "${var.bastion_vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_to_test.id}"
}

resource "aws_route" "bastion_to_test" {
  route_table_id            = "${aws_route_table.bastion_rt.id}"
  destination_cidr_block    = "${var.test_vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_to_test.id}"
}

# ---------------------------------------
# NACL in the VPC
# ---------------------------------------
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
  cidr_block     = "${var.bastion_vpc_cidr}"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "test_ssh_from_bastion" {
  network_acl_id = "${aws_network_acl.test_nacl_main.id}"
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${var.bastion_vpc_cidr}"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "test_ephemeral_from_bastion" {
  network_acl_id = "${aws_network_acl.test_nacl_main.id}"
  rule_number    = 150
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${var.bastion_vpc_cidr}"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "test_ephemeral_from_proxy" {
  network_acl_id = "${aws_network_acl.test_nacl_main.id}"
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${var.proxy_subnet_cidr}"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "test_to_proxy" {
  network_acl_id = "${aws_network_acl.test_nacl_main.id}"
  rule_number    = 200
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${var.proxy_subnet_cidr}"
  from_port      = 3128
  to_port        = 3128
}
