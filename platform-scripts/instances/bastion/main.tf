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

# ------------------------ Bastion Instance --------------------------------------------------------

resource "aws_instance" "bastion" {
  ami                    = "${data.aws_ami.target_ami.id}"
  instance_type          = "${var.bastion_instance_type}"
  key_name               = "${var.bastion_key}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${var.ssh_access_sg_id}"]

  iam_instance_profile = "${var.profile_name}"

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

  user_data = <<EOF
#!/bin/bash
yum update -y -q
yum erase -y -q ntp*
yum -y -q install chrony git
service chronyd start

git config --system credential.https://git-codecommit.${var.aws_region}.amazonaws.com.helper '!aws --profile default codecommit credential-helper $@'
git config --system credential.https://git-codecommit.${var.aws_region}.amazonaws.com.UseHttpPath true

sudo -u ${var.bastion_user} sudo -u ${var.bastion_user} mkdir ~${var.bastion_user}/.aws ~${var.bastion_user}/.ssh ~${var.bastion_user}/bin
sudo -u ${var.bastion_user} aws configure set region ${var.aws_region}
sudo -u ${var.bastion_user} sudo -u ${var.bastion_user} aws configure set output json
cd ~${var.bastion_user}/bin
sudo -u ${var.bastion_user} wget https://releases.hashicorp.com/terraform/0.10.7/terraform_0.10.7_linux_amd64.zip
sudo -u ${var.bastion_user} unzip terraform*zip
cd ..
sudo -u ${var.bastion_user} git clone https://git-codecommit.${var.aws_region}.amazonaws.com/v1/repos/bastion-smoketest

sudo -u ${var.bastion_user} aws ssm get-parameter --name ${var.test_key}_pem --with-decryption --output text --query Parameter.Value > ~${var.bastion_user}/.ssh/${var.test_key}.pem
sudo -u ${var.bastion_user} aws ssm get-parameter --name ${var.proxy_key}_pem --with-decryption --output text --query Parameter.Value > ~${var.bastion_user}/.ssh/${var.proxy_key}.pem

chown ${var.bastion_user}:${var.bastion_user} ~${var.bastion_user}/.ssh/*.pem
chmod 400 ~${var.bastion_user}/.ssh/*.pem
EOF
}
