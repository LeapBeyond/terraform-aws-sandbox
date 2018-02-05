variable "aws_region" {}
variable "bastion_key" {}
variable "test_key" {}
variable "bastion_vpc_cidr" {}
variable "bastion_subnet_cidr" {}

variable "bastion_ssh_inbound" {
  type = "list"
}

variable "tags" {
  type = "map"
}

variable "bastion_user" {
  default = "ec2-user"
}

variable "default_network_acl_id" {
  default = "acl-6c6a2f05"
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
