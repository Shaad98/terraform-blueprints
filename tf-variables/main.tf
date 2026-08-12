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


resource "aws_instance" "mywebserver01" {
  ami = "ami-0bdc7d025135d7b49"
  instance_type = var.aws_instance_type

  root_block_device {
    delete_on_termination = true
    volume_size = 30
    volume_type = "gp2"
  }
  tags = {
    Name = "MyWebServer01"
  }
}