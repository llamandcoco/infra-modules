terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Basic Lambda Test
# Tests minimal Lambda configuration with inline Python code
# Uses local zip deployment method
# -----------------------------------------------------------------------------

provider "aws" {
  region = "us-east-1"

  # Mock configuration for testing - no real AWS credentials needed for plan
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    lambda         = "http://localhost:4566"
    iam            = "http://localhost:4566"
    cloudwatchlogs = "http://localhost:4566"
  }
}

# Create a simple Python Lambda function inline
resource "local_file" "lambda_code" {
  filename = "${path.module}/lambda_function.py"
  content  = <<-EOT
    def handler(event, context):
        """
        Basic Lambda handler that returns a simple response.
        """
        return {
            'statusCode': 200,
            'body': 'Hello from Lambda!'
        }
  EOT
}

# Package the Lambda function into a zip file
data "archive_file" "lambda" {
  type        = "zip"
  source_file = local_file.lambda_code.filename
  output_path = "${path.module}/lambda.zip"
}

# Create Lambda function using the module with minimal configuration
module "lambda" {
  source = "../.."

  # Required variables
  function_name = "basic-test-lambda"
  runtime       = "python3.12"
  handler       = "lambda_function.handler"

  # Local deployment method
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  # Use defaults for all other variables
  # - timeout: 30 seconds (default)
  # - memory_size: 128 MB (default)
  # - log_retention_days: 7 days (default)
  # - create_cloudwatch_log_policy: true (default)

  tags = {
    Environment = "test"
    Purpose     = "basic-test"
  }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda.function_arn
}

output "function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda.function_name
}

output "role_arn" {
  description = "ARN of the IAM role"
  value       = module.lambda.role_arn
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = module.lambda.log_group_name
}
