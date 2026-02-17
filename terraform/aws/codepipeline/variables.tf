# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "pipeline_name" {
  description = "Name of the CodePipeline. Used for resource naming and tagging."
  type        = string

  validation {
    condition     = length(var.pipeline_name) >= 1 && length(var.pipeline_name) <= 100
    error_message = "Pipeline name must be between 1 and 100 characters long."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.pipeline_name))
    error_message = "Pipeline name must contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "env" {
  description = "Environment name used for resource naming and SSM parameter paths."
  type        = string

  validation {
    condition     = length(var.env) >= 1 && length(var.env) <= 50
    error_message = "Environment name must be between 1 and 50 characters long."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.env))
    error_message = "Environment name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "app" {
  description = "Application name used for resource naming and SSM parameter paths."
  type        = string

  validation {
    condition     = length(var.app) >= 1 && length(var.app) <= 50
    error_message = "Application name must be between 1 and 50 characters long."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.app))
    error_message = "Application name must contain only lowercase letters, numbers, and hyphens."
  }
}

# -----------------------------------------------------------------------------
# GitHub Configuration
# -----------------------------------------------------------------------------

variable "github_owner" {
  description = "GitHub repository owner (organization or username)."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.github_owner))
    error_message = "GitHub owner must contain only alphanumeric characters and hyphens."
  }
}

variable "github_repo" {
  description = "GitHub repository name."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+$", var.github_repo))
    error_message = "GitHub repository name must contain only alphanumeric characters, dots, hyphens, and underscores."
  }
}

variable "github_branch" {
  description = "GitHub branch to monitor for changes and trigger pipeline executions."
  type        = string
  default     = "main"

  validation {
    condition     = can(regex("^[a-zA-Z0-9/_-]+$", var.github_branch))
    error_message = "GitHub branch must contain only alphanumeric characters, slashes, hyphens, and underscores."
  }
}

# -----------------------------------------------------------------------------
# CodeBuild Integration
# -----------------------------------------------------------------------------

variable "codebuild_project_name" {
  description = "Name of the CodeBuild project to use in the Build stage."
  type        = string
}

variable "codebuild_project_arn" {
  description = "ARN of the CodeBuild project. Used for IAM permissions."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:codebuild:[a-z0-9-]+:[0-9]{12}:project/[a-zA-Z0-9_-]+$", var.codebuild_project_arn))
    error_message = "CodeBuild project ARN must be a valid ARN format."
  }
}

# -----------------------------------------------------------------------------
# Testing Configuration
# -----------------------------------------------------------------------------

variable "skip_data_source_lookup" {
  description = "Skip AWS data source lookups for testing without credentials. Uses mock values instead."
  type        = bool
  default     = false
}

variable "mock_account_id" {
  description = "Mock AWS account ID to use when skip_data_source_lookup is true."
  type        = string
  default     = "123456789012"
}

variable "mock_github_token" {
  description = "Mock GitHub token to use when skip_data_source_lookup is true."
  type        = string
  default     = "mock-token"
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Security Configuration
# -----------------------------------------------------------------------------

variable "kms_key_id" {
  description = <<-EOT
    KMS key ID for S3 bucket encryption.
    If not provided, uses AWS-managed encryption (AES256).
    For enhanced security, provide a customer-managed KMS key ARN or alias.
    Examples:
    - Key ARN: arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012
    - Alias ARN: arn:aws:kms:us-east-1:123456789012:alias/my-key
    - Key ID: 12345678-1234-1234-1234-123456789012
  EOT
  type        = string
  default     = null

  validation {
    condition = var.kms_key_id == null || can(regex(
      "^(arn:aws:kms:[a-z0-9-]+:[0-9]{12}:(key|alias)/[a-zA-Z0-9/_-]+|[a-f0-9-]+)$",
      var.kms_key_id
    ))
    error_message = "KMS key ID must be a valid KMS key ARN, alias ARN, or key ID."
  }
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
