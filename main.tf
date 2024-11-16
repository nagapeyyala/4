provider "aws" {
      region = "us-east-1"
}

resource "aws_vpc" "myvpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "myvpc"
  }
}
resource "aws_subnet" "mysubnet01" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "192.168.1.0/24"
  map_public_ip_on_launch = true 
  availability_zone = "us-east-1a"
  tags = {
    Name = "mysubnet01"
  }
}
resource "aws_subnet" "mysubnet02" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "192.168.2.0/24"
  map_public_ip_on_launch = true 
  availability_zone = "us-east-1b"
  tags = {
    Name = "mysubnet02"
  }
}
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myigw"
  }
}
resource "aws_route_table" "myroutetable" {
  vpc_id = aws_vpc.myvpc.id

  # since this is exactly the route AWS will create, the route will be adopted
  route {
    cidr_block = "0.0.0.0/0" 
    gateway_id = aws_internet_gateway.myigw.id
  }
  tags = { 
    Name = "myroutetable"
  }
}
resource "aws_route_table_association" "sub1asso" {
  subnet_id      = aws_subnet.mysubnet01.id
  route_table_id = aws_route_table.myroutetable.id
}
resource "aws_route_table_association" "sub2asso" {
  subnet_id      = aws_subnet.mysubnet02.id
  route_table_id = aws_route_table.myroutetable.id
}

resource "aws_security_group" "mysg2" {
  name        = "mysg2"
  description = "Allow http and ssh inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id
  tags = {
    Name = "mysg2"
  }
}
resource "aws_vpc_security_group_ingress_rule" "allowssh" {
  security_group_id = aws_security_group.mysg2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allowhttp" {
  security_group_id = aws_security_group.mysg2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allowalltraffic" {
  security_group_id = aws_security_group.mysg2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
resource "aws_instance" "project01" {
  ami = "ami-0866a3c8686eaeeba"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.mysubnet02.id
  key_name = "potenitio"
  vpc_security_group_ids = [aws_security_group.mysg2.id]
  tags = {
    Name = "project01" 
  }
}  
