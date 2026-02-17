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

# Test the module with custom compute configuration
# This demonstrates how to use larger compute instances for resource-intensive builds
module "test_large_compute_codebuild" {
  source = "../../"

  # Required variables
  project_name        = "test-large-build"
  ecr_repository_name = "test-ml-app"
  aws_account_id      = "123456789012"

  # GitHub source
  github_location = "https://github.com/example/ml-app.git"
  github_branch   = "main"
  github_webhook  = true

  # Use larger compute for resource-intensive builds
  compute_type = "BUILD_GENERAL1_LARGE"

  # Use specific build image
  image = "aws/codebuild/standard:7.0"

  # Enable privileged mode for Docker
  privileged_mode = true

  # Longer log retention for production workloads
  logs_retention_days = 30

  # Custom buildspec location
  buildspec_path = "build/buildspec.yml"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    TestType    = "custom-compute"
    Workload    = "ml-training"
  }
}

# Test outputs
output "project_name" {
  description = "The name of the CodeBuild project"
  value       = module.test_large_compute_codebuild.project_name
}

output "project_arn" {
  description = "The ARN of the CodeBuild project"
  value       = module.test_large_compute_codebuild.project_arn
}

output "webhook_url" {
  description = "The GitHub webhook URL"
  value       = module.test_large_compute_codebuild.webhook_url
}
