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

data "aws_ami" "get_ami" {
  most_recent = true
  owners = [ "amazon" ]
}

output "aws_ami" {
    # Return Obj
    value = data.aws_ami.get_ami

    # value = data.aws_ami.get_ami.id
}

resource "aws_instance" "mywebserver01" {
  ami = data.aws_ami.get_ami.id
  instance_type = "t3.micro"

  tags = {
    Name = "MyWebServer01"
  }
}