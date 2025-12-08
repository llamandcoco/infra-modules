# -----------------------------------------------------------------------------
# Repository Identification Outputs
# -----------------------------------------------------------------------------

output "repository_name" {
  description = "The name of the ECR repository. Use this to reference the repository in deployment configurations."
  value       = aws_ecr_repository.this.name
}

output "repository_arn" {
  description = "The ARN of the ECR repository. Use this for IAM policies, resource tagging, and cross-account access configurations."
  value       = aws_ecr_repository.this.arn
}

output "repository_url" {
  description = "The URL of the ECR repository. Use this as the Docker image repository URL for pushing and pulling images (e.g., in CI/CD pipelines)."
  value       = aws_ecr_repository.this.repository_url
}

output "registry_id" {
  description = "The registry ID where the repository was created. This is typically your AWS account ID."
  value       = aws_ecr_repository.this.registry_id
}

# -----------------------------------------------------------------------------
# Security Configuration Outputs
# -----------------------------------------------------------------------------

output "image_tag_mutability" {
  description = "The tag mutability setting for the repository (MUTABLE or IMMUTABLE). Important for understanding image tag update behavior."
  value       = aws_ecr_repository.this.image_tag_mutability
}

output "scan_on_push_enabled" {
  description = "Whether image scanning on push is enabled. Important for security compliance verification."
  value       = var.scan_on_push
}

output "encryption_type" {
  description = "The encryption type used for the repository (AES256 or KMS)."
  value       = var.kms_key_arn != null ? "KMS" : "AES256"
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for encryption, if KMS encryption is enabled."
  value       = var.kms_key_arn
}

# -----------------------------------------------------------------------------
# Policy Outputs
# -----------------------------------------------------------------------------

output "lifecycle_policy_enabled" {
  description = "Whether a lifecycle policy is configured for the repository. Indicates if automatic image cleanup is active."
  value       = var.lifecycle_policy != null
}

output "repository_policy_enabled" {
  description = "Whether a repository policy is configured. Indicates if custom access control is in place."
  value       = var.repository_policy_statements != null
}

# -----------------------------------------------------------------------------
# Reference Outputs
# -----------------------------------------------------------------------------

output "tags" {
  description = "All tags applied to the repository, including default and custom tags."
  value       = aws_ecr_repository.this.tags_all
}
