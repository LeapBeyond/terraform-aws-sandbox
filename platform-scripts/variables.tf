variable "tags" {
  default = {
    "owner"   = "rahook"
    "project" = "work-bootstrap"
    "client"  = "Internal"
  }
}

/* variables to inject via terraform.tfvars */

variable "aws_account_id" {}
variable "aws_profile" {}
variable "aws_region" {}

variable "proxy_key" {}
variable "test_key" {}
variable "bastion_key" {}

variable "ssh_inbound" {
  type = "list"
}
