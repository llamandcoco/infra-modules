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
# Basic Bedrock Test
# Tests minimal Bedrock configuration with service role for Lambda
# No logging enabled to keep it simple
# -----------------------------------------------------------------------------

provider "aws" {
  region = "us-east-1"

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

# Create Bedrock service role for Lambda to invoke models
module "bedrock" {
  source = "../.."

  # Create service role for Lambda functions to use Bedrock
  create_service_role = true
  service_role_name   = "basic-bedrock-lambda-role"
  service_principals  = ["lambda.amazonaws.com"]

  # Provide dummy AWS context to avoid data source calls during CI/testing
  aws_account_id = "123456789012"
  aws_region     = "us-east-1"

  # Allow access to all foundation models
  allowed_model_arns = [
    "arn:aws:bedrock:*::foundation-model/*"
  ]

  # Disable logging for basic example
  enable_model_invocation_logging = false

  tags = {
    Environment = "test"
    Purpose     = "basic-bedrock-test"
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

output "claude_3_5_sonnet_arn" {
  description = "ARN for Claude 3.5 Sonnet model"
  value       = module.bedrock.claude_3_5_sonnet_arn
}

output "region" {
  description = "AWS region"
  value       = module.bedrock.region
}
