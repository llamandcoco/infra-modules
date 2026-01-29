terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  token                       = "mock_token"
  skip_credentials_validation = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

module "task_role" {
  source = "../.."

  name = "test-task-role"

  enable_s3_access = true
  s3_bucket_arns   = ["arn:aws:s3:::test-bucket"]

  enable_dynamodb_access = true
  dynamodb_table_arns    = ["arn:aws:dynamodb:us-east-1:123456789012:table/TestTable"]

  enable_sqs_access = true
  sqs_queue_arns    = ["arn:aws:sqs:us-east-1:123456789012:test-queue"]

  enable_secrets_manager = true
  secret_arns            = ["arn:aws:secretsmanager:us-east-1:123456789012:secret:test-secret"]

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
  ]

  inline_policies = {
    custom_logs = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "logs:DescribeLogGroups"
          ]
          Resource = "*"
        }
      ]
    })
  }

  tags = {
    Environment = "test"
  }
}
