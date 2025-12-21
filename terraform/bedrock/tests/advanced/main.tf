terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Advanced Bedrock Test
# Tests comprehensive Bedrock configuration with:
# - Service role for multiple AWS services
# - Model invocation logging to CloudWatch
# - Optional S3 logging configuration
# - Specific model ARN restrictions
# - Custom CloudWatch log retention
# -----------------------------------------------------------------------------

provider "aws" {
  region = "us-west-2"

  # Mock configuration for testing - no real AWS credentials needed for plan
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    bedrock        = "http://localhost:4566"
    iam            = "http://localhost:4566"
    cloudwatchlogs = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }
}

# Create Bedrock configuration with logging and service role
module "bedrock" {
  source = "../.."

  # Service Role Configuration
  create_service_role = true
  service_role_name   = "advanced-bedrock-service-role"
  service_principals = [
    "lambda.amazonaws.com",
    "ecs-tasks.amazonaws.com",
    "ec2.amazonaws.com"
  ]

  # Provide dummy AWS context to avoid data source calls during CI/testing
  aws_account_id = "123456789012"
  aws_region     = "us-west-2"

  # Restrict access to specific Claude models only
  allowed_model_arns = [
    "arn:aws:bedrock:*::foundation-model/anthropic.claude-3-5-sonnet-20241022-v2:0",
    "arn:aws:bedrock:*::foundation-model/anthropic.claude-3-opus-20240229-v1:0",
    "arn:aws:bedrock:*::foundation-model/anthropic.claude-3-haiku-20240307-v1:0"
  ]

  # Additional policies for the service role
  additional_service_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  # Model Invocation Logging Configuration
  enable_model_invocation_logging = true
  log_group_name                  = "/aws/bedrock/production/model-invocations"
  log_retention_days              = 90
  logging_role_name               = "bedrock-production-logging-role"

  # Configure what data to log
  log_text_data      = true  # Log prompts and responses
  log_image_data     = true  # Log image inputs/outputs
  log_embedding_data = false # Don't log embeddings

  # Optional: S3 logging for long-term archival
  # Uncomment these lines if you want to test S3 logging
  # s3_logging_bucket     = "my-bedrock-logs-bucket"
  # s3_logging_key_prefix = "production/bedrock-logs/"

  tags = {
    Environment = "production"
    Purpose     = "advanced-bedrock-test"
    Team        = "ai-platform"
    CostCenter  = "engineering"
  }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "service_role_arn" {
  description = "ARN of the Bedrock service role"
  value       = module.bedrock.service_role_arn
}

output "service_role_name" {
  description = "Name of the Bedrock service role"
  value       = module.bedrock.service_role_name
}

output "log_group_name" {
  description = "CloudWatch log group for Bedrock invocations"
  value       = module.bedrock.log_group_name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = module.bedrock.log_group_arn
}

output "logging_role_arn" {
  description = "ARN of the Bedrock logging role"
  value       = module.bedrock.logging_role_arn
}

output "claude_3_5_sonnet_arn" {
  description = "ARN for Claude 3.5 Sonnet model"
  value       = module.bedrock.claude_3_5_sonnet_arn
}

output "claude_3_opus_arn" {
  description = "ARN for Claude 3 Opus model"
  value       = module.bedrock.claude_3_opus_arn
}

output "claude_3_haiku_arn" {
  description = "ARN for Claude 3 Haiku model"
  value       = module.bedrock.claude_3_haiku_arn
}

output "region" {
  description = "AWS region"
  value       = module.bedrock.region
}

output "account_id" {
  description = "AWS account ID"
  value       = module.bedrock.account_id
}
