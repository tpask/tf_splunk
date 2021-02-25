provider "aws" { region = var.region }


variable "region" { type = string }
variable "owner" { type = string }
variable "instance_type" { type = string }


# vars
variable "priv_key" {
  default = "~/.ssh/id_rsa"
  type = string
}

variable "pub_key_file" {
  default = "~/.ssh/id_rsa.pub"
  type = string
}

variable "project" {
  default = "splunk"
  type = string
}
variable "splunk_download" {
  default = "https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.1.1&product=splunk&filename=splunk-8.1.1-08187535c166-linux-2.6-x86_64.rpm&wget=true"
  type = string
}
variable "ssh_user" {
  default = "centos"
  type = string
}
variable "ssh_port" {
  default = 22
  type = number
}
#get my local address:
data "http" "workstation-external-ip" { url = "http://ipv4.icanhazip.com" }
locals { workstation-external-cidr = "${chomp(data.http.workstation-external-ip.body)}/32" }

# define userdata
locals {
  instance-userdata = <<EOF
#!/bin/bash
splunk_download="${var.splunk_download}"
echo "start installing splunk: $splunk_download" >/tmp/out.txt
splunk_rpm=`echo $splunk_download | awk -F'[=&]' '{print $10}'`
SPLUNK_HOME=/opt/splunk
cd /tmp
yum install wget -y
wget -O $splunk_rpm $splunk_download >/dev/null 2>&1
yum update -y
rpm -ivh $splunk_rpm
splunk_passwd="changeme"
$SPLUNK_HOME/bin/splunk start --answer-yes --no-prompt --accept-license --seed-passwd $splunk_passwd
$SPLUNK_HOME/bin/splunk enable boot-start
logger `date`: done
echo "done installing splunk" >>/tmp/out.txt
EOF
}
