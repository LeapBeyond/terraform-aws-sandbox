variable "subnet_id" {}
variable "vpc_id" {}

variable "ssh_inbound" {
  type = "list"
}

variable "tags" {
  type = "map"
}

variable "proxy_subnet_cidr" {}
variable "proxy_address" {}
variable "test_key" {}
variable "profile_name" {}

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
