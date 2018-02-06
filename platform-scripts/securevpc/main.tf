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

data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user_data.sh.tpl")}"

  vars {
    proxy_address = "${var.proxy_address}"
  }
}

# --------------------------------------------------------------------------------------------------------------
# the EC2 instance(s) inside the subnet
# --------------------------------------------------------------------------------------------------------------
resource "aws_instance" "ssmtest" {
  associate_public_ip_address = false
  ami                         = "${data.aws_ami.target_ami.id}"
  instance_type               = "${var.ec2_instance_type}"
  key_name                    = "${var.test_key}"
  subnet_id                   = "${var.subnet_id}"

  vpc_security_group_ids = ["${aws_security_group.test_ssh.id}", "${aws_security_group.test_proxy.id}"]
  iam_instance_profile   = "${var.profile_name}"

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

  user_data = "${data.template_file.user_data.rendered}"
}

resource "aws_security_group" "test_ssh" {
  name        = "test_ssh"
  description = "allows ssh access to test"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_inbound}"]
  }

  egress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_inbound}"]
  }
}

resource "aws_security_group" "test_proxy" {
  name        = "test_proxy"
  description = "allows access to yum proxy"
  vpc_id      = "${var.vpc_id}"

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
