output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.my_bucket.bucket
}

output "random_id" {
  value = random_id.random_id.b64_url
}

