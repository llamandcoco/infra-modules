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
# Advanced Cognito Test
# Tests comprehensive Cognito configuration with:
# - User pool with custom attributes
# - Identity pool for AWS credentials
# - Multiple user pool clients (web, mobile)
# - Hosted UI domain
# - Advanced security features
# - OAuth 2.0 flows
# -----------------------------------------------------------------------------

provider "aws" {
  region = "us-west-2"

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

# Create advanced Cognito user pool
module "cognito" {
  source = "../.."

  # User pool configuration
  user_pool_name = "advanced-user-pool"

  # Email-based sign-in
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  username_case_sensitive  = false

  # Strong password policy
  password_minimum_length      = 12
  password_require_lowercase   = true
  password_require_uppercase   = true
  password_require_numbers     = true
  password_require_symbols     = true
  temporary_password_validity_days = 3

  # Required MFA
  mfa_configuration = "ON"

  # Account recovery mechanisms
  account_recovery_mechanisms = [
    {
      name     = "verified_email"
      priority = 1
    },
    {
      name     = "verified_phone_number"
      priority = 2
    }
  ]

  # Advanced security features
  enable_advanced_security = true
  advanced_security_mode   = "ENFORCED"

  # Device tracking
  device_tracking = {
    challenge_required_on_new_device      = true
    device_only_remembered_on_user_prompt = true
  }

  # Custom attributes
  schema_attributes = [
    {
      name                = "tenant_id"
      attribute_data_type = "String"
      mutable             = false
      required            = false
      min_length          = 1
      max_length          = 256
    },
    {
      name                = "subscription_tier"
      attribute_data_type = "String"
      mutable             = true
      required            = false
      min_length          = 1
      max_length          = 50
    },
    {
      name                = "onboarding_completed"
      attribute_data_type = "Boolean"
      mutable             = true
      required            = false
    }
  ]

  # User pool clients
  user_pool_clients = [
    {
      name = "web-client"

      # OAuth configuration for hosted UI
      allowed_oauth_flows = [
        "code",
        "implicit"
      ]
      allowed_oauth_scopes = [
        "email",
        "openid",
        "profile"
      ]
      allowed_oauth_flows_user_pool_client = true

      callback_urls = [
        "https://app.example.com/callback",
        "http://localhost:3000/callback"
      ]
      logout_urls = [
        "https://app.example.com/logout",
        "http://localhost:3000/logout"
      ]

      supported_identity_providers = ["COGNITO"]

      # Token validity
      access_token_validity       = 60
      id_token_validity           = 60
      refresh_token_validity      = 30
      access_token_validity_unit  = "minutes"
      id_token_validity_unit      = "minutes"
      refresh_token_validity_unit = "days"

      # Auth flows
      explicit_auth_flows = [
        "ALLOW_USER_SRP_AUTH",
        "ALLOW_REFRESH_TOKEN_AUTH"
      ]

      prevent_user_existence_errors = "ENABLED"
      enable_token_revocation       = true
      server_side_token_check       = true
    },
    {
      name = "mobile-client"

      # Mobile-specific configuration
      generate_secret = false

      # Token validity - longer refresh for mobile
      access_token_validity       = 60
      id_token_validity           = 60
      refresh_token_validity      = 90
      access_token_validity_unit  = "minutes"
      id_token_validity_unit      = "minutes"
      refresh_token_validity_unit = "days"

      # Auth flows for mobile
      explicit_auth_flows = [
        "ALLOW_USER_SRP_AUTH",
        "ALLOW_REFRESH_TOKEN_AUTH",
        "ALLOW_CUSTOM_AUTH"
      ]

      enable_token_revocation = true
      server_side_token_check = false
    },
    {
      name = "backend-service"

      # Service-to-service authentication
      generate_secret = true

      # Token validity
      access_token_validity       = 60
      id_token_validity           = 60
      refresh_token_validity      = 30
      access_token_validity_unit  = "minutes"
      id_token_validity_unit      = "minutes"
      refresh_token_validity_unit = "days"

      # Auth flows
      explicit_auth_flows = [
        "ALLOW_USER_PASSWORD_AUTH",
        "ALLOW_REFRESH_TOKEN_AUTH"
      ]

      server_side_token_check = true
    }
  ]

  # Hosted UI domain
  user_pool_domain = "advanced-user-pool-${data.aws_caller_identity.current.account_id}"

  # Identity pool for AWS credentials
  create_identity_pool             = true
  identity_pool_name               = "advanced-identity-pool"
  allow_unauthenticated_identities = false
  allow_classic_flow               = false

  # IAM policies for authenticated users
  authenticated_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  # Deletion protection
  deletion_protection = "ACTIVE"

  tags = {
    Environment = "production"
    Purpose     = "advanced-cognito-test"
    Team        = "platform"
    CostCenter  = "engineering"
  }
}

# Data source for account ID
data "aws_caller_identity" "current" {}

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

output "hosted_ui_url" {
  description = "Hosted UI URL"
  value       = module.cognito.hosted_ui_url
}

output "identity_pool_id" {
  description = "Identity pool ID"
  value       = module.cognito.identity_pool_id
}

output "authenticated_role_arn" {
  description = "Authenticated role ARN"
  value       = module.cognito.authenticated_role_arn
}

output "region" {
  description = "AWS region"
  value       = module.cognito.region
}

output "authentication_example" {
  description = "Example authentication code"
  value       = module.cognito.boto3_authentication_example
}

output "identity_pool_credentials_example" {
  description = "Example code for getting AWS credentials"
  value       = module.cognito.identity_pool_credentials_example
}

output "javascript_auth_example" {
  description = "JavaScript authentication example"
  value       = module.cognito.javascript_authentication_example
}
