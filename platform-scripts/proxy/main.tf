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

data "aws_vpc" "bastion_vpc" {
  id = "${var.bastion_vpc_id}"
}

data "template_file" "squid_conf" {
  template = "${file("${path.module}/templates/squid.conf.tpl")}"

  vars {
    bastion_subnet = "${var.bastion_subnet_cidr}"
    secure_subnet  = "${var.test_subnet_cidr}"
  }
}

# --------------------------------------------------------------------------------------------------------------
# define the proxy subnet
# --------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "proxy_subnet" {
  vpc_id                  = "${var.bastion_vpc_id}"
  cidr_block              = "${var.proxy_subnet_cidr}"
  map_public_ip_on_launch = true

  tags {
    Name    = "proxy-subnet"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

resource "aws_route_table_association" "proxy_rta" {
  subnet_id      = "${aws_subnet.proxy_subnet.id}"
  route_table_id = "${var.bastion_rt_id}"
}

# --------------------------------------------------------------------------------------------------------------
# the EC2 instance
# --------------------------------------------------------------------------------------------------------------
resource "aws_instance" "proxy" {
  ami                    = "${data.aws_ami.target_ami.id}"
  instance_type          = "${var.proxy_instance_type}"
  key_name               = "${var.proxy_key}"
  subnet_id              = "${aws_subnet.proxy_subnet.id}"
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

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "${var.proxy_user}"
      private_key = "${file("${path.root}/../data/${var.proxy_key}.pem")}"
      timeout     = "5m"
    }

    content     = "${data.template_file.squid_conf.rendered}"
    destination = "~${var.proxy_user}/squid.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp ~${var.proxy_user}/squid.conf /etc/squid/squid.conf",
      "sudo service squid restart",
    ]
  }

  user_data = <<EOF
#!/bin/bash
yum update -y
yum erase -y ntp*
yum -y install chrony squid
echo "server 169.254.169.123 prefer iburst" >> /etc/chrony.conf
service chronyd start
chkconfig squid on


EOF
}

# --------------------------------------------------------------------------------------------------------------
# security groups
# --------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "proxy_ssh" {
  name        = "proxy_ssh"
  description = "allows ssh access to proxy"
  vpc_id      = "${data.aws_vpc.bastion_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.ssh_inbound}"
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
  vpc_id      = "${data.aws_vpc.bastion_vpc.id}"

  ingress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = ["${var.test_vpc_cidr}"]
  }
}
