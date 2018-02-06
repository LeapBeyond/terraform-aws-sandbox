#!/bin/bash

yum update -y -q
yum erase -y -q ntp*
yum -y -q install chrony squid
service chronyd start
chkconfig squid on

cat <<EOF > /etc/squid/squid.conf
acl localnet src ${bastion_subnet}
acl localnet src ${secure_subnet}
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
refresh_pattern . 0 20% 4320
EOF

service squid restart
