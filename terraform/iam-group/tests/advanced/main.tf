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
  access_key                  = "test"
  secret_key                  = "test"

  endpoints {
    iam = "http://localhost:4566"
  }
}

# Create test users to add to the group
resource "aws_iam_user" "test_users" {
  for_each = toset(["alice", "bob", "charlie"])

  name = each.value
  path = "/developers/"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
  }
}

# Create IAM group with inline policies and members
module "iam_group" {
  source = "../.."

  name = "developers"
  path = "/teams/"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]

  inline_policies = {
    s3-access = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:ListBucket"
          ]
          Resource = [
            "arn:aws:s3:::my-bucket",
            "arn:aws:s3:::my-bucket/*"
          ]
        }
      ]
    })

    dynamodb-access = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "dynamodb:GetItem",
            "dynamodb:Query",
            "dynamodb:Scan"
          ]
          Resource = "arn:aws:dynamodb:us-east-1:123456789012:table/my-table"
        }
      ]
    })
  }

  user_names = [for user in aws_iam_user.test_users : user.name]
}

output "group_name" {
  value = module.iam_group.group_name
}

output "group_arn" {
  value = module.iam_group.group_arn
}

output "inline_policy_names" {
  value = module.iam_group.inline_policy_names
}

output "member_user_names" {
  value = module.iam_group.member_user_names
}
