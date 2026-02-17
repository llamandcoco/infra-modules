# -----------------------------------------------------------------------------
# Secret Outputs
# -----------------------------------------------------------------------------

output "secret_ids" {
  description = "Map of secret IDs. Use this to reference secrets in other resources or data sources."
  value       = { for k, v in aws_secretsmanager_secret.this : k => v.id }
}

output "secret_arns" {
  description = "Map of secret ARNs. Use this for IAM policies, cross-account access, and resource tagging."
  value       = { for k, v in aws_secretsmanager_secret.this : k => v.arn }
}

output "secret_versions" {
  description = "Map of current secret version IDs. Useful for tracking secret updates and changes."
  value       = { for k, v in aws_secretsmanager_secret_version.this : k => v.version_id }
}

# -----------------------------------------------------------------------------
# Full Secret Details
# -----------------------------------------------------------------------------

output "secrets" {
  description = "Complete map of all secret details including ID, ARN, version, rotation status, etc."
  value = {
    for k, v in aws_secretsmanager_secret.this : k => {
      id                      = v.id
      arn                     = v.arn
      name                    = v.name
      description             = v.description
      kms_key_id              = v.kms_key_id
      recovery_window_in_days = v.recovery_window_in_days
      version_id              = aws_secretsmanager_secret_version.this[k].version_id
      tags                    = v.tags_all
    }
  }
}
