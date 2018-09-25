resource "aws_instance" "ec2_instance" {
  ami = "${data.aws_ami.centos.id}"
  instance_type = "t2.small"
  tags {
    Name = "ec2_instance"
  }
}

