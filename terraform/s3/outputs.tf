output "bucket_id" {
  description = "The name of the S3 bucket."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "The bucket domain name (legacy global endpoint)."
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The bucket regional domain name."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "bucket_hosted_zone_id" {
  description = "The Route 53 hosted zone ID for the bucket endpoint."
  value       = aws_s3_bucket.this.hosted_zone_id
}

output "versioning_status" {
  description = "Current versioning status (Enabled or Suspended)."
  value       = aws_s3_bucket_versioning.this.versioning_configuration[0].status
}

output "public_access_block" {
  description = "Public access block configuration applied to the bucket. Null when disabled."
  value       = var.public_access_block_enabled ? aws_s3_bucket_public_access_block.this[0] : null
}
