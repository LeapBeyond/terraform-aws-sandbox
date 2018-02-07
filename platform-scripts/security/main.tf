# ------------------------ IAM role for bastion instance -------------------------------------------------

resource "aws_iam_role" "bastion_role" {
  name_prefix           = "bastion"
  path                  = "/"
  description           = "roles policy the bastion uses"
  force_detach_policies = true
  assume_role_policy    = "${file("${path.module}/templates/ec2-service-role-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "bastion-role-codecommit" {
  role       = "${aws_iam_role.bastion_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitReadOnly"
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name_prefix = "bastion"
  role        = "${aws_iam_role.bastion_role.name}"
}

data "aws_vpc" "ssmtest_vpc" {
  id = "${var.ssmtest_vpc_id}"
}

# --------------------------------------------------------------------------------------------------------------
# roles to assign to the EC2 instance(s)
# --------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "test_ssm_role" {
  name_prefix           = "testssm"
  path                  = "/"
  description           = "roles polices the test can use"
  force_detach_policies = true
  assume_role_policy    = "${file("${path.module}/templates/ssm-service-role-policy.json")}"
}

resource "aws_iam_instance_profile" "test_ssm_profile" {
  name_prefix = "testssm"
  role        = "${aws_iam_role.test_ssm_role.name}"
}

# --------------------------------------------------------------------------------------------------------------
# security groups for bastion vpc
# --------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "bastion_ssh_access" {
  name        = "bastion_ssh_access"
  description = "allows ssh access"
  vpc_id      = "${var.bastion_vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_inbound}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "proxy_ssh" {
  name        = "proxy_ssh"
  description = "allows ssh access to proxy"
  vpc_id      = "${var.bastion_vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.bastion_subnet_cidr}"]
  }

  # ToDo this could be finessed to just 443 for the target aws environments
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "proxy" {
  name        = "proxy"
  description = "allows access to squid proxy"
  vpc_id      = "${var.bastion_vpc_id}"

  ingress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_vpc.ssmtest_vpc.cidr_block}"]
  }
}

# --------------------------------------------------------------------------------------------------------------
# security groups for ssmtest vpc
# --------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "ssmtest_ssh_access" {
  name        = "ssmtest_ssh_access"
  description = "allows ssh access"
  vpc_id      = "${var.ssmtest_vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_inbound}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssmtest_proxy_access" {
  name        = "ssmtest_proxy_access"
  description = "allows access to yum proxy"
  vpc_id      = "${var.ssmtest_vpc_id}"

  ingress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${var.proxy_subnet_cidr}"]
  }

  egress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = ["${var.proxy_subnet_cidr}"]
  }
}
