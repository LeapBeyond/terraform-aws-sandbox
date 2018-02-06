# terraform-aws-sandbox

This is a set of terraform and other scripts that intended to be able to bootstrap up a _tabula-rasa_ AWS account
with several VPCs and instances that can be used to explore security issues. In general terms it should be considered
a base environment that can be expanded on, and probably if you want to add other services or infrastructure you should
consider forking it.

I'm also hoping that this will evolve into an exemplar of general best practices and common conventions around using
AWS and Terraform.


## todo
 - SSH to the proxy instance should only be from the bastion, not the internet
 - get secure instance yum.conf sorted out
 - SSM per <https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-patch-walkthrough.html>
 - currently there's a dependency problem between the bastion and securevpc modules. the latter wants to look up the
   route table for the former, but they are executing in parallel, so fail out if the bastion route table does not already exist.
   - going further, the route in the bastion route table out through the peering connection gets dropped on some runs.
 - the `data "aws_iam_policy_document" "ec2-service-role-policy"` would be clearer as a template
 - access to terraform state S3 bucket and table lock could be tightened

## Notes
/etc/yum.conf:

proxy=http://<Proxy-Server-IP-Address>:<Proxy_Port>
proxy_username=<Proxy-User-Name>
proxy_password=<Proxy-Password>


port 443,80
rhui2-cds01.eu-west-2.aws.ce.redhat.com
rhui2-cds02.eu-west-2.aws.ce.redhat.com

https://aws.amazon.com/partners/redhat/faqs/
    makes clear that only supported means is via internet gateway
    "All on-demand Red Hat Enterprise Linux (RHEL) Amazon Machine Images (AMIs) are configured to utilize the Red Hat Update Infrastructure (RHUI) in AWS. If in a VPC, Amazon EC2 RHEL instances will need to access RHUI in EC2 either through the VPC Internet Gateway, through an attached Virtual IP, or through a VPN or Direct Connect connection to a data center that routes the update request through the general internet to the RHUI servers."

<http://cbonte.github.io/haproxy-dconv/1.7/intro.html#3>
wget http://www.haproxy.org/download/1.7/src/haproxy-1.7.9.tar.gz
tar xf haproxy-1.7.9.tar.gz
ln -s haproxy-1.7.9 haproxy
cd haproxy
yum install gcc -y
make TARGET=linux2628
make install
mkdir -p /etc/haproxy
mkdir -p /var/lib/haproxy
touch /var/lib/haproxy/stats
cp examples/haproxy.init /etc/init.d/haproxy
chkconfig --add haproxy
adduser haproxy
<set up /etc/haproxy/haproxy.cfg>


---------- squid -----------------
http://pingbin.com/2014/08/centos-updateinstall-applications-proxy-yum/

yum -y install squid
chkconfig squid on
< update /etc/squid/squid.conf >
service squid restart

added to /etc/yum.conf - proxy=http://172.16.10.18:3128
looked in /var/log/squid/access.log and saw it being used


[root@ip-172-16-10-60 ~]# vi /etc/squid/squid.conf

acl localnet src 172.16.10.0/26
acl localnet src 172.17.10.0/24
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 443         
#acl Safe_ports port 1025-65535
acl CONNECT method CONNECT
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access allow localhost manager
http_access deny manager
http_access deny to_localhost
http_access allow localnet
http_access allow localhost
http_access deny all
http_port 3128
coredump_dir /var/spool/squid
refresh_pattern .               0       20%     4320

acl localnet src ${bastion_subnet} -> 172.16.10.0/26
acl localnet src ${secure_subnet} - 172.17.10.0/24


================================
proxy - remove ability to ssh to it
    - add /etc/squid/squid.conf
    - update yum.conf
