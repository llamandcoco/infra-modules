# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "repository_name" {
  description = "Name of the ECR repository. This will be used to identify your container images (e.g., 'my-app', 'backend-service')."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]+(?:[/_-][a-z0-9]+)*$", var.repository_name))
    error_message = "Repository name must contain only lowercase letters, numbers, hyphens, underscores, and forward slashes. It cannot start or end with hyphens, underscores, or slashes."
  }

  validation {
    condition     = length(var.repository_name) >= 2 && length(var.repository_name) <= 256
    error_message = "Repository name must be between 2 and 256 characters long."
  }
}

# -----------------------------------------------------------------------------
# Security Variables
# -----------------------------------------------------------------------------

variable "image_tag_mutability" {
  description = <<-EOT
    Image tag mutability setting. Use 'IMMUTABLE' to prevent image tags from being overwritten (recommended for production).
    Use 'MUTABLE' to allow tags to be updated (useful for development workflows with 'latest' tags).
  EOT
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Image tag mutability must be either 'MUTABLE' or 'IMMUTABLE'."
  }
}

variable "scan_on_push" {
  description = <<-EOT
    Enable automatic image scanning on push for security vulnerabilities.
    Recommended to keep enabled for security best practices. Scans are performed using Amazon ECR basic scanning or enhanced scanning if enabled at the registry level.
  EOT
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = <<-EOT
    ARN of the KMS key to use for encryption at rest. If not specified, AES256 encryption will be used.
    Use a KMS key when you need:
    - Fine-grained access control over encryption keys
    - Audit trails via CloudTrail for key usage
    - Ability to disable/rotate encryption keys
    - Cross-account repository access with custom encryption
  EOT
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Lifecycle Policy Configuration
# -----------------------------------------------------------------------------

variable "lifecycle_policy" {
  description = <<-EOT
    List of lifecycle policy rules to manage image retention and cleanup.
    Use lifecycle policies to:
    - Remove old or unused images to reduce storage costs
    - Keep only the N most recent images
    - Expire images older than X days
    - Keep images matching specific tag patterns

    Each rule includes:
    - description: Human-readable description of the rule
    - priority: Optional explicit priority (lower numbers have higher priority). If not specified, rules are prioritized by their order in the list (first = priority 1)
    - tag_status: Either 'tagged', 'untagged', or 'any'
    - tag_prefix_list: List of tag prefixes to match (only for tagged images, omit for untagged/any)
    - count_type: Either 'imageCountMoreThan' or 'sinceImagePushed'
    - count_unit: 'days' (only for sinceImagePushed, omit for imageCountMoreThan)
    - count_number: Number of images or days

    Example:
    lifecycle_policy = [
      {
        description     = "Keep only 10 most recent production images"
        tag_status      = "tagged"
        tag_prefix_list = ["prod-"]
        count_type      = "imageCountMoreThan"
        count_number    = 10
      },
      {
        description  = "Remove untagged images older than 7 days"
        tag_status   = "untagged"
        count_type   = "sinceImagePushed"
        count_unit   = "days"
        count_number = 7
      }
    ]
  EOT
  type = list(object({
    description     = string
    priority        = optional(number)
    tag_status      = string
    tag_prefix_list = optional(list(string))
    count_type      = string
    count_unit      = optional(string)
    count_number    = number
  }))
  default = null

  validation {
    condition = var.lifecycle_policy == null ? true : alltrue([
      for rule in var.lifecycle_policy :
      contains(["tagged", "untagged", "any"], rule.tag_status)
    ])
    error_message = "Lifecycle policy tag_status must be 'tagged', 'untagged', or 'any'."
  }

  validation {
    condition = var.lifecycle_policy == null ? true : alltrue([
      for rule in var.lifecycle_policy :
      contains(["imageCountMoreThan", "sinceImagePushed"], rule.count_type)
    ])
    error_message = "Lifecycle policy count_type must be 'imageCountMoreThan' or 'sinceImagePushed'."
  }

  validation {
    condition = var.lifecycle_policy == null ? true : alltrue([
      for rule in var.lifecycle_policy :
      rule.count_type == "sinceImagePushed" ? rule.count_unit == "days" : true
    ])
    error_message = "Lifecycle policy count_unit must be 'days' when count_type is 'sinceImagePushed'."
  }
}

# -----------------------------------------------------------------------------
# Repository Policy Configuration
# -----------------------------------------------------------------------------

variable "repository_policy_statements" {
  description = <<-EOT
    List of IAM policy statements for repository access control.
    Use repository policies to:
    - Grant cross-account access to pull/push images
    - Allow specific IAM roles (e.g., CI/CD pipelines) to interact with the repository
    - Implement least-privilege access control

    Each statement includes:
    - sid: Statement ID (unique identifier)
    - effect: Either 'Allow' or 'Deny'
    - principals: List of AWS principal ARNs (IAM users, roles, or account IDs)
    - actions: List of ECR actions (e.g., 'ecr:GetDownloadUrlForLayer', 'ecr:BatchGetImage', 'ecr:PutImage')

    Example:
    repository_policy_statements = [
      {
        sid        = "AllowCrossAccountPull"
        effect     = "Allow"
        principals = ["arn:aws:iam::123456789012:root"]
        actions    = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  EOT
  type = list(object({
    sid        = string
    effect     = string
    principals = list(string)
    actions    = list(string)
  }))
  default = null

  validation {
    condition = var.repository_policy_statements == null ? true : alltrue([
      for statement in var.repository_policy_statements :
      contains(["Allow", "Deny"], statement.effect)
    ])
    error_message = "Repository policy effect must be 'Allow' or 'Deny'."
  }
}

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "force_delete" {
  description = <<-EOT
    Allow deletion of the repository even if it contains images.
    Use with caution in production environments. Setting this to true will delete all images when the repository is destroyed.
  EOT
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to the ECR repository. Use this to add consistent tagging across your infrastructure for cost allocation, environment identification, etc."
  type        = map(string)
  default     = {}
}
