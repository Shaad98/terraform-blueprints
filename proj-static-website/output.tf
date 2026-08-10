# ------------------------------------------------------------
# S3 Bucket Information
# ------------------------------------------------------------

output "s3_bucket_name" {
  description = "Name of the S3 bucket hosting the static website."
  value       = aws_s3_bucket.static_website.bucket
}


output "s3_bucket_arn" {
  description = "ARN of the S3 bucket."
  value       = aws_s3_bucket.static_website.arn
}


output "s3_bucket_region" {
  description = "AWS region where the S3 bucket is located."
  value       = aws_s3_bucket.static_website.region
}


# ------------------------------------------------------------
# Static Website URL
# ------------------------------------------------------------

output "static_website_endpoint" {
  description = "S3 static website endpoint."
  value       = "http://${aws_s3_bucket_website_configuration.static_website.website_endpoint}"
}


# ------------------------------------------------------------
# Object URLs
# ------------------------------------------------------------

output "index_html_url" {
  description = "URL of the index.html object."
  value       = "http://${aws_s3_bucket_website_configuration.static_website.website_endpoint}/index.html"
}