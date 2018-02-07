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
# the EC2 instance
# --------------------------------------------------------------------------------------------------------------

resource "aws_instance" "proxy" {
  ami                    = "${data.aws_ami.target_ami.id}"
  instance_type          = "${var.proxy_instance_type}"
  key_name               = "${var.proxy_key}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${var.proxy_sg_id}", "${var.ssh_sg_id}"]

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
