# -----------------------------------------------------------------------------
# Bucket Identification Outputs
# -----------------------------------------------------------------------------

output "bucket_name" {
  description = "The name of the GCS bucket. Use this for bucket policy references and other resource configurations."
  value       = google_storage_bucket.this.name
}

output "bucket_url" {
  description = "The base URL of the bucket, in the format gs://<bucket-name>."
  value       = google_storage_bucket.this.url
}

output "bucket_self_link" {
  description = "The URI of the bucket for use in other resources. Use this for cross-resource references."
  value       = google_storage_bucket.this.self_link
}

# -----------------------------------------------------------------------------
# Bucket Configuration Outputs
# -----------------------------------------------------------------------------

output "bucket_location" {
  description = "The location where the bucket is deployed (region or multi-region)."
  value       = google_storage_bucket.this.location
}

output "storage_class" {
  description = "The Storage Class of the bucket."
  value       = google_storage_bucket.this.storage_class
}

# -----------------------------------------------------------------------------
# Security Outputs
# -----------------------------------------------------------------------------

output "versioning_enabled" {
  description = "Whether versioning is enabled on the bucket. Important for compliance and data protection verification."
  value       = var.versioning_enabled
}

output "encryption_key_name" {
  description = "The Cloud KMS key name used for encryption, if CMEK is enabled. Null if using Google-managed keys."
  value       = var.encryption_key_name
}

output "uniform_bucket_level_access" {
  description = "Whether uniform bucket-level access is enabled for IAM-only access control."
  value       = var.uniform_bucket_level_access
}

output "public_access_prevention" {
  description = "The public access prevention setting for the bucket."
  value       = var.public_access_prevention
}

# -----------------------------------------------------------------------------
# Reference Outputs
# -----------------------------------------------------------------------------

output "labels" {
  description = "All labels applied to the bucket, including default and custom labels."
  value       = google_storage_bucket.this.labels
}

output "project" {
  description = "The project in which the bucket is created."
  value       = google_storage_bucket.this.project
}
