# ------------------------------------------------------------
# Terraform Configuration
# ------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.9.0"
    }
  }
}


# ------------------------------------------------------------
# Random ID
# Used to generate a unique S3 bucket name.
# S3 bucket names must be globally unique across AWS.
# ------------------------------------------------------------

resource "random_id" "bucket_suffix" {
  byte_length = 8
}


# ------------------------------------------------------------
# S3 Bucket
# Creates the bucket that will store the static website files.
# ------------------------------------------------------------

resource "aws_s3_bucket" "static_website" {
  bucket = "my-bucket-terraform-static-hosting-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "terraform-static-website"
    Environment = "learning"
    ManagedBy   = "Terraform"
  }
}


# ------------------------------------------------------------
# S3 Object - index.html
# Uploads the main HTML file to the S3 bucket.
# ------------------------------------------------------------

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.static_website.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
}


# ------------------------------------------------------------
# S3 Object - style.css
# Uploads the CSS file to the S3 bucket.
# ------------------------------------------------------------

resource "aws_s3_object" "style_css" {
  bucket       = aws_s3_bucket.static_website.id
  key          = "style.css"
  source       = "${path.module}/style.css"
  content_type = "text/css"
}


# ------------------------------------------------------------
# S3 Object - script.js
# Uploads the JavaScript file to the S3 bucket.
# ------------------------------------------------------------

resource "aws_s3_object" "script_js" {
  bucket       = aws_s3_bucket.static_website.id
  key          = "script.js"
  source       = "${path.module}/script.js"
  content_type = "text/javascript"
}


# ------------------------------------------------------------
# S3 Public Access Block
#
# S3 blocks public access by default.
# Since this bucket is being used for public static
# website hosting, public access must be allowed.
# ------------------------------------------------------------

resource "aws_s3_bucket_public_access_block" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


# ------------------------------------------------------------
# S3 Bucket Policy
#
# Allows anyone on the internet to read objects from
# this bucket.
#
# This is required for public S3 static website hosting.
# ------------------------------------------------------------

resource "aws_s3_bucket_policy" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  depends_on = [
    aws_s3_bucket_public_access_block.static_website
  ]

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"

        Action = [
          "s3:GetObject"
        ]

        Resource = "${aws_s3_bucket.static_website.arn}/*"
      }
    ]
  })
}


# ------------------------------------------------------------
# S3 Static Website Configuration
#
# Configures S3 to serve index.html as the default
# document when someone accesses the website.
# ------------------------------------------------------------

resource "aws_s3_bucket_website_configuration" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  index_document {
    suffix = "index.html"
  }
}