# variable "region" {
#   description = "AWS region"
#   default = "us-east-1"
# }
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}



# Create a VPC
# resource "aws_vpc" "example" {
#   cidr_block = "10.0.0.0/16"
# }


# AMI is of SUSE Linux
resource "aws_instance" "myserver" {
  ami = "ami-0b12a86a613a04fc6"
  instance_type = "t2.micro"

  tags = {
    Name = "MyWebServer"
  }

}