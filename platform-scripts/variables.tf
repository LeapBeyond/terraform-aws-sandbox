variable "tags" {
  default = {
    "owner"   = "rahook"
    "project" = "work-bootstrap"
    "client"  = "Internal"
  }
}

# 213.205.252.0/24 - tethered to my phone
# 188.183.134.0/24 - airbnb
# 94.101.220.0/24 - NZ guest network

variable "bastion_inbound" {
  type    = "list"
  default = ["213.205.252.0/24", "188.183.134.0/24", "94.101.220.0/24"]
}

/* variables to inject via terraform.tfvars */
variable "aws_region" {}

variable "aws_account_id" {}
variable "aws_profile" {}
variable "bastion_key" {}
variable "test_key" {}
