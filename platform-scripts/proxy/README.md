# Module Proxy

This module creates an ec2 instance in the bastion vpc running a Squid proxy that can be used by the 'securevpc' instances for yum updates.

## TODO
SSH to this instance should only be from the bastion, not the wider internet.
