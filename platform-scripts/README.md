# Bastion
This is the set of terraform resources to create and manage the Infrastructure

## Notes
If this has just been pulled out of git, then need to do `terraform init` and possibly `terraform get` before can proceed to anything else

Also note that the region and profile are duplicated between the `backend.tf` and `variables.tf`/`terraform.tfvars` files - that is currently because configuring the S3 backend for Terraform does not support interpolation.

## AWS Parameter Store
These scripts include an example of using the AWS [Systems Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-paramstore.html) to store sone private SSH keys. The keys are stored when generated using the AWS CLI in the `bootstrap.sh` script, and then consumed when the Bastion host is created to store copies of the key locally in the Bastion host. In part this is done to demonstrate a way of injecting things onto the host without needing to do an SCP via the Terraform provisioning facility, and partially to show one way that the Paramter Store might be used.

Terraform _does_ have facilities to read and write to the Parameter Store, but you must be aware that anything stored as a SecureString is retained in the Terraform state file in plaintext (see  <https://www.terraform.io/docs/state/sensitive-data.html>), which makes this solution somewhat tricky for sensitive information. The problem can be mitigated by using an S3 backend coupled with both Terraform and S3 encryption-at-rest, and placing strong controls over who can read the backend.

If you are going to use this facility for sensitive information, be careful to _not_ use the account default encryption key (like this example currently does), but instead create a separate key that can only be used by the publishing and consuming EC2 instances. The problem can easily arise if you use the account default encryption key that a privileged AWS Console user will be able to see the plain-text value of encrypted secrets via the console.
