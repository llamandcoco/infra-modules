terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Secrets Manager Secret
# Creates and manages secrets in AWS Secrets Manager with automatic rotation support
resource "aws_secretsmanager_secret" "this" {
  for_each = var.secrets

  name                    = each.key
  description             = try(each.value.description, null)
  kms_key_id              = try(each.value.kms_key_id, var.default_kms_key_id)
  recovery_window_in_days = try(each.value.recovery_window_in_days, var.default_recovery_window_in_days)

  tags = merge(
    var.common_tags,
    try(each.value.tags, {}),
    {
      Name = each.key
    }
  )
}

# Secret Version (stores the actual secret value)
resource "aws_secretsmanager_secret_version" "this" {
  for_each = var.secrets

  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = try(each.value.secret_string, null)
  secret_binary = try(each.value.secret_binary, null)

  # Only include version_stages if specified
  version_stages = try(each.value.version_stages, null)
}

# Optional Lambda rotation configuration
resource "aws_secretsmanager_secret_rotation" "this" {
  for_each = {
    for k, v in var.secrets : k => v
    if lookup(v, "rotation_enabled", false) == true && lookup(v, "rotation_lambda_arn", "") != ""
  }

  secret_id           = aws_secretsmanager_secret.this[each.key].id
  rotation_lambda_arn = each.value.rotation_lambda_arn

  rotation_rules {
    automatically_after_days = try(each.value.rotation_days, var.default_rotation_days)
  }

  depends_on = [aws_secretsmanager_secret_version.this]
}
