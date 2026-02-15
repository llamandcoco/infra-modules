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

# Create a policy document using Terraform's data source
data "aws_iam_policy_document" "dynamodb_access" {
  statement {
    sid    = "DynamoDBReadWrite"
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]

    resources = [
      "arn:aws:dynamodb:us-east-1:123456789012:table/my-table",
      "arn:aws:dynamodb:us-east-1:123456789012:table/my-table/index/*"
    ]
  }

  statement {
    sid    = "DynamoDBList"
    effect = "Allow"

    actions = [
      "dynamodb:ListTables",
      "dynamodb:DescribeTable"
    ]

    resources = ["*"]
  }
}

module "iam_policy" {
  source = "../.."

  name        = "test-dynamodb-policy"
  description = "Test policy for DynamoDB access using policy document"
  policy      = data.aws_iam_policy_document.dynamodb_access.json

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Service     = "dynamodb"
  }
}

output "policy_arn" {
  value = module.iam_policy.policy_arn
}

output "policy_name" {
  value = module.iam_policy.policy_name
}
