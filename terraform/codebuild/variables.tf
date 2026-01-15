# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "CodeBuild project name. Used for resource naming and tagging."
  type        = string

  validation {
    condition     = length(var.project_name) >= 2 && length(var.project_name) <= 255
    error_message = "Project name must be between 2 and 255 characters long."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.project_name))
    error_message = "Project name must contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "ecr_repository_name" {
  description = "ECR repository name for the IMAGE_REPO_NAME environment variable."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-_/]*$", var.ecr_repository_name))
    error_message = "ECR repository name must start with a lowercase letter or number and contain only lowercase letters, numbers, hyphens, underscores, and slashes."
  }
}

variable "aws_account_id" {
  description = "AWS Account ID for the AWS_ACCOUNT_ID environment variable."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "AWS Account ID must be a 12-digit number."
  }
}

# -----------------------------------------------------------------------------
# Source Configuration
# -----------------------------------------------------------------------------

variable "source_type" {
  description = <<-EOT
    Source type for CodeBuild project.
    Valid values: GITHUB, CODEPIPELINE, CODECOMMIT, S3, BITBUCKET, GITHUB_ENTERPRISE, NO_SOURCE
  EOT
  type        = string
  default     = "GITHUB"

  validation {
    condition = contains([
      "GITHUB", "CODEPIPELINE", "CODECOMMIT", "S3",
      "BITBUCKET", "GITHUB_ENTERPRISE", "NO_SOURCE"
    ], var.source_type)
    error_message = "Source type must be one of: GITHUB, CODEPIPELINE, CODECOMMIT, S3, BITBUCKET, GITHUB_ENTERPRISE, NO_SOURCE."
  }
}

variable "github_location" {
  description = "GitHub repository URL (e.g., https://github.com/owner/repo.git). Required when source_type is GITHUB."
  type        = string
  default     = null
}

variable "github_branch" {
  description = "GitHub branch to build from. Defaults to main."
  type        = string
  default     = "main"

  validation {
    condition     = can(regex("^[a-zA-Z0-9/_-]+$", var.github_branch))
    error_message = "GitHub branch must contain only alphanumeric characters, slashes, hyphens, and underscores."
  }
}

variable "github_webhook" {
  description = "Enable GitHub webhook trigger for automatic builds on push and pull requests."
  type        = bool
  default     = true
}

variable "github_token" {
  description = <<-EOT
    GitHub Personal Access Token for webhook authentication.
    Leave empty to skip GitHub source credential creation.
  EOT
  type        = string
  default     = ""
  sensitive   = true
}

variable "buildspec_path" {
  description = "Path to buildspec.yml file in the repository."
  type        = string
  default     = "buildspec.yml"
}

# -----------------------------------------------------------------------------
# S3 Artifact Configuration
# -----------------------------------------------------------------------------

variable "enable_artifact_bucket_access" {
  description = "Grant CodeBuild read/write access to the pipeline artifact bucket. Required for CodePipeline integration."
  type        = bool
  default     = false
}

variable "artifact_bucket_arn" {
  description = "ARN of the S3 bucket for pipeline artifacts. Required when enable_artifact_bucket_access is true."
  type        = string
  default     = null

  validation {
    condition     = var.artifact_bucket_arn == null || can(regex("^arn:aws:s3:::[a-z0-9][a-z0-9.-]*$", var.artifact_bucket_arn))
    error_message = "Artifact bucket ARN must be a valid S3 bucket ARN format."
  }
}

# -----------------------------------------------------------------------------
# Compute Configuration
# -----------------------------------------------------------------------------

variable "compute_type" {
  description = <<-EOT
    CodeBuild compute type determining instance size and resources.
    Valid values: BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, BUILD_GENERAL1_LARGE,
    BUILD_GENERAL1_2XLARGE, BUILD_LAMBDA_*
  EOT
  type        = string
  default     = "BUILD_GENERAL1_SMALL"

  validation {
    condition     = can(regex("^BUILD_(GENERAL1|LAMBDA)_", var.compute_type))
    error_message = "Compute type must be a valid CodeBuild compute type (e.g., BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM)."
  }
}

variable "image" {
  description = <<-EOT
    Docker image to use for builds. Must be a CodeBuild-managed or custom image.
    Default uses AWS standard image with Docker support.
  EOT
  type        = string
  default     = "aws/codebuild/standard:7.0"
}

variable "privileged_mode" {
  description = <<-EOT
    Enable privileged mode for Docker builds.
    Required for building Docker images (docker build, docker-compose).
  EOT
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Logging Configuration
# -----------------------------------------------------------------------------

variable "logs_retention_days" {
  description = <<-EOT
    CloudWatch Logs retention period in days.
    Valid values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653
  EOT
  type        = number
  default     = 7

  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365,
      400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653
    ], var.logs_retention_days)
    error_message = "Logs retention days must be a valid CloudWatch Logs retention period."
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
