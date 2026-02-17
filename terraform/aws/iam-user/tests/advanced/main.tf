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

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
  access_key                  = "test"
  secret_key                  = "test"
}

module "iam_user_advanced" {
  source = "../.."

  name          = "advanced-user"
  path          = "/automation/"
  force_destroy = true

  # Create programmatic access
  create_access_key = true

  # Create console access
  create_login_profile    = true
  pgp_key                 = "keybase:test-user"
  password_reset_required = true

  # Attach managed policies
  policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
  ]

  # Add custom inline policies
  custom_policy_statements = [
    {
      sid    = "S3BucketAccess"
      effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      resources = [
        "arn:aws:s3:::my-bucket",
        "arn:aws:s3:::my-bucket/*"
      ]
    },
    {
      sid    = "DynamoDBAccess"
      effect = "Allow"
      actions = [
        "dynamodb:GetItem",
        "dynamodb:Query"
      ]
      resources = [
        "arn:aws:dynamodb:us-east-1:123456789012:table/my-table"
      ]
    }
  ]

  # Add to groups
  group_names = ["developers", "readonly-users"]

  tags = {
    Environment = "production"
    Team        = "platform"
    ManagedBy   = "terraform"
  }
}

output "user_name" {
  value = module.iam_user_advanced.user_name
}

output "user_arn" {
  value = module.iam_user_advanced.user_arn
}

output "access_key_id" {
  value = module.iam_user_advanced.access_key_id
}

output "attached_policies" {
  value = module.iam_user_advanced.attached_policy_arns
}

output "inline_policies" {
  value = module.iam_user_advanced.inline_policy_names
}
