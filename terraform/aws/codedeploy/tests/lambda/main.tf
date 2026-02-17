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

# Test the module with Lambda deployment configuration
# This demonstrates Lambda-specific features like canary deployments
module "test_lambda_codedeploy" {
  source = "../../"

  # Required variables
  application_name      = "test-lambda-app"
  deployment_group_name = "test-lambda-group"

  # Lambda compute platform
  compute_platform = "Lambda"

  # Create service role automatically
  create_service_role = true

  # Canary deployment - 10% traffic shift after 5 minutes
  deployment_config_name = "CodeDeployDefault.LambdaCanary10Percent5Minutes"

  # Lambda uses blue/green deployments with traffic control
  deployment_type = "BLUE_GREEN"

  # Enable auto rollback on failure or alarm
  auto_rollback_enabled = true
  auto_rollback_events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]

  # CloudWatch alarms for monitoring Lambda errors
  alarm_names = [
    "lambda-error-rate-alarm",
    "lambda-duration-alarm"
  ]
  ignore_poll_alarm_failure = false

  # SNS notifications for deployment events
  trigger_configurations = [
    {
      trigger_name       = "deployment-success"
      trigger_events     = ["DeploymentSuccess"]
      trigger_target_arn = "arn:aws:sns:us-east-1:123456789012:deployment-notifications"
    },
    {
      trigger_name       = "deployment-failure"
      trigger_events     = ["DeploymentFailure"]
      trigger_target_arn = "arn:aws:sns:us-east-1:123456789012:deployment-alerts"
    }
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    TestType    = "lambda"
  }
}

# Test outputs
output "application_name" {
  description = "The name of the CodeDeploy application"
  value       = module.test_lambda_codedeploy.application_name
}

output "application_arn" {
  description = "The ARN of the CodeDeploy application"
  value       = module.test_lambda_codedeploy.application_arn
}

output "compute_platform" {
  description = "The compute platform"
  value       = module.test_lambda_codedeploy.compute_platform
}

output "deployment_group_name" {
  description = "The name of the deployment group"
  value       = module.test_lambda_codedeploy.deployment_group_name
}

output "deployment_group_arn" {
  description = "The ARN of the deployment group"
  value       = module.test_lambda_codedeploy.deployment_group_arn
}

output "role_arn" {
  description = "The ARN of the IAM role"
  value       = module.test_lambda_codedeploy.role_arn
}
