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

module "iam_user" {
  source = "../.."

  name = "test-user"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
  }
}

output "user_name" {
  value = module.iam_user.user_name
}

output "user_arn" {
  value = module.iam_user.user_arn
}
