terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 6.0"
    }
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-bucket-xyz928"

}

resource "aws_s3_object" "my_text_file" {

  source = "./program.txt"
  key = "main.txt"
  bucket = aws_s3_bucket.my_bucket.bucket
}