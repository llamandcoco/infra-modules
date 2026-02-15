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

  # Mock configuration for testing - no real AWS credentials needed
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
  access_key                  = "test"
  secret_key                  = "test"
}

module "iam_group_policy_attachment" {
  source = "../.."

  group_name = "developers"
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

output "group_name" {
  value = module.iam_group_policy_attachment.group_name
}

output "policy_arn" {
  value = module.iam_group_policy_attachment.policy_arn
}
