variable "subnet_id" {}

variable "tags" {
  type = "map"
}

variable "proxy_key" {}

variable "test_subnet_cidr" {}
variable "bastion_subnet_cidr" {}
variable "ssh_sg_id" {}
variable "proxy_sg_id" {}

variable "proxy_ami_name" {
  default = "amzn-ami-hvm-2017.09.0.20170930-x86_64-ebs"
}

variable "proxy_user" {
  default = "ec2-user"
}

variable "proxy_instance_type" {
  default = "t2.micro"
}

variable "root_vol_size" {
  default = 10
}
