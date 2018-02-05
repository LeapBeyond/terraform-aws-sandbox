terraform {
  backend "s3" {
    region         = "eu-west-2"
    profile        = "adm_rhook_cli"
    dynamodb_table = "terraform-state-lock"
    bucket         = "terraform-state20180205182440636400000001"
    key            = "terraform-aws-sandbox/platform-scripts"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:eu-west-2:889199313043:key/0332f798-716a-4203-8078-63140c319e6a"
  }
}
