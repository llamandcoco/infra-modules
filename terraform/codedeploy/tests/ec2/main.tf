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

# Test the module with EC2 blue/green deployment configuration
# This demonstrates advanced features like auto rollback and load balancer integration
module "test_ec2_bluegreen_codedeploy" {
  source = "../../"

  # Required variables
  application_name      = "test-ec2-bluegreen-app"
  deployment_group_name = "test-ec2-bluegreen-group"

  # EC2 compute platform
  compute_platform = "Server"

  # Create service role automatically
  create_service_role = true

  # Half at a time deployment strategy
  deployment_config_name = "CodeDeployDefault.HalfAtATime"

  # Deploy to Auto Scaling Groups
  autoscaling_groups = [
    "web-asg-blue",
    "web-asg-green"
  ]

  # Blue/Green deployment configuration
  blue_green_deployment_config = {
    terminate_blue_instances_action  = "TERMINATE"
    termination_wait_time_in_minutes = 5
    deployment_ready_action          = "CONTINUE_DEPLOYMENT"
    green_fleet_provisioning_action  = "COPY_AUTO_SCALING_GROUP"
  }

  # Load balancer configuration
  load_balancer_info = {
    target_group_names = ["web-target-group"]
    elb_names          = []
  }

  # Enable auto rollback on failure
  auto_rollback_enabled = true
  auto_rollback_events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]

  # CloudWatch alarms for monitoring
  alarm_names = [
    "high-cpu-alarm",
    "high-error-rate-alarm"
  ]
  ignore_poll_alarm_failure = false

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    TestType    = "ec2-bluegreen"
  }
}

# Test outputs
output "application_name" {
  description = "The name of the CodeDeploy application"
  value       = module.test_ec2_bluegreen_codedeploy.application_name
}

output "application_arn" {
  description = "The ARN of the CodeDeploy application"
  value       = module.test_ec2_bluegreen_codedeploy.application_arn
}

output "deployment_group_name" {
  description = "The name of the deployment group"
  value       = module.test_ec2_bluegreen_codedeploy.deployment_group_name
}

output "deployment_group_arn" {
  description = "The ARN of the deployment group"
  value       = module.test_ec2_bluegreen_codedeploy.deployment_group_arn
}

output "role_arn" {
  description = "The ARN of the IAM role"
  value       = module.test_ec2_bluegreen_codedeploy.role_arn
}
