variable "subnet_id" {}
variable "vpc_id" {}

variable "ssh_inbound" {
  type = "list"
}

variable "tags" {
  type = "map"
}

variable "bastion_key" {}
variable "test_key" {}
variable "proxy_key" {}
variable "aws_region" {}
variable "profile_name" {}

variable "bastion_user" {
  default = "ec2-user"
}

variable "bastion_ami_name" {
  default = "amzn-ami-hvm-2017.09.0.20170930-x86_64-ebs"
}

variable "bastion_instance_type" {
  default = "t2.micro"
}

variable "root_vol_size" {
  default = 10
}
