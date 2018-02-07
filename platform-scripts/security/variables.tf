variable "tags" {
  type = "map"
}

variable "ssh_inbound" {
  type = "list"
}

variable "bastion_vpc_id" {}
variable "ssmtest_vpc_id" {}
variable "proxy_subnet_cidr" {}
variable "bastion_subnet_cidr" {}
