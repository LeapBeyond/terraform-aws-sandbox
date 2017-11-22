data "aws_ami" "target_ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["${var.nexus_ami_name}"]
  }
}

resource "aws_spot_instance_request" "nexus" {
  ami                  = "${data.aws_ami.target_ami.id}"
  spot_price           = "0.021"
  key_name             = "${var.nexus_key}"
  subnet_id            = "${var.bastion_subnet_id}"
  instance_type        = "${var.nexus_instance_type}"
  wait_for_fulfillment = true

  vpc_security_group_ids = [
    "${var.bastion_ssh_sg_id}",
    "${aws_security_group.nexus_http.id}",
    "${aws_security_group.http_from_test.id}"
  ]

  root_block_device = {
    volume_type = "gp2"
    volume_size = "${var.root_vol_size}"
  }

  tags {
    Name    = "Nexus"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }

  volume_tags {
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }

  user_data = <<EOF
#!/bin/bash
yum update -y
yum install -y java-1.8.0-openjdk-1.8.0.151-1.b12.35.amzn1.x86_64
alternatives --remove java /usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin/java
useradd nexus
echo 'nexus - nofile 65536' >> /etc/security/limits.conf
cd ~nexus
wget -q https://download.sonatype.com/nexus/3/nexus-3.6.1-02-unix.tar.gz
tar xfz nexus-3.6.1-02-unix.tar.gz
chown -R nexus:nexus ./*
sudo -u nexus ~nexus/nexus-3.6.1-02/bin/nexus start
EOF
}

resource "aws_security_group" "nexus_http" {
  name        = "nexus_http"
  description = "allows http access to bastion"
  vpc_id      = "${var.bastion_vpc_id}"

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = "${var.bastion_inbound}"
  }

  // TODO: could be improved
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "http_from_test" {
  name        = "http_from_test"
  description = "allows http from anywhere in the test VPC"
  vpc_id      = "${var.bastion_vpc_id}"

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["${var.test_vpc_cidr}"]
  }
}

resource "null_resource" "update" {
  connection {
    type        = "ssh"
    agent       = false
    user        = "${var.nexus_user}"
    host        = "${aws_instance.nexus.public_dns}"
    private_key = "${file("${path.root}/../data/${var.nexus_key}.pem")}"
  }
}
