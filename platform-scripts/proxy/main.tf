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
    values = ["${var.proxy_ami_name}"]
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user_data.sh.tpl")}"

  vars {
    bastion_subnet = "${var.bastion_subnet_cidr}"
    secure_subnet  = "${var.test_subnet_cidr}"
  }
}

# --------------------------------------------------------------------------------------------------------------
# security groups
# --------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "proxy_ssh" {
  name        = "proxy_ssh"
  description = "allows ssh access to proxy"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_inbound}"]
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
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = ["${var.test_vpc_cidr}"]
  }
}

# --------------------------------------------------------------------------------------------------------------
# the EC2 instance
# --------------------------------------------------------------------------------------------------------------

resource "aws_instance" "proxy" {
  ami                    = "${data.aws_ami.target_ami.id}"
  instance_type          = "${var.proxy_instance_type}"
  key_name               = "${var.proxy_key}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.proxy.id}", "${aws_security_group.proxy_ssh.id}"]

  root_block_device = {
    volume_type = "gp2"
    volume_size = "${var.root_vol_size}"
  }

  tags {
    Name    = "proxy"
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
