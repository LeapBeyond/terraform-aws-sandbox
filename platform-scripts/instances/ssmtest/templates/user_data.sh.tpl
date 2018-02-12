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

# note that this is specific to RHEL - see https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-install-startup-linux.html
yum install -y https://s3-${aws_region}.amazonaws.com/amazon-ssm-${aws_region}/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl start amazon-ssm-agent

cat <<AGENT > /etc/systemd/system/amazon-ssm-agent.service
[Unit]
Description=amazon-ssm-agent
After=network-online.target

[Service]
Type=simple
WorkingDirectory=/usr/bin/
ExecStart=/usr/bin/amazon-ssm-agent
KillMode=process
Restart=on-failure
RestartSec=15min
Environment="http_proxy=http://${proxy_address}:3128"
Environment="https_proxy=http://${proxy_address}:3128"
Environment="HTTP_PROXY=http://${proxy_address}:3128"
Environment="HTTPS_PROXY=http://${proxy_address}:3128"
Environment="no_proxy=169.254.169.254"

[Install]
WantedBy=multi-user.target
AGENT

systemctl daemon-reload
systemctl restart amazon-ssm-agent
