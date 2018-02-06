#!/bin/bash

cat <<EOF > /etc/yum.conf
[main]
cachedir=/var/cache/yum/$basearch/$releasever
keepcache=0
debuglevel=2
logfile=/var/log/yum.log
exactarch=1
obsoletes=1
gpgcheck=1
plugins=1
installonly_limit=3
metadata_expire=90m
proxy=http://${proxy_address}:3128
EOF

yum update -y
yum erase -y ntp*

yum -y install chrony
echo "server 169.254.169.123 prefer iburst" >> /etc/chrony.conf
service chronyd restart
