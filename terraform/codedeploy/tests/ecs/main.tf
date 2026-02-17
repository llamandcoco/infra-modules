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

# Test the module with ECS deployment configuration
# This demonstrates ECS-specific configuration with traffic shifting
module "test_ecs_codedeploy" {
  source = "../../"

  # Required variables
  application_name      = "test-ecs-app"
  deployment_group_name = "test-ecs-group"

  # ECS compute platform
  compute_platform = "ECS"

  # Create service role automatically
  create_service_role = true

  # ECS deployment configuration
  deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes"
  deployment_type        = "BLUE_GREEN"

  # ECS service required for ECS deployment groups
  ecs_service = {
    cluster_name = "test-ecs-cluster"
    service_name = "test-ecs-service"
  }

  # ECS deployments require at least one target group
  load_balancer_info = {
    target_group_names = ["test-ecs-target-group"]
    elb_names          = []
  }

  # Enable auto rollback on deployment issues
  auto_rollback_enabled = true
  auto_rollback_events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    TestType    = "ecs"
  }
}

# Test outputs
output "application_name" {
  description = "The name of the CodeDeploy ECS application"
  value       = module.test_ecs_codedeploy.application_name
}

output "compute_platform" {
  description = "The compute platform"
  value       = module.test_ecs_codedeploy.compute_platform
}

output "deployment_group_name" {
  description = "The name of the ECS deployment group"
  value       = module.test_ecs_codedeploy.deployment_group_name
}

output "deployment_group_arn" {
  description = "The ARN of the ECS deployment group"
  value       = module.test_ecs_codedeploy.deployment_group_arn
}

output "role_arn" {
  description = "The ARN of the IAM role"
  value       = module.test_ecs_codedeploy.role_arn
}
