terraform {
  required_version = ">= 1.3.0"
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
  skip_region_validation      = true
  access_key                  = "test"
  secret_key                  = "test"
}

module "iam_group_policy" {
  source = "../.."

  name = "test-power-users"
  path = "/engineering/"

  # Enable multiple built-in policies
  enable_s3_read        = true
  enable_s3_write       = true
  enable_ec2_read       = true
  enable_dynamodb_read  = true
  enable_dynamodb_write = true
  enable_logs_read      = true
  enable_ssm_read       = true

  # Attach AWS managed policies
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]

  # Add custom inline policies
  custom_policy_statements = [
    {
      sid = "AllowAssumeRole"
      actions = [
        "sts:AssumeRole"
      ]
      resources = [
        "arn:aws:iam::123456789012:role/DevRole"
      ]
    },
    {
      sid = "AllowKMSDecrypt"
      actions = [
        "kms:Decrypt",
        "kms:DescribeKey"
      ]
      resources = [
        "arn:aws:kms:us-east-1:123456789012:key/*"
      ]
    }
  ]

  # Add users to group
  users = [
    "john.doe",
    "jane.smith"
  ]
}

output "group_name" {
  value = module.iam_group_policy.group_name
}

output "group_arn" {
  value = module.iam_group_policy.group_arn
}

output "inline_policy_names" {
  value = module.iam_group_policy.inline_policy_names
}

output "managed_policy_arns" {
  value = module.iam_group_policy.managed_policy_arns
}

output "users" {
  value = module.iam_group_policy.users
}
