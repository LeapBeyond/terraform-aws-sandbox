variable "tags" {
  default = {
    "owner"   = "rahook"
    "project" = "work-bootstrap"
    "client"  = "Internal"
  }
}

variable "bucket_prefix" {
  default = "terraform-state"
}

variable "lock_table_name" {
  default = "terraform-state-lock"
}

/* variables to inject via terraform.tfvars */
variable "aws_region" {}

variable "aws_account_id" {}
variable "aws_profile" {}
