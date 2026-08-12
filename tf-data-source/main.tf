terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# --------------------------------------------------
# Fetch existing Amazon Linux 2023 AMI
# --------------------------------------------------

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --------------------------------------------------
# Fetch existing VPC
# --------------------------------------------------

data "aws_vpc" "existing_vpc" {
  filter {
    name   = "tag:Name"
    values = ["my-vpc"]
  }
}

# --------------------------------------------------
# Fetch existing Subnet
# --------------------------------------------------

data "aws_subnet" "existing_subnet" {
  vpc_id = data.aws_vpc.existing_vpc.id

  filter {
    name   = "tag:Name"
    values = ["my-public-subnet"]
  }
}

# --------------------------------------------------
# Fetch existing Security Group
# --------------------------------------------------

data "aws_security_group" "existing_sg" {
  vpc_id = data.aws_vpc.existing_vpc.id

  filter {
    name   = "tag:Name"
    values = ["my-web-sg"]
  }
}

# --------------------------------------------------
# Fetch AWS Caller Identity
# --------------------------------------------------

data "aws_caller_identity" "current" {}

# --------------------------------------------------
# Fetch Available Availability Zones
# --------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"
}

# --------------------------------------------------
# Create EC2 Instance
# --------------------------------------------------

resource "aws_instance" "mywebserver01" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  subnet_id = data.aws_subnet.existing_subnet.id

  vpc_security_group_ids = [
    data.aws_security_group.existing_sg.id
  ]

  tags = {
    Name = "MyWebServer01"
  }
}

# --------------------------------------------------
# Outputs - AMI
# --------------------------------------------------

output "ami_id" {
  value = data.aws_ami.amazon_linux.id
}

output "ami_name" {
  value = data.aws_ami.amazon_linux.name
}

# --------------------------------------------------
# Outputs - Existing AWS Infrastructure
# --------------------------------------------------

output "vpc_id" {
  value = data.aws_vpc.existing_vpc.id
}

output "subnet_id" {
  value = data.aws_subnet.existing_subnet.id
}

output "security_group_id" {
  value = data.aws_security_group.existing_sg.id
}

# --------------------------------------------------
# Outputs - EC2
# --------------------------------------------------

output "ec2_public_ip" {
  value = aws_instance.mywebserver01.public_ip
}

# --------------------------------------------------
# Outputs - AWS Caller Identity
# --------------------------------------------------

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "aws_caller_user_id" {
  value = data.aws_caller_identity.current.user_id
}

# --------------------------------------------------
# Outputs - Availability Zones
# --------------------------------------------------

output "availability_zones" {
  value = data.aws_availability_zones.available.names
}