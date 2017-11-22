variable "nexus_key" {}
variable "bastion_ssh_sg_id" {}
variable "bastion_subnet_id" {}
variable "bastion_vpc_id" {}
variable "test_vpc_cidr" {}

variable "bastion_inbound" {
  type = "list"
}

variable "tags" {
  type = "map"
}

variable "nexus_user" {
  default = "ec2-user"
}

variable "nexus_ami_name" {
  default = "amzn-ami-hvm-2017.09.0.20170930-x86_64-ebs"
}

variable "nexus_instance_type" {
  default = "m4.large"
}

variable "root_vol_size" {
  default = 10
}
