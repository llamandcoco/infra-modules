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

# Test the module with minimal configuration
# This creates a basic CodeBuild project for Docker builds with GitHub integration
module "test_basic_codebuild" {
  source = "../../"

  # Required variables
  project_name        = "test-basic-build"
  ecr_repository_name = "test-app"
  aws_account_id      = "123456789012"

  # GitHub source
  github_location = "https://github.com/example/app.git"
  github_branch   = "main"

  # Enable GitHub webhook for automatic builds
  github_webhook = true

  # Default compute configuration
  compute_type    = "BUILD_GENERAL1_SMALL"
  privileged_mode = true

  # Default buildspec location
  buildspec_path = "buildspec.yml"

  # CloudWatch Logs with default retention
  logs_retention_days = 7

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    TestType    = "basic"
  }
}

# Test outputs
output "project_name" {
  description = "The name of the CodeBuild project"
  value       = module.test_basic_codebuild.project_name
}

output "project_arn" {
  description = "The ARN of the CodeBuild project"
  value       = module.test_basic_codebuild.project_arn
}

output "role_arn" {
  description = "The ARN of the IAM role"
  value       = module.test_basic_codebuild.role_arn
}

output "log_group_name" {
  description = "The CloudWatch Log Group name"
  value       = module.test_basic_codebuild.log_group_name
}

output "webhook_url" {
  description = "The GitHub webhook URL"
  value       = module.test_basic_codebuild.webhook_url
}
