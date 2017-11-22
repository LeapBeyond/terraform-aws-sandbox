# Bastion
This is the set of terraform resources to create and manage the Infrastructure

## Notes
If this has just been pulled out of git, then need to do `terraform init` and possibly `terraform get` before can proceed to anything else

## todo
 - SSM per <https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-patch-walkthrough.html>
 - currently there's a dependency problem between the bastion and securevpc modules. the latter wants to look up the
   route table for the former, but they are executing in parallel, so fail out if the bastion route table does not already exist.
   - going further, the route in the bastion route table out through the peering connection gets dropped on some runs.
