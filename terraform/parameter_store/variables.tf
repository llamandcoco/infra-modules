# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "parameter_name" {
  description = "Name of the SSM parameter. Should follow a hierarchical naming pattern like /app/environment/config. Must start with forward slash."
  type        = string

  validation {
    condition     = can(regex("^/", var.parameter_name))
    error_message = "Parameter name must start with a forward slash (/)."
  }

  validation {
    condition     = length(var.parameter_name) >= 1 && length(var.parameter_name) <= 2048
    error_message = "Parameter name must be between 1 and 2048 characters."
  }
}

variable "value" {
  description = "Value of the parameter. For SecureString types, this should be sensitive data like passwords or API keys. For StringList, use comma-separated values."
  type        = string
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Parameter Type and Security Configuration
# -----------------------------------------------------------------------------

variable "type" {
  description = "Type of parameter. String for plain text, SecureString for encrypted sensitive data (recommended), StringList for comma-separated values."
  type        = string
  default     = "SecureString"

  validation {
    condition     = contains(["String", "StringList", "SecureString"], var.type)
    error_message = "Parameter type must be one of: String, StringList, SecureString."
  }
}

variable "kms_key_id" {
  description = "KMS key ID, ARN, alias, or alias ARN to use for encrypting SecureString parameters. If not specified, uses the default AWS-managed key (alias/aws/ssm). Only applies to SecureString type."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Parameter Configuration
# -----------------------------------------------------------------------------

variable "description" {
  description = "Description of the parameter. Explain what the parameter is used for and any important context."
  type        = string
  default     = null
}

variable "tier" {
  description = "Parameter tier determines storage limits and pricing. Standard (up to 4KB, free), Advanced (up to 8KB, charges apply), Intelligent-Tiering (automatic tier selection)."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Advanced", "Intelligent-Tiering"], var.tier)
    error_message = "Parameter tier must be one of: Standard, Advanced, Intelligent-Tiering."
  }
}

variable "overwrite" {
  description = "Whether to overwrite an existing parameter. Set to true to update existing parameters, false to prevent accidental overwrites."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Data Validation Configuration
# -----------------------------------------------------------------------------

variable "data_type" {
  description = "Data type for the parameter value. Used for validation. Common values: text (AWS default when not specified), aws:ec2:image (for AMI IDs). Defaults to null, which allows AWS to use its default (text)."
  type        = string
  default     = null

  validation {
    condition     = var.data_type == null || can(regex("^(text|aws:ec2:image)$", var.data_type))
    error_message = "Data type must be either 'text' or 'aws:ec2:image', or null."
  }
}

variable "allowed_pattern" {
  description = "Regular expression pattern to validate parameter values. Useful for enforcing value formats. Example: '^[a-zA-Z0-9]*$' for alphanumeric only."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Tagging Configuration
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to the parameter. Use this for resource organization, cost allocation, and governance."
  type        = map(string)
  default     = {}
}
