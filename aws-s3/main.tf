terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 6.0"
    }

      random = {
      source  = "hashicorp/random"
      version = "~> 3.9.0"
    }

  }
}

resource "random_id" "random_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-bucket-${random_id.random_id.hex}"

}

resource "aws_s3_object" "my_text_file" {

  source = "./program.txt"
  key = "main.txt"
  bucket = aws_s3_bucket.my_bucket.bucket
}