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
# Python Lambda Test
# Tests Python 3.12 runtime with S3 deployment method
# Demonstrates environment variables and custom configuration
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
    s3             = "http://localhost:4566"
  }
}

# Create Lambda function using S3 deployment method
# This demonstrates how you would deploy in production via CI/CD
module "lambda_python" {
  source = "../.."

  # Required variables
  function_name = "python-s3-test-lambda"
  runtime       = "python3.12"
  handler       = "app.lambda_handler"

  # S3 deployment method
  # In production, your CI/CD pipeline would upload the zip to S3
  s3_bucket         = "my-lambda-deployments"
  s3_key            = "functions/python-app/v1.0.0/lambda.zip"
  s3_object_version = "abc123"

  # Function configuration
  description  = "Python Lambda function deployed from S3"
  timeout      = 60
  memory_size  = 256

  # Environment variables
  # These are encrypted at rest using AWS managed keys
  environment_variables = {
    ENVIRONMENT     = "production"
    LOG_LEVEL       = "INFO"
    API_ENDPOINT    = "https://api.example.com"
    TABLE_NAME      = "my-dynamodb-table"
    CACHE_TTL       = "300"
  }

  # CloudWatch Logs configuration
  log_retention_days = 14

  # Additional IAM permissions
  # Example: Grant access to DynamoDB and S3
  additional_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  tags = {
    Environment = "production"
    Application = "python-app"
    ManagedBy   = "terraform"
    CostCenter  = "engineering"
  }
}

# -----------------------------------------------------------------------------
# Example Lambda Function Code
# -----------------------------------------------------------------------------

# This is what your app.py would look like:
#
# import json
# import os
# import boto3
# import logging
#
# # Configure logging
# logger = logging.getLogger()
# logger.setLevel(os.environ.get('LOG_LEVEL', 'INFO'))
#
# # Initialize AWS clients
# dynamodb = boto3.resource('dynamodb')
# s3 = boto3.client('s3')
#
# def lambda_handler(event, context):
#     """
#     Process incoming events and interact with AWS services.
#     """
#     logger.info(f"Processing event: {json.dumps(event)}")
#
#     table_name = os.environ['TABLE_NAME']
#     table = dynamodb.Table(table_name)
#
#     # Your business logic here
#     # ...
#
#     return {
#         'statusCode': 200,
#         'body': json.dumps({
#             'message': 'Success',
#             'environment': os.environ['ENVIRONMENT']
#         })
#     }

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda_python.function_arn
}

output "invoke_arn" {
  description = "Invoke ARN for API Gateway integration"
  value       = module.lambda_python.invoke_arn
}

output "role_name" {
  description = "Name of the IAM execution role"
  value       = module.lambda_python.role_name
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = module.lambda_python.log_group_name
}
