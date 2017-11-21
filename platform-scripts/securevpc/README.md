# VPC Security exploration

This is used to run up a VPC which can be used to explore security issues.

The intention is to have an EC2 instance in a subnet inside a VPC that can be connected to from (in this case) only the Bastion subnet from SSH,
but cannot connect to the internet or be contacted through the internet.

So far I have established:
 - because the instance does not have access to an internet gateway, it cannot at startup reach out to get the ECS agent from the nominated location (see `install_ssh_agent.sh`)
 - the yum repos on the RHEL box created (in `/etc/yum.repos.d`) do refer to AWS mirrors for updates, _but_ these are referenced by https to FQDN, i.e. still needs to go out across an internet gateway.
 - thus the only feasible solution is to use a local Nexus (or similar) proxy for `yum`, or add a gateway to the vpc and whitelist the aws destinations (difficult, they will be all over the place)
