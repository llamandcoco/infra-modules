# -----------------------------------------------------------------------------
# Bucket Identification Outputs
# -----------------------------------------------------------------------------

output "bucket_id" {
  description = "The name/ID of the S3 bucket. Use this for bucket policy references and other resource configurations."
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket. Use this for IAM policies and cross-account access configurations."
  value       = aws_s3_bucket.main.arn
}

# -----------------------------------------------------------------------------
# Bucket Configuration Outputs
# -----------------------------------------------------------------------------

output "bucket_domain_name" {
  description = "The bucket domain name. Use this for CloudFront distributions or direct S3 website hosting."
  value       = aws_s3_bucket.main.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The bucket region-specific domain name. Use this when you need region-specific endpoints."
  value       = aws_s3_bucket.main.bucket_regional_domain_name
}

output "bucket_region" {
  description = "The AWS region where the bucket is deployed."
  value       = aws_s3_bucket.main.region
}

# -----------------------------------------------------------------------------
# Security Outputs
# -----------------------------------------------------------------------------

output "versioning_enabled" {
  description = "Whether versioning is enabled on the bucket. Important for compliance and data protection verification."
  value       = var.versioning_enabled
}

output "encryption_algorithm" {
  description = "The server-side encryption algorithm used (AES256 for SSE-S3, aws:kms for SSE-KMS)."
  value       = var.kms_key_id != null ? "aws:kms" : "AES256"
}

output "kms_key_id" {
  description = "The KMS key ID used for encryption, if SSE-KMS is enabled."
  value       = var.kms_key_id
}

# -----------------------------------------------------------------------------
# Reference Outputs
# -----------------------------------------------------------------------------

output "bucket_name" {
  description = "The name of the bucket (same as bucket_id). Provided for convenience and clarity in module outputs."
  value       = aws_s3_bucket.main.bucket
}

output "tags" {
  description = "All tags applied to the bucket, including default and custom tags."
  value       = aws_s3_bucket.main.tags_all
}
