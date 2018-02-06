# terraform-aws-sandbox

This is a set of terraform and other scripts that intended to be able to bootstrap up a _tabula-rasa_ AWS account
with several VPCs and instances that can be used to explore security issues. In general terms it should be considered
a base environment that can be expanded on, and probably if you want to add other services or infrastructure you should
consider forking it.

I'm also hoping that this will evolve into an exemplar of general best practices and common conventions around using
AWS and Terraform.

## To use
First modify and execute the `bootstrap-scripts` to get the base accounts, groups, keys and S3 backend sorted out.

Second setup `terraform.tfvars` for the `platform-scripts`, then do appropriate `terraform init` & `terraform apply` to get it all up and running. Be aware that the terraform scripts may complete well before the EC2 instances finish initialising.
