# -----------------------------------------------------------------------------
# Parameter Outputs
# -----------------------------------------------------------------------------

output "parameter_names" {
  description = "Map of parameter names. Use this to reference parameters in other resources or data sources."
  value       = { for k, v in aws_ssm_parameter.this : k => v.name }
}

output "parameter_arns" {
  description = "Map of parameter ARNs. Use this for IAM policies, cross-account access, and resource tagging."
  value       = { for k, v in aws_ssm_parameter.this : k => v.arn }
}

output "parameter_types" {
  description = "Map of parameter types (String, StringList, or SecureString). Useful for validation and documentation."
  value       = { for k, v in aws_ssm_parameter.this : k => v.type }
}

output "parameter_versions" {
  description = "Map of parameter versions. Increments with each update, useful for change tracking and rollback scenarios."
  value       = { for k, v in aws_ssm_parameter.this : k => v.version }
}

# -----------------------------------------------------------------------------
# Full Parameter Details
# -----------------------------------------------------------------------------

output "parameters" {
  description = "Complete map of all parameter details including name, ARN, type, version, etc."
  value = {
    for k, v in aws_ssm_parameter.this : k => {
      name      = v.name
      arn       = v.arn
      type      = v.type
      tier      = v.tier
      version   = v.version
      key_id    = v.key_id
      data_type = v.data_type
      tags      = v.tags_all
    }
  }
}
