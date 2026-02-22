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

variable "pipeline_type" {
  description = "Pipeline type. Valid values: V1, V2"
  type        = string
  default     = "V2"

  validation {
    condition     = contains(["V1", "V2"], var.pipeline_type)
    error_message = "Pipeline type must be either V1 or V2."
  }
}

variable "execution_mode" {
  description = "Execution mode for V2 pipelines. Valid values: QUEUED, SUPERSEDED, PARALLEL"
  type        = string
  default     = "SUPERSEDED"

  validation {
    condition     = contains(["QUEUED", "SUPERSEDED", "PARALLEL"], var.execution_mode)
    error_message = "Execution mode must be one of: QUEUED, SUPERSEDED, PARALLEL."
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
# Source Configuration
# -----------------------------------------------------------------------------

variable "source_provider" {
  description = "Source provider type. Valid values: CodeStarSourceConnection, GitHub"
  type        = string
  default     = "CodeStarSourceConnection"

  validation {
    condition     = contains(["CodeStarSourceConnection", "GitHub"], var.source_provider)
    error_message = "Source provider must be either CodeStarSourceConnection or GitHub."
  }
}

variable "codestar_connection_arn" {
  description = "ARN of CodeStar connection for GitHub V2 integration. Required when source_provider is CodeStarSourceConnection."
  type        = string
  default     = null

  validation {
    condition = var.codestar_connection_arn == null || can(regex(
      "^arn:aws:(codestar-connections|codeconnections):[a-z0-9-]+:[0-9]{12}:connection/[a-f0-9-]+$",
      var.codestar_connection_arn
    ))
    error_message = "CodeStar connection ARN must be a valid ARN format."
  }
}

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

variable "github_full_repository_id" {
  description = "Full repository ID in format 'owner/repo' for CodeStarSourceConnection."
  type        = string
  default     = null
}

variable "detect_changes" {
  description = "Whether to detect changes in the source repository for CodeStarSourceConnection."
  type        = bool
  default     = false
}

variable "output_artifact_format" {
  description = "Output artifact format for CodeStarSourceConnection. Valid values: CODE_ZIP, CODEBUILD_CLONE_REF"
  type        = string
  default     = "CODE_ZIP"

  validation {
    condition     = contains(["CODE_ZIP", "CODEBUILD_CLONE_REF"], var.output_artifact_format)
    error_message = "Output artifact format must be either CODE_ZIP or CODEBUILD_CLONE_REF."
  }
}

variable "source_output_artifact_name" {
  description = "Name of the source output artifact."
  type        = string
  default     = "SourceArtifact"
}

variable "build_output_artifact_name" {
  description = "Name of the build output artifact."
  type        = string
  default     = "BuildArtifact"
}

variable "source_action_namespace" {
  description = "Namespace for source action variables."
  type        = string
  default     = "SourceVariables"
}

variable "deploy_action_namespace" {
  description = "Namespace for deploy action variables."
  type        = string
  default     = "DeployVariables"
}

# -----------------------------------------------------------------------------
# Build Stage Configuration
# -----------------------------------------------------------------------------

variable "enable_build_stage" {
  description = "Enable Build stage with CodeBuild. If false, pipeline goes directly from Source to Deploy."
  type        = bool
  default     = false
}

variable "codebuild_project_name" {
  description = "Name of the CodeBuild project to use in the Build stage. Required when enable_build_stage is true."
  type        = string
  default     = null
}

variable "codebuild_project_arn" {
  description = "ARN of the CodeBuild project. Used for IAM permissions. Required when enable_build_stage is true."
  type        = string
  default     = null

  validation {
    condition = var.codebuild_project_arn == null || can(regex(
      "^arn:aws:codebuild:[a-z0-9-]+:[0-9]{12}:project/[a-zA-Z0-9_-]+$",
      var.codebuild_project_arn
    ))
    error_message = "CodeBuild project ARN must be a valid ARN format."
  }
}

# -----------------------------------------------------------------------------
# Deploy Stage Configuration
# -----------------------------------------------------------------------------

variable "enable_deploy_stage" {
  description = "Enable Deploy stage with CodeDeploy."
  type        = bool
  default     = true
}

variable "codedeploy_applications" {
  description = <<-EOT
    List of CodeDeploy deployment configurations.
    Each deployment should have: application_name, deployment_group_name, and optional action_name, namespace, run_order.
  EOT
  type = list(object({
    application_name      = string
    deployment_group_name = string
    action_name           = optional(string, null)
    namespace             = optional(string, null)
    run_order             = optional(number, null)
  }))
  default = []
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
# Artifact Store Configuration
# -----------------------------------------------------------------------------

variable "create_artifact_bucket" {
  description = "Create a new S3 bucket for artifacts. If false, use existing bucket specified in artifact_bucket_name."
  type        = bool
  default     = true
}

variable "artifact_bucket_name" {
  description = "Name of existing S3 bucket for artifacts. Required when create_artifact_bucket is false."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Service Role Configuration
# -----------------------------------------------------------------------------

variable "create_service_role" {
  description = "Create a new IAM service role for CodePipeline. If false, use existing role specified in service_role_arn."
  type        = bool
  default     = true
}

variable "service_role_arn" {
  description = "ARN of existing IAM role for CodePipeline. Required when create_service_role is false."
  type        = string
  default     = null

  validation {
    condition     = var.service_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.service_role_arn))
    error_message = "Service role ARN must be a valid IAM role ARN."
  }
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
