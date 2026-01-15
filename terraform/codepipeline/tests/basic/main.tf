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
# This creates a basic CodePipeline with GitHub source and CodeBuild
module "test_basic_pipeline" {
  source = "../../"

  # Required variables
  pipeline_name = "test-basic-pipeline"
  env           = "dev"
  app           = "myapp"

  # GitHub configuration
  github_owner  = "myorg"
  github_repo   = "myrepo"
  github_branch = "main"

  # CodeBuild integration
  codebuild_project_name = "test-build-project"
  codebuild_project_arn  = "arn:aws:codebuild:us-east-1:123456789012:project/test-build-project"

  # Skip real AWS calls for testing
  skip_data_source_lookup = true
  mock_account_id         = "123456789012"
  mock_github_token       = "test-token"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    TestType    = "basic"
  }
}

# Test outputs
output "pipeline_name" {
  description = "The name of the CodePipeline"
  value       = module.test_basic_pipeline.pipeline_name
}

output "pipeline_arn" {
  description = "The ARN of the CodePipeline"
  value       = module.test_basic_pipeline.pipeline_arn
}

output "artifact_bucket_name" {
  description = "The name of the S3 artifact bucket"
  value       = module.test_basic_pipeline.artifact_bucket_name
}

output "pipeline_role_arn" {
  description = "The ARN of the pipeline IAM role"
  value       = module.test_basic_pipeline.pipeline_role_arn
}
