/*
#this is how we would create a new key but instead, we are using caller's private key instead:
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
*/

#add pubkey to AWS
resource "aws_key_pair" "add_key" {
  key_name   = "key-for-${var.project}"
  public_key = file(var.pub_key_file)
}

resource "random_uuid" "sg" {
}

#create security groups
# note this SG only allows regional FH.  NEED to modify if you are sending from multipl/different region
resource "aws_security_group" "firehose" {
  name        = "firehose-${random_uuid.sg.result}"
  description = "Allow all inbound from us FH on port"
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port   = 0
    to_port     = 8088
    protocol    = "tcp"
    cidr_blocks = [ var.fire_hose_cidr[var.region] ]
  }
  tags = {
    Name = "${var.owner} - allow Firehose:8088 from my region only"
  }
}

#create security groups
resource "aws_security_group" "allow_my_pc" {
  name        = "allow_all"
  description = "Allow all inbound connections from my workstaion"
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ local.workstation-external-cidr ]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.owner} - allow all to my address only"
  }
}

#create security bastian in public subnet
resource "aws_instance" "my_instance" {
  ami           = data.aws_ami.centos8.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.add_key.key_name
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids  = [ aws_security_group.allow_my_pc.id, aws_security_group.firehose.id ]
  # use this when not using FH: vpc_security_group_ids  = [ aws_security_group.allow_my_pc.id ]
  associate_public_ip_address = true
  tags = {
    Name = "${var.owner}-${var.project}"
  }
  user_data_base64 = base64encode(local.instance-userdata)
}
