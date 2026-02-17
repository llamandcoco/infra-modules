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
# This creates a basic CodeDeploy application and deployment group for EC2 instances
module "test_basic_codedeploy" {
  source = "../../"

  # Required variables
  application_name      = "test-app"
  deployment_group_name = "test-deployment-group"

  # Use default Server compute platform (EC2/On-Premises)
  compute_platform = "Server"

  # Create service role automatically
  create_service_role = true

  # Default deployment configuration
  deployment_config_name = "CodeDeployDefault.OneAtATime"

  # Deploy to EC2 instances with specific tags
  ec2_tag_filters = [
    {
      key   = "Environment"
      type  = "KEY_AND_VALUE"
      value = "production"
    },
    {
      key   = "Application"
      type  = "KEY_AND_VALUE"
      value = "web"
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    TestType    = "basic"
  }
}

# Test outputs
output "application_name" {
  description = "The name of the CodeDeploy application"
  value       = module.test_basic_codedeploy.application_name
}

output "application_arn" {
  description = "The ARN of the CodeDeploy application"
  value       = module.test_basic_codedeploy.application_arn
}

output "deployment_group_name" {
  description = "The name of the deployment group"
  value       = module.test_basic_codedeploy.deployment_group_name
}

output "deployment_group_arn" {
  description = "The ARN of the deployment group"
  value       = module.test_basic_codedeploy.deployment_group_arn
}

output "role_arn" {
  description = "The ARN of the IAM role"
  value       = module.test_basic_codedeploy.role_arn
}
