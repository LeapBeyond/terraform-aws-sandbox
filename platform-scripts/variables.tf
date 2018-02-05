variable "tags" {
  default = {
    "owner"   = "rahook"
    "project" = "work-bootstrap"
    "client"  = "Internal"
  }
}

# 94.101.220.0/24 - NZ guest network

variable "bastion_inbound" {
  type    = "list"
  default = ["94.101.220.0/24"]
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

/* variables to inject via terraform.tfvars */
variable "aws_region" {}

variable "aws_account_id" {}
variable "aws_profile" {}
variable "proxy_key" {}
variable "test_key" {}
variable "bastion_key" {}
