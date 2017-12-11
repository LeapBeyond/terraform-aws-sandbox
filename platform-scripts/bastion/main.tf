# --------------------------------------------------------------------------------------------------------------
# various data lookups
# --------------------------------------------------------------------------------------------------------------
data "aws_ami" "target_ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["${var.bastion_ami_name}"]
  }
}

# TODO: move this out
data "aws_vpc" "defaultvpc" {
  cidr_block = "172.31.0.0/16"
}

// TODO: turn this into a template
data "aws_iam_policy_document" "ec2-service-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# TODO: parameterise that nacl
variable "default_network_acl_id" {
  default = "acl-6c6a2f05"
}

# --------------------------------------------------------------------------------------------------------------
# lock down the default security group and NACL
# --------------------------------------------------------------------------------------------------------------

resource "aws_default_security_group" "default" {
  vpc_id = "${data.aws_vpc.defaultvpc.id}"

  tags {
    Name    = "default_sg"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

resource "aws_default_network_acl" "support" {
  default_network_acl_id = "${var.default_network_acl_id}"

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

resource "aws_internet_gateway" "bastion-gateway" {
  vpc_id = "${aws_vpc.bastion_vpc.id}"

  tags {
    Name    = "Bastion-gateway"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

# --------------------------------------------------------------------------------------------------------------
# define the bastion subnet
# --------------------------------------------------------------------------------------------------------------

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

# ------------------------ route table associated with the subnet ----------------------------
resource "aws_route_table" "bastion-rt" {
  vpc_id = "${aws_vpc.bastion_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.bastion-gateway.id}"
  }

  tags {
    Name    = "Bastion-rt"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

resource "aws_route_table_association" "bastion-rta" {
  subnet_id      = "${aws_subnet.bastion_subnet.id}"
  route_table_id = "${aws_route_table.bastion-rt.id}"
}

# ------------------------ security groups --------------------------------------------------------

resource "aws_security_group" "bastion_ssh" {
  name        = "bastion_ssh"
  description = "allows ssh access to bastion"
  vpc_id      = "${aws_vpc.bastion_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.bastion_ssh_inbound}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_default_security_group" "bastion_default" {
  vpc_id = "${aws_vpc.bastion_vpc.id}"

  tags {
    Name    = "bastion_default"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

# ------------------------ IAM role for bastion instance -------------------------------------------------

resource "aws_iam_role" "bastion_role" {
  name_prefix           = "bastion"
  path                  = "/"
  description           = "roles polices the bastion can use"
  force_detach_policies = true
  assume_role_policy    = "${data.aws_iam_policy_document.ec2-service-role-policy.json}"
}

resource "aws_iam_role_policy_attachment" "bastion-role-codecommit" {
  role       = "${aws_iam_role.bastion_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitReadOnly"
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name_prefix = "bastion"
  role        = "${aws_iam_role.bastion_role.name}"
}

# ------------------------ Bastion Instance --------------------------------------------------------

resource "aws_instance" "bastion" {
  ami                    = "${data.aws_ami.target_ami.id}"
  instance_type          = "${var.bastion_instance_type}"
  key_name               = "${var.bastion_key}"
  subnet_id              = "${aws_subnet.bastion_subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.bastion_ssh.id}"]

  iam_instance_profile = "${aws_iam_instance_profile.bastion_profile.name}"

  root_block_device = {
    volume_type = "gp2"
    volume_size = "${var.root_vol_size}"
  }

  tags {
    Name    = "Bastion"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }

  volume_tags {
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }

  provisioner "file" {
    source      = "${path.root}/../data/${var.test_key}.pem"
    destination = "/home/${var.bastion_user}/.ssh/${var.test_key}.pem"

    connection {
      type        = "ssh"
      user        = "${var.bastion_user}"
      private_key = "${file("${path.root}/../data/${var.bastion_key}.pem")}"
      timeout     = "5m"
    }
  }

  user_data = <<EOF
#!/bin/bash
yum update -y
yum erase -y ntp*
yum -y install chrony
echo "server 169.254.169.123 prefer iburst" >> /etc/chrony.conf
service chronyd start
EOF
}

resource "null_resource" "update" {
  connection {
    type        = "ssh"
    agent       = false
    user        = "${var.bastion_user}"
    host        = "${aws_instance.bastion.public_dns}"
    private_key = "${file("${path.root}/../data/${var.bastion_key}.pem")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install git -y",
      "mkdir ~/.aws ~/bin && cd ~/bin && wget https://releases.hashicorp.com/terraform/0.10.7/terraform_0.10.7_linux_amd64.zip && unzip terraform*zip",
      "sudo git config --system credential.https://git-codecommit.${var.aws_region}.amazonaws.com.helper '!aws --profile default codecommit credential-helper $@'",
      "sudo git config --system credential.https://git-codecommit.${var.aws_region}.amazonaws.com.UseHttpPath true",
      "aws configure set region ${var.aws_region}",
      "aws configure set output json",
      "cd ~ && git clone https://git-codecommit.${var.aws_region}.amazonaws.com/v1/repos/bastion-smoketest",
      "chmod 0400 /home/${var.bastion_user}/.ssh/${var.test_key}.pem",
    ]
  }
}

# -------------------------------   code commit repository -----------------------------
# TODO probably drop this or move elsewhere.
resource "aws_codecommit_repository" "bastion-smoketest" {
  repository_name = "bastion-smoketest"
  description     = "smoke test scripts for the bastion."
}
