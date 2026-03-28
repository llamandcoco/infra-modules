# GitHub Actions OIDC Example
# This example shows how to configure OIDC for GitHub Actions workflows

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

# Example 1: Single repository with specific branch
module "github_actions_single_repo" {
  source = "../../"

  role_name        = "github-actions-deploy-role"
  role_description = "Role for GitHub Actions to deploy applications"

  github_org    = "my-organization"
  github_repo   = "my-app"
  github_branch = "main"

  # Attach managed policies
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Team        = "platform"
  }
}

# Example 2: All repositories in organization
module "github_actions_org_wide" {
  source = "../../"

  role_name   = "github-actions-read-only-role"
  github_org  = "my-organization"
  github_repo = "*" # Allow all repositories

  policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]

  tags = {
    Environment = "development"
    Purpose     = "read-only-access"
  }
}

# Example 3: Multiple branches with inline policies
module "github_actions_multi_branch" {
  source = "../../"

  role_name = "github-actions-s3-deploy-role"

  # Use custom subjects for multiple branches
  oidc_subjects = [
    "repo:my-organization/my-app:ref:refs/heads/main",
    "repo:my-organization/my-app:ref:refs/heads/develop",
    "repo:my-organization/my-app:ref:refs/heads/staging"
  ]

  # Custom inline policies
  inline_policy_statements = [
    {
      sid    = "AllowS3Deploy"
      effect = "Allow"
      actions = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ]
      resources = [
        "arn:aws:s3:::my-app-bucket",
        "arn:aws:s3:::my-app-bucket/*"
      ]
      condition = null
    },
    {
      sid    = "AllowCloudFrontInvalidation"
      effect = "Allow"
      actions = [
        "cloudfront:CreateInvalidation",
        "cloudfront:GetInvalidation"
      ]
      resources = ["*"]
      condition = null
    }
  ]

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}

# Outputs
output "single_repo_role_arn" {
  description = "Role ARN for single repository - use this in GitHub Actions workflow"
  value       = module.github_actions_single_repo.role_arn
}

output "org_wide_role_arn" {
  description = "Role ARN for organization-wide access"
  value       = module.github_actions_org_wide.role_arn
}

output "multi_branch_role_arn" {
  description = "Role ARN for multi-branch deployment"
  value       = module.github_actions_multi_branch.role_arn
}
