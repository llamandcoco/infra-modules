terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ECR Repository
# Creates a private container registry repository for storing Docker images
# tfsec:ignore:aws-ecr-repository-customer-key - KMS encryption is optional and configurable via kms_key_arn variable
resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  # Image Scanning Configuration
  # Scans images on push for security vulnerabilities
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  # Encryption Configuration
  # Uses either AES256 (default) or KMS encryption for images at rest
  encryption_configuration {
    encryption_type = var.kms_key_arn != null ? "KMS" : "AES256"
    kms_key         = var.kms_key_arn
  }

  force_delete = var.force_delete

  tags = merge(
    var.tags,
    {
      Name = var.repository_name
    }
  )
}

# ECR Lifecycle Policy
# Manages image retention and cleanup based on age or count
resource "aws_ecr_lifecycle_policy" "this" {
  count      = var.lifecycle_policy != null ? 1 : 0
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      for idx, rule in var.lifecycle_policy : {
        rulePriority = rule.priority != null ? rule.priority : idx + 1
        description  = rule.description
        selection = merge(
          {
            tagStatus   = rule.tag_status
            countType   = rule.count_type
            countNumber = rule.count_number
          },
          # Only include tagPrefixList for tagged images
          rule.tag_status == "tagged" && rule.tag_prefix_list != null ? {
            tagPrefixList = rule.tag_prefix_list
          } : {},
          # Only include countUnit for sinceImagePushed
          rule.count_type == "sinceImagePushed" && rule.count_unit != null ? {
            countUnit = rule.count_unit
          } : {}
        )
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ECR Repository Policy
# Defines access control for cross-account access, CI/CD roles, etc.
resource "aws_ecr_repository_policy" "this" {
  count      = var.repository_policy_statements != null ? 1 : 0
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for statement in var.repository_policy_statements : {
        Sid    = statement.sid
        Effect = statement.effect
        Principal = {
          AWS = statement.principals
        }
        Action = statement.actions
      }
    ]
  })
}
