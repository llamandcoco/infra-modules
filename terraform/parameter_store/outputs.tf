# -----------------------------------------------------------------------------
# Parameter Identification Outputs
# -----------------------------------------------------------------------------

output "parameter_name" {
  description = "The name of the SSM parameter. Use this to reference the parameter in other resources or data sources."
  value       = aws_ssm_parameter.this.name
}

output "parameter_arn" {
  description = "The ARN of the SSM parameter. Use this for IAM policies, cross-account access, and resource tagging."
  value       = aws_ssm_parameter.this.arn
}

# -----------------------------------------------------------------------------
# Parameter Configuration Outputs
# -----------------------------------------------------------------------------

output "parameter_type" {
  description = "The type of the parameter (String, StringList, or SecureString). Useful for validation and documentation."
  value       = aws_ssm_parameter.this.type
}

output "parameter_tier" {
  description = "The tier of the parameter (Standard, Advanced, or Intelligent-Tiering). Important for cost tracking and capacity planning."
  value       = aws_ssm_parameter.this.tier
}

output "parameter_version" {
  description = "The version number of the parameter. Increments with each update, useful for change tracking and rollback scenarios."
  value       = aws_ssm_parameter.this.version
}

# -----------------------------------------------------------------------------
# Security Outputs
# -----------------------------------------------------------------------------

output "kms_key_id" {
  description = "The KMS key ID used for encryption, if SSE-KMS is enabled for SecureString. Returns null for non-SecureString types or when using AWS-managed keys."
  value       = aws_ssm_parameter.this.key_id
}

# -----------------------------------------------------------------------------
# Data Type Outputs
# -----------------------------------------------------------------------------

output "data_type" {
  description = "The data type of the parameter (e.g., text, aws:ec2:image). Used for parameter value validation."
  value       = aws_ssm_parameter.this.data_type
}

# -----------------------------------------------------------------------------
# Reference Outputs
# -----------------------------------------------------------------------------

output "tags" {
  description = "All tags applied to the parameter, including default and custom tags."
  value       = aws_ssm_parameter.this.tags_all
}
