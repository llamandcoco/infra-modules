terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Basic Cognito Test
# Tests minimal Cognito configuration with:
# - User pool with email sign-in
# - Basic password policy
# - One user pool client
# - Optional MFA
# -----------------------------------------------------------------------------

provider "aws" {
  region = "us-east-1"

  # Mock configuration for testing - no real AWS credentials needed for plan
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    cognitoidentity = "http://localhost:4566"
    cognitoidp      = "http://localhost:4566"
    iam             = "http://localhost:4566"
    sts             = "http://localhost:4566"
  }
}

# Create basic Cognito user pool
module "cognito" {
  source = "../.."

  # User pool configuration
  user_pool_name = "basic-user-pool"

  # Email-based sign-in
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Basic password policy (use defaults)
  # - minimum_length: 8
  # - require_lowercase: true
  # - require_uppercase: true
  # - require_numbers: true
  # - require_symbols: true

  # Optional MFA
  mfa_configuration = "OPTIONAL"

  # Account recovery via email
  account_recovery_mechanisms = [
    {
      name     = "verified_email"
      priority = 1
    }
  ]

  # User pool client for web application
  user_pool_clients = [
    {
      name = "web-client"
      explicit_auth_flows = [
        "ALLOW_USER_SRP_AUTH",
        "ALLOW_REFRESH_TOKEN_AUTH"
      ]
    }
  ]

  tags = {
    Environment = "test"
    Purpose     = "basic-cognito-test"
  }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "user_pool_id" {
  description = "ID of the user pool"
  value       = module.cognito.user_pool_id
}

output "user_pool_arn" {
  description = "ARN of the user pool"
  value       = module.cognito.user_pool_arn
}

output "user_pool_endpoint" {
  description = "Endpoint of the user pool"
  value       = module.cognito.user_pool_endpoint
}

output "client_ids" {
  description = "User pool client IDs"
  value       = module.cognito.user_pool_client_ids
}

output "region" {
  description = "AWS region"
  value       = module.cognito.region
}

output "authentication_example" {
  description = "Example authentication code"
  value       = module.cognito.boto3_authentication_example
}
