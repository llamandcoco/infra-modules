terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Mock AWS provider for testing without credentials
provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  access_key = "test"
  secret_key = "test"
}

module "test_keda_iam_role" {
  source = "../../"

  role_name         = "test-keda-role"
  oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B716D3041E"
  oidc_provider     = "oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B716D3041E"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
  }
}

output "role_arn" {
  description = "ARN of the KEDA IAM role"
  value       = module.test_keda_iam_role.role_arn
}

output "role_name" {
  description = "Name of the KEDA IAM role"
  value       = module.test_keda_iam_role.role_name
}

output "policy_arn" {
  description = "ARN of the KEDA IAM policy"
  value       = module.test_keda_iam_role.policy_arn
}
