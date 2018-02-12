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
    aws_region    = "${var.aws_region}"
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

  vpc_security_group_ids = ["${var.ssh_sg_id}", "${var.proxy_access_sg_id}"]
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
