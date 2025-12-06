// terraform/s3/outputs.tf
output "bucket_id" {
  description = "The name (ID) of the S3 bucket."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "The DNS name of the S3 bucket. Useful for website endpoints."
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "versioning_enabled" {
  description = "Whether versioning is enabled on the bucket."
  value       = var.versioning_enabled
}

output "server_side_encryption_algorithm" {
  description = "The server-side encryption algorithm applied to the bucket."
  value       = var.encryption_algorithm
}
