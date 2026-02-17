terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# SSM Parameters
# Creates multiple parameters in AWS Systems Manager Parameter Store
# Supports String, StringList, and SecureString types with optional KMS encryption
resource "aws_ssm_parameter" "this" {
  for_each = var.parameters

  name        = each.key
  description = try(each.value.description, null)
  type        = try(each.value.type, var.default_type)
  value       = each.value.value
  tier        = try(each.value.tier, var.default_tier)
  key_id      = try(each.value.type, var.default_type) == "SecureString" ? try(each.value.kms_key_id, var.default_kms_key_id) : null
  overwrite   = try(each.value.overwrite, var.default_overwrite)

  # Data type validation for StringList parameters
  data_type = try(each.value.data_type, null)

  # Allowed patterns for parameter values (optional validation)
  allowed_pattern = try(each.value.allowed_pattern, null)

  tags = merge(
    var.common_tags,
    try(each.value.tags, {}),
    {
      Name = each.key
    }
  )
}
