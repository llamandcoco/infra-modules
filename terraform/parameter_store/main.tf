terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# SSM Parameter
# Creates a parameter in AWS Systems Manager Parameter Store
# Supports String, StringList, and SecureString types with optional KMS encryption
resource "aws_ssm_parameter" "this" {
  name        = var.parameter_name
  description = var.description
  type        = var.type
  value       = var.value
  tier        = var.tier
  key_id      = var.type == "SecureString" && var.kms_key_id != null ? var.kms_key_id : null
  overwrite   = var.overwrite

  # Data type validation for StringList parameters
  data_type = var.data_type

  # Allowed patterns for parameter values (optional validation)
  allowed_pattern = var.allowed_pattern

  tags = merge(
    var.tags,
    {
      Name = var.parameter_name
    }
  )
}
