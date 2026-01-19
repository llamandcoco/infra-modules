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

module "instance_profile" {
  source = "../.."

  name = "my-app"

  # Enable built-in policies
  enable_ecr                 = true
  enable_ssm                 = true
  enable_ssm_session_manager = true
  enable_cw_logs             = true
  enable_cw_agent            = true

  # S3 and KMS support
  s3_log_buckets = [
    "arn:aws:s3:::my-log-bucket"
  ]
  kms_key_arns = [
    "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  ]

  # Attach additional managed policies
  additional_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  # Add custom inline policies
  custom_policy_statements = [
    {
      sid = "DynamoDBAccess"
      actions = [
        "dynamodb:GetItem",
        "dynamodb:Query"
      ]
      resources = ["arn:aws:dynamodb:us-east-1:123456789012:table/my-table"]
    }
  ]

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}
