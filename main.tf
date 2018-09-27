#define vars. Keep anything that is specific to me in vars.tf file
variable "instance_type" { default = "t2.small" }
variable "Name" { default = "ec2_instance" }
variable "associate_public_ip_address" { default = "true" }

/*
variable "topic" {  default = "" }
variable "key_name" { default = "" }
variable "security_groups" { default = "" }
variable "iam_instance_profile" { default = "" }
*/

resource "aws_instance" "ec2_instance" {
  ami = "${data.aws_ami.centos.id}"
  instance_type = "${var.instance_type}"
  tags { Name = "${var.Name}" }
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  security_groups = [
    "${var.security_groups}"
  ]
  iam_instance_profile = "${var.iam_instance_profile}"
  user_data = "${file("installSplunk.sh")}"
}

