/* variables to inject */
variable "ssh_inbound" {
  type = "list"
}

variable "tags" {
  type = "map"
}

variable "bastion_vpc_id" {}
variable "bastion_subnet_id" {}
variable "test_vpc_cidr" {}
variable "test_subnet_cidr" {}
variable "proxy_subnet_cidr" {}

# variable "nexus_subnet_id" {}
variable "test_key" {}

variable "bastion_rt_id" {}

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
