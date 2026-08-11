terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my_vpc"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "private_subnet"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "public_subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my_igw"
  }
}

# Routing Table
resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id

  }
  tags = {
    Name = "my_rt"
  }
}

resource "aws_route_table_association" "public_sub" {
  route_table_id = aws_route_table.my_rt.id
  subnet_id = aws_subnet.public_subnet.id
}

resource "aws_instance" "myserver01" {
  ami = "ami-0bdc7d025135d7b49"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.public_subnet.id
  tags = {
    Name = "MyServer01"
  }
}