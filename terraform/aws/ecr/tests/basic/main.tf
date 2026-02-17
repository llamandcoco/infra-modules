terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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
# Test 1: Basic ECR repository with default security settings
# -----------------------------------------------------------------------------

module "basic_repository" {
  source = "../../"

  repository_name = "test-basic-repo"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "basic-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 2: ECR repository with KMS encryption
# -----------------------------------------------------------------------------

module "kms_encrypted_repository" {
  source = "../../"

  repository_name = "test-kms-repo"

  # Use mock KMS key ARN for testing
  kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "kms-encryption-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 3: ECR repository with lifecycle policy
# -----------------------------------------------------------------------------

module "lifecycle_repository" {
  source = "../../"

  repository_name = "test-lifecycle-repo"

  lifecycle_policy = [
    {
      description     = "Keep last 10 production images"
      tag_status      = "tagged"
      tag_prefix_list = ["prod-", "v"]
      count_type      = "imageCountMoreThan"
      count_number    = 10
    },
    {
      description  = "Remove untagged images older than 7 days"
      tag_status   = "untagged"
      count_type   = "sinceImagePushed"
      count_unit   = "days"
      count_number = 7
    },
    {
      description     = "Keep last 5 development images"
      tag_status      = "tagged"
      tag_prefix_list = ["dev-"]
      count_type      = "imageCountMoreThan"
      count_number    = 5
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "lifecycle-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 4: ECR repository with repository policy for cross-account access
# -----------------------------------------------------------------------------

module "policy_repository" {
  source = "../../"

  repository_name = "test-policy-repo"

  repository_policy_statements = [
    {
      sid        = "AllowCrossAccountPull"
      effect     = "Allow"
      principals = ["arn:aws:iam::123456789012:root"]
      actions = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ]
    },
    {
      sid        = "AllowCICDPush"
      effect     = "Allow"
      principals = ["arn:aws:iam::123456789012:role/ci-cd-role"]
      actions = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ]
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "policy-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 5: ECR repository with all features combined
# -----------------------------------------------------------------------------

module "comprehensive_repository" {
  source = "../../"

  repository_name      = "test-comprehensive-repo"
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true
  kms_key_arn          = "arn:aws:kms:us-east-1:123456789012:key/87654321-4321-4321-4321-210987654321"

  lifecycle_policy = [
    {
      description  = "Keep last 15 images"
      tag_status   = "any"
      count_type   = "imageCountMoreThan"
      count_number = 15
    }
  ]

  repository_policy_statements = [
    {
      sid        = "AllowPull"
      effect     = "Allow"
      principals = ["arn:aws:iam::123456789012:root"]
      actions = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ]
    }
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Purpose     = "comprehensive-testing"
    Project     = "test-project"
  }
}

# -----------------------------------------------------------------------------
# Test Outputs
# -----------------------------------------------------------------------------

output "basic_repository_url" {
  description = "URL of the basic test repository"
  value       = module.basic_repository.repository_url
}

output "basic_repository_arn" {
  description = "ARN of the basic test repository"
  value       = module.basic_repository.repository_arn
}

output "kms_repository_encryption" {
  description = "Encryption type used for KMS repository"
  value       = module.kms_encrypted_repository.encryption_type
}

output "lifecycle_repository_name" {
  description = "Name of the lifecycle test repository"
  value       = module.lifecycle_repository.repository_name
}

output "policy_repository_policy_enabled" {
  description = "Whether repository policy is enabled"
  value       = module.policy_repository.repository_policy_enabled
}

output "comprehensive_repository_registry_id" {
  description = "Registry ID of the comprehensive test repository"
  value       = module.comprehensive_repository.registry_id
}

output "comprehensive_repository_scan_enabled" {
  description = "Whether scan on push is enabled for comprehensive repository"
  value       = module.comprehensive_repository.scan_on_push_enabled
}
