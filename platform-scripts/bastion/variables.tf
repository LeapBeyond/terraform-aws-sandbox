variable "aws_region" {}
variable "bastion_key" {}
variable "test_key" {}

variable "bastion_ssh_inbound" {
  type = "list"
}

variable "tags" {
  type = "map"
}

variable "bastion_user" {
  default = "ec2-user"
}

variable "bastion_ami_name" {
  default = "amzn-ami-hvm-2017.09.0.20170930-x86_64-ebs"
}

variable "bastion_instance_type" {
  default = "t2.micro"
}

# 172.16.0.0 - 172.16.255.255
variable "bastion_vpc_cidr" {
  default = "172.16.0.0/16"
}

# 172.16.10.0 - 172.16.10.63
variable "bastion_subnet_cidr" {
  default = "172.16.10.0/26"
}

variable "root_vol_size" {
  default = 10
}
