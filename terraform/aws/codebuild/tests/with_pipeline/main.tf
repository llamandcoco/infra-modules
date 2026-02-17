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

# Test the module with CodePipeline integration
# This demonstrates how to use CodeBuild with CodePipeline and S3 artifacts
module "test_pipeline_codebuild" {
  source = "../../"

  # Required variables
  project_name        = "test-pipeline-build"
  ecr_repository_name = "test-app"
  aws_account_id      = "123456789012"

  # Use CodePipeline as source
  source_type = "CODEPIPELINE"

  # Disable GitHub webhook (not used with CodePipeline)
  github_webhook = false

  # Enable S3 artifact access for CodePipeline integration
  enable_artifact_bucket_access = true
  artifact_bucket_arn           = "arn:aws:s3:::test-pipeline-artifacts"

  # Build configuration
  compute_type    = "BUILD_GENERAL1_SMALL"
  privileged_mode = true

  # CloudWatch Logs
  logs_retention_days = 7

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    TestType    = "pipeline-integration"
  }
}

# Test outputs
output "project_name" {
  description = "The name of the CodeBuild project"
  value       = module.test_pipeline_codebuild.project_name
}

output "role_arn" {
  description = "The ARN of the IAM role"
  value       = module.test_pipeline_codebuild.role_arn
}

output "log_group_name" {
  description = "The CloudWatch Log Group name"
  value       = module.test_pipeline_codebuild.log_group_name
}
