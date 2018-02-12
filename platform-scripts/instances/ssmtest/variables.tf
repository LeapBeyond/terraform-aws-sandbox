variable "subnet_id" {}

variable "tags" {
  type = "map"
}

variable "proxy_address" {}
variable "test_key" {}
variable "profile_name" {}
variable "ssh_sg_id" {}
variable "proxy_access_sg_id" {}
variable "aws_region" {}

/* locally defined */
variable "ec2_user" {
  default = "ec2-user"
}

variable "ec2_ami_name" {
  default = "RHEL-7.4_HVM_GA-20170808-x86_64-2-Hourly2-GP2"
}

variable "ec2_instance_type" {
  default = "t2.micro"
}

variable "root_vol_size" {
  default = 10
}
