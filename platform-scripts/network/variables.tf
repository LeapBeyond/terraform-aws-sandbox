variable "tags" {
  type = "map"
}

variable "bastion_inbound" {
  type    = "list"
  default = ["94.101.220.0/24", "46.68.8.0/24", "80.71.142.0/24"]
}

# 172.16.0.0 - 172.16.255.255
variable "bastion_vpc_cidr" {
  default = "172.16.0.0/16"
}

# 172.16.10.0 - 172.16.10.63
variable "bastion_subnet_cidr" {
  default = "172.16.10.0/26"
}

# 172.16.10.64 - 172.16.10.127
variable "proxy_subnet_cidr" {
  default = "172.16.10.64/26"
}

# 172.17.0.0 - 172.17.255.255
variable "test_vpc_cidr" {
  default = "172.17.0.0/16"
}

# 172.17.10.0 - 172.17.10.255
variable "test_subnet_cidr" {
  default = "172.17.10.0/24"
}
