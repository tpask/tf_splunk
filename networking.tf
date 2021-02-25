
#create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.1.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.owner} - VPC"
  }
}

#create public subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.1.0.0/24"
  tags = {
    Name = "${var.owner}-Public Subnet"
  }
}

#create gateway
resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.owner}- Internet Gateway"
  }
}

#create route table
resource "aws_route_table" "my_vpc_rt" {
    vpc_id = aws_vpc.my_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_vpc_igw.id
    }
    tags = {
        Name = "${var.owner} - Public Subnet Route Table."
    }
}

#associate route to subnet
resource "aws_route_table_association" "my_vpc" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.my_vpc_rt.id
}
