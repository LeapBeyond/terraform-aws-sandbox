variable "tags" {
  default = {
    "owner"   = "rahook"
    "project" = "work-bootstrap"
    "client"  = "Internal"
  }
}

variable "bastion_inbound" {
  type    = "list"
  default = ["192.168.1.0/24", "151.236.44.229/32", "94.101.220.0/24", "185.122.190.0/24"]
}

/* variables to inject via terraform.tfvars */
variable "aws_region" {}

variable "aws_account_id" {}
variable "aws_profile" {}
variable "bastion_key" {}
variable "test_key" {}
