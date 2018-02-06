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

# -------------------------------   code commit repository -----------------------------
resource "aws_codecommit_repository" "bastion-smoketest" {
  repository_name = "bastion-smoketest"
  description     = "smoke test scripts for the bastion."
}

# ------------------------ security groups --------------------------------------------------------

resource "aws_security_group" "bastion_ssh" {
  name        = "bastion_ssh"
  description = "allows ssh access to bastion"
  vpc_id      = "${var.vpc_id}"

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

# ------------------------ Bastion Instance --------------------------------------------------------

resource "aws_instance" "bastion" {
  ami                    = "${data.aws_ami.target_ami.id}"
  instance_type          = "${var.bastion_instance_type}"
  key_name               = "${var.bastion_key}"
  subnet_id              = "${var.subnet_id}"
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

  provisioner "file" {
    source      = "${path.root}/../data/${var.proxy_key}.pem"
    destination = "/home/${var.bastion_user}/.ssh/${var.proxy_key}.pem"

    connection {
      type        = "ssh"
      user        = "${var.bastion_user}"
      private_key = "${file("${path.root}/../data/${var.bastion_key}.pem")}"
      timeout     = "5m"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 0400 /home/${var.bastion_user}/.ssh/${var.test_key}.pem",
      "chmod 0400 /home/${var.bastion_user}/.ssh/${var.proxy_key}.pem",
    ]

    connection {
      type        = "ssh"
      user        = "${var.bastion_user}"
      private_key = "${file("${path.root}/../data/${var.bastion_key}.pem")}"
    }
  }

  user_data = <<EOF
#!/bin/bash
yum update -y -q
yum erase -y -q ntp*
yum -y -q install chrony git

service chronyd start

git config --system credential.https://git-codecommit.${var.aws_region}.amazonaws.com.helper '!aws --profile default codecommit credential-helper $@'
git config --system credential.https://git-codecommit.${var.aws_region}.amazonaws.com.UseHttpPath true

sudo -u ${var.bastion_user} mkdir ~${var.bastion_user}/.aws ~${var.bastion_user}/bin
sudo -u ${var.bastion_user} aws configure set region ${var.aws_region}
sudo -u ${var.bastion_user} aws configure set output json
cd ~${var.bastion_user}/bin
sudo -u ${var.bastion_user} wget https://releases.hashicorp.com/terraform/0.10.7/terraform_0.10.7_linux_amd64.zip
sudo -u ${var.bastion_user} unzip terraform*zip
cd ..
sudo -u ${var.bastion_user} git clone https://git-codecommit.${var.aws_region}.amazonaws.com/v1/repos/bastion-smoketest

EOF
}
