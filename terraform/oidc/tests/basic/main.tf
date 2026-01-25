terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# Mock AWS provider for testing without credentials
provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  access_key = "test"
  secret_key = "test"
}

# -----------------------------------------------------------------------------
# Test 1: GitHub Actions OIDC with specific repository
# -----------------------------------------------------------------------------

module "github_single_repo" {
  source = "../../"

  role_name   = "test-github-single-repo-role"
  github_org  = "my-organization"
  github_repo = "my-repository"

  policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "github-single-repo-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 2: GitHub Actions OIDC with all repositories in organization
# -----------------------------------------------------------------------------

module "github_all_repos" {
  source = "../../"

  role_name   = "test-github-all-repos-role"
  github_org  = "my-organization"
  github_repo = "*"

  policy_arns = [
    "arn:aws:iam::aws:policy/PowerUserAccess"
  ]

  tags = {
    Environment = "test"
    Purpose     = "github-all-repos-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 3: GitHub Actions OIDC with specific branch
# -----------------------------------------------------------------------------

module "github_main_branch" {
  source = "../../"

  role_name     = "test-github-main-branch-role"
  github_org    = "my-organization"
  github_repo   = "production-app"
  github_branch = "main"

  inline_policy_statements = [
    {
      sid    = "AllowECRAccess"
      effect = "Allow"
      actions = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ]
      resources = ["*"]
      condition = null
    }
  ]

  tags = {
    Environment = "production"
    Purpose     = "github-branch-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 4: Multiple branches with explicit OIDC subjects (recommended approach)
# -----------------------------------------------------------------------------

module "github_multiple_branches" {
  source = "../../"

  role_name = "test-github-multi-branch-role"

  # Best practice: Use explicit oidc_subjects instead of wildcards
  # Set github_org/repo/branch to null to avoid wildcard subjects
  github_org    = null
  github_repo   = null
  github_branch = null

  oidc_subjects = [
    "repo:my-organization/my-repository:ref:refs/heads/main",
    "repo:my-organization/my-repository:ref:refs/heads/develop",
    "repo:my-organization/my-repository:ref:refs/heads/staging"
  ]

  inline_policy_statements = [
    {
      sid    = "AllowS3Access"
      effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ]
      resources = [
        "arn:aws:s3:::my-bucket",
        "arn:aws:s3:::my-bucket/*"
      ]
      condition = null
    },
    {
      sid    = "AllowSecretsManagerRead"
      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      resources = [
        "arn:aws:secretsmanager:us-east-1:123456789012:secret:app/*"
      ]
      condition = null
    }
  ]

  tags = {
    Environment = "test"
    Purpose     = "multi-branch-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 5: Comprehensive - GitHub with managed and inline policies
# -----------------------------------------------------------------------------

module "github_comprehensive" {
  source = "../../"

  role_name   = "test-github-comprehensive-role"
  github_org  = "comprehensive-org"
  github_repo = "comprehensive-app"

  # Managed policies
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  ]

  # Inline policies
  inline_policy_statements = [
    {
      sid    = "AllowParameterStore"
      effect = "Allow"
      actions = [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath"
      ]
      resources = [
        "arn:aws:ssm:*:*:parameter/app/*"
      ]
      condition = null
    },
    {
      sid    = "AllowKMSDecrypt"
      effect = "Allow"
      actions = [
        "kms:Decrypt",
        "kms:DescribeKey"
      ]
      resources = [
        "arn:aws:kms:us-east-1:123456789012:key/*"
      ]
      condition = null
    }
  ]

  max_session_duration = 3600

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Purpose     = "comprehensive-testing"
    Team        = "platform"
  }
}

# -----------------------------------------------------------------------------
# Test 6: Pull request access
# -----------------------------------------------------------------------------

module "github_pull_requests" {
  source = "../../"

  role_name = "test-github-pr-role"

  # Explicit control - allow pull requests
  github_org    = null
  github_repo   = null
  github_branch = null

  oidc_subjects = [
    "repo:my-organization/my-repository:pull_request"
  ]

  policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]

  tags = {
    Environment = "test"
    Purpose     = "pull-request-testing"
  }
}

# -----------------------------------------------------------------------------
# Test Outputs
# -----------------------------------------------------------------------------

output "github_single_repo_role_arn" {
  description = "ARN of the GitHub single repo role"
  value       = module.github_single_repo.role_arn
}

output "github_all_repos_role_name" {
  description = "Name of the GitHub all repos role"
  value       = module.github_all_repos.role_name
}

output "github_multiple_branches_role_arn" {
  description = "ARN of the multi-branch role"
  value       = module.github_multiple_branches.role_arn
}

output "github_comprehensive_role_id" {
  description = "Unique ID of the comprehensive role"
  value       = module.github_comprehensive.role_id
}

output "github_pull_requests_role_arn" {
  description = "ARN of the pull request role"
  value       = module.github_pull_requests.role_arn
}
