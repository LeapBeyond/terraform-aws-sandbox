/* variables to inject */
variable "ssh_inbound" {
  type = "list"
}

variable "tags" {
  type = "map"
}

variable "bastion_vpc_id" {}
variable "bastion_subnet_id" {}
variable "test_key" {}

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

# 172.17.0.0 - 172.17.255.255
variable "test_vpc_cidr" {
  default = "172.17.0.0/16"
}

# 172.17.10.0 - 172.17.10.255
variable "test_subnet_cidr" {
  default = "172.17.10.0/24"
}

variable "root_vol_size" {
  default = 10
}