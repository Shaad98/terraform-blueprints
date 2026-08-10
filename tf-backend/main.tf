terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 6.0"
    }
    random = {
        source = "hashicorp/random"
        version = "~> 3.9.0"
    }
  }
  backend "s3" {
    # Bucket name where to preserve state file 
    bucket = "mybucket-terraform-backend-12345"
    # Region has to provide manually bcz variables load after this backend config
    region = "us-east-1"
    # File where we have to maintain state
    key = "backend.tfstate"
  }
}

resource "random_id" "random_value" {
  byte_length = 8
}

resource "aws_instance" "mywebserver01" {
  ami = "ami-0bdc7d025135d7b49"
  instance_type = "t3.micro"
  tags = {
    Name = "mywebserver01-${random_id.random_value.hex}"
  }
}