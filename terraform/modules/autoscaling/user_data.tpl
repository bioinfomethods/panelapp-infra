#!/bin/bash
mkdir /tmp/ssm
cd /tmp/ssm
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
yum install -y https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-latest-x86_64/postgresql10-libs-10.7-2PGDG.rhel7.x86_64.rpm
yum install -y https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-latest-x86_64/postgresql10-10.7-2PGDG.rhel7.x86_64.rpm
yum install -y https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-latest-x86_64/postgresql10-server-10.7-2PGDG.rhel7.x86_64.rpm
