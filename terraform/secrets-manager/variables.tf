# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "secrets" {
  description = <<-EOT
    Map of secrets to create in AWS Secrets Manager. Key is the secret name,
    value is an object with secret configuration.

    Example:
      secrets = {
        "prod/database/password" = {
          secret_string = jsonencode({
            username = "admin"
            password = "super-secret-password"
          })
          description             = "Database credentials"
          kms_key_id              = "alias/app-secrets"
          rotation_enabled        = true
          rotation_lambda_arn     = "arn:aws:lambda:us-east-1:123456789012:function:SecretsManagerRotation"
          rotation_days           = 30
        }
        "prod/api/key" = {
          secret_string = "api-key-value"
          description   = "API key for external service"
        }
      }
  EOT
  type = map(object({
    secret_string           = optional(string)
    secret_binary           = optional(string)
    description             = optional(string)
    kms_key_id              = optional(string)
    recovery_window_in_days = optional(number)
    rotation_enabled        = optional(bool)
    rotation_lambda_arn     = optional(string)
    rotation_days           = optional(number)
    version_stages          = optional(list(string))
    tags                    = optional(map(string))
  }))

  validation {
    condition = alltrue([
      for name, secret in var.secrets :
      (secret.secret_string != null && secret.secret_binary == null) ||
      (secret.secret_string == null && secret.secret_binary != null)
    ])
    error_message = "Each secret must have either secret_string or secret_binary, but not both."
  }

  validation {
    condition = alltrue([
      for name, secret in var.secrets :
      secret.rotation_enabled != true || secret.rotation_lambda_arn != null
    ])
    error_message = "When rotation_enabled is true, rotation_lambda_arn must be specified."
  }
}

# -----------------------------------------------------------------------------
# Default Configuration
# -----------------------------------------------------------------------------

variable "default_kms_key_id" {
  description = "Default KMS key ID for secret encryption if not specified per secret. If not specified, uses the AWS managed key (aws/secretsmanager)."
  type        = string
  default     = null
}

variable "default_recovery_window_in_days" {
  description = "Default recovery window in days for deleted secrets if not specified per secret. Must be between 7 and 30 days. Set to 0 for immediate deletion (not recommended for production)."
  type        = number
  default     = 30

  validation {
    condition     = var.default_recovery_window_in_days == 0 || (var.default_recovery_window_in_days >= 7 && var.default_recovery_window_in_days <= 30)
    error_message = "Recovery window must be 0 (immediate deletion) or between 7 and 30 days."
  }
}

variable "default_rotation_days" {
  description = "Default number of days between automatic rotations if not specified per secret. Must be between 1 and 365 days."
  type        = number
  default     = 30

  validation {
    condition     = var.default_rotation_days >= 1 && var.default_rotation_days <= 365
    error_message = "Rotation days must be between 1 and 365."
  }
}

# -----------------------------------------------------------------------------
# Tagging Configuration
# -----------------------------------------------------------------------------

variable "common_tags" {
  description = "Common tags to add to all secrets. Use this for resource organization, cost allocation, and governance. Individual secret tags will be merged with these."
  type        = map(string)
  default     = {}
}
