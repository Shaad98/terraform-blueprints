terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
# resource "aws_vpc" "example" {
#   cidr_block = "10.0.0.0/16"
# }


# AMI is of Ubuntu
resource "aws_instance" "myserver" {
  ami = "ami-091138d0f0d41ff90"
  instance_type = "t2.micro"

  tags = {
    Name = "MyWebServer"
  }

}