#get the latest ami_id
data "aws_ami" "centos8" {
  owners      = ["125523088429"]
  most_recent = true
  filter {
    name   = "name"
    values = ["CentOS 8*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
