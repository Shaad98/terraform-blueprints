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