# -----------------------------------------------------------------------------
# Basic EventBridge Module Test
# This example demonstrates:
# - Using the default AWS event bus
# - Creating a simple scheduled rule with rate expression
# - Single Lambda function target
# - Auto-created IAM role
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  # Skip credentials for testing
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  # Use localstack or mock endpoints for testing
  endpoints {
    events = "http://localhost:4566"
    iam    = "http://localhost:4566"
    lambda = "http://localhost:4566"
  }
}

# -----------------------------------------------------------------------------
# Mock Lambda Function (for testing purposes)
# In production, this would be a real Lambda function
# -----------------------------------------------------------------------------

resource "aws_lambda_function" "example" {
  function_name = "example-function"
  role          = "arn:aws:iam::123456789012:role/lambda-role"
  handler       = "index.handler"
  runtime       = "python3.11"
  filename      = "lambda.zip"

  # Mock configuration
  environment {
    variables = {
      ENVIRONMENT = "test"
    }
  }
}

# -----------------------------------------------------------------------------
# EventBridge Module - Basic Configuration
# -----------------------------------------------------------------------------

module "eventbridge" {
  source = "../.."

  caller_identity_override = {
    account_id = "123456789012"
    arn        = "arn:aws:iam::123456789012:user/mock"
    user_id    = "AIDAMOCK"
  }

  # Use default event bus
  event_bus_name   = "default"
  create_event_bus = false

  # Simple scheduled rule - runs every 5 minutes
  rule_name           = "example-basic-rule"
  rule_description    = "Basic example: trigger Lambda every 5 minutes"
  schedule_expression = "rate(5 minutes)"
  is_enabled          = true

  # Single Lambda target
  targets = [
    {
      target_id = "lambda-target"
      arn       = aws_lambda_function.example.arn
    }
  ]

  # Auto-create IAM role for EventBridge to invoke Lambda
  create_role = true

  # Tags
  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Example     = "basic"
  }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "rule_arn" {
  description = "ARN of the EventBridge rule"
  value       = module.eventbridge.rule_arn
}

output "rule_name" {
  description = "Name of the EventBridge rule"
  value       = module.eventbridge.rule_name
}

output "role_arn" {
  description = "ARN of the IAM role created for EventBridge"
  value       = module.eventbridge.role_arn
}

output "target_arns" {
  description = "List of target ARNs"
  value       = module.eventbridge.target_arns
}
