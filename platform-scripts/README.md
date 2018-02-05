# Bastion
This is the set of terraform resources to create and manage the Infrastructure

## Notes
If this has just been pulled out of git, then need to do `terraform init` and possibly `terraform get` before can proceed to anything else

Also note that the region and profile are duplicated between the `backend.tf` and `variables.tf`/`terraform.tfvars` files - that is currently because configuring the S3 backend for Terraform does not support interpolation.
