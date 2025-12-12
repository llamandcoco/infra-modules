# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "parameters" {
  description = <<-EOT
    Map of SSM parameters to create. Key is the parameter name (must start with /),
    value is an object with parameter configuration.

    Example:
      parameters = {
        "/app/db/host" = {
          value       = "db.example.com"
          type        = "String"
          description = "Database hostname"
        }
        "/app/api/key" = {
          value       = "secret-key"
          type        = "SecureString"
          kms_key_id  = "alias/app-secrets"
          description = "API key for external service"
        }
      }
  EOT
  type = map(object({
    value           = string
    type            = optional(string)
    description     = optional(string)
    tier            = optional(string)
    kms_key_id      = optional(string)
    overwrite       = optional(bool)
    data_type       = optional(string)
    allowed_pattern = optional(string)
    tags            = optional(map(string))
  }))

  validation {
    condition     = alltrue([for name, _ in var.parameters : can(regex("^/", name))])
    error_message = "All parameter names must start with a forward slash (/)."
  }

  validation {
    condition     = alltrue([for name, _ in var.parameters : length(name) >= 1 && length(name) <= 2048])
    error_message = "All parameter names must be between 1 and 2048 characters."
  }
}

# -----------------------------------------------------------------------------
# Default Configuration
# -----------------------------------------------------------------------------

variable "default_type" {
  description = "Default parameter type if not specified per parameter. String for plain text, SecureString for encrypted sensitive data (recommended), StringList for comma-separated values."
  type        = string
  default     = "SecureString"

  validation {
    condition     = contains(["String", "StringList", "SecureString"], var.default_type)
    error_message = "Parameter type must be one of: String, StringList, SecureString."
  }
}

variable "default_tier" {
  description = "Default parameter tier if not specified per parameter. Standard (up to 4KB, free), Advanced (up to 8KB, charges apply), Intelligent-Tiering (automatic tier selection)."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Advanced", "Intelligent-Tiering"], var.default_tier)
    error_message = "Parameter tier must be one of: Standard, Advanced, Intelligent-Tiering."
  }
}

variable "default_kms_key_id" {
  description = "Default KMS key ID for SecureString parameters if not specified per parameter. If not specified, uses the default AWS-managed key (alias/aws/ssm)."
  type        = string
  default     = null
}

variable "default_overwrite" {
  description = "Default overwrite behavior if not specified per parameter. Set to true to update existing parameters, false to prevent accidental overwrites."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Tagging Configuration
# -----------------------------------------------------------------------------

variable "common_tags" {
  description = "Common tags to add to all parameters. Use this for resource organization, cost allocation, and governance. Individual parameter tags will be merged with these."
  type        = map(string)
  default     = {}
}
