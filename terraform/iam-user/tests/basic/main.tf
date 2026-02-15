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
