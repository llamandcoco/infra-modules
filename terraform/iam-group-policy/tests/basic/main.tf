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

  endpoints {
    iam = "http://localhost:4566"
  }
}

module "iam_group_policy" {
  source = "../.."

  name = "test-developers"

  enable_s3_read   = true
  enable_ec2_read  = true
  enable_logs_read = true
  enable_ssm_read  = true
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
