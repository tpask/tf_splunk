#!/usr/bin/bash

#yum update
yum update -y

#install aws cli
curl -O https://bootstrap.pypa.io/get-pip.py
python get-pip.py
pip install awscli

#this section is only for AWS instances
region=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//'`
instanceId=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
ip=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`
topic=`aws ssm get-parameter --region $region --name "/tf/techSnsArn" --output text |awk '{ print $6 }'`
host=`aws ec2 describe-tags --region $region --output text  --filter "Name=resource-id,Values=$instanceId" |awk '{print $NF}'`

#this is not necessary in TF
#aws ec2 create-tags --region $region --resources $instanceId --tags Key=Name,Value=$host

#set host name
if [ ! -z "$host" ]; then
  hostnamectl set-hostname $host
fi

#install splunk
#default admin password is "helloWorld" remember to change it.
splunk_url='https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=7.1.3&product=splunk&filename=splunk-7.1.3-51d9cac7b837-linux-2.6-x86_64.rpm&wget=true'
splunk_rpm=`echo $splunk_url | awk -F'[=&]' '{print $10}'`
SPLUNK_HOME=/opt/splunk
cd /tmp
yum install wget -y
wget -O $splunk_rpm $splunk_url >/dev/null 2>&1
rpm -ivh $splunk_rpm

#if splunk-passwd is set use it, else initial password is "changeme"
if [ -z "$splunk_passwd" ]; then
  splunk_passwd="changeme"
fi
$SPLUNK_HOME/bin/splunk start --answer-yes --no-prompt --accept-license --seed-passwd $splunk_passwd
$SPLUNK_HOME/bin/splunk enable boot-start

#notify admin that instance is up
if [ ! -z "$topic" ]; then
  aws sns publish --topic-arn $topic --region $region --message "$HOSTNAME ($ip) is up"
fi

logger `date`: done
