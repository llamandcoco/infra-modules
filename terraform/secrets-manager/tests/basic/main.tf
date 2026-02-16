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

# Test the module with multiple secrets
module "test_secrets" {
  source = "../../"

  secrets = {
    # Database credentials with rotation
    "production/database/main" = {
      secret_string = jsonencode({
        username = "admin"
        password = "super-secret-password-123"
        host     = "db.example.com"
        port     = 5432
      })
      description         = "Main database credentials for production"
      kms_key_id          = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
      rotation_enabled    = true
      rotation_lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:SecretsManagerRotation"
      rotation_days       = 30
      tags = {
        Purpose     = "database-credentials"
        Environment = "production"
      }
    }

    # API key without rotation
    "production/api/external-service" = {
      secret_string = "api-key-xyz-789"
      description   = "API key for external service integration"
      tags = {
        Purpose = "api-credentials"
      }
    }

    # JSON configuration secret
    "production/app/config" = {
      secret_string = jsonencode({
        api_url      = "https://api.example.com"
        timeout      = 30
        max_retries  = 3
        feature_flag = true
      })
      description = "Application configuration settings"
      tags = {
        Purpose = "configuration"
      }
    }

    # Secret with custom recovery window
    "staging/database/backup" = {
      secret_string           = "backup-credentials-456"
      description             = "Backup database credentials for staging"
      recovery_window_in_days = 7
      tags = {
        Purpose     = "backup-credentials"
        Environment = "staging"
      }
    }

    # OAuth credentials
    "production/oauth/client" = {
      secret_string = jsonencode({
        client_id     = "oauth-client-id-123"
        client_secret = "oauth-client-secret-456"
        redirect_uri  = "https://app.example.com/callback"
      })
      description = "OAuth client credentials"
      tags = {
        Purpose = "oauth-credentials"
      }
    }
  }

  # Common tags applied to all secrets
  common_tags = {
    ManagedBy = "terraform"
    Team      = "platform"
    Service   = "secrets-manager-test"
  }

  # Default values for secrets that don't specify them
  default_kms_key_id              = null
  default_recovery_window_in_days = 30
  default_rotation_days           = 30
}

# Test outputs to verify module behavior
output "all_secret_ids" {
  description = "Map of all secret IDs"
  value       = module.test_secrets.secret_ids
}

output "all_secret_arns" {
  description = "Map of all secret ARNs"
  value       = module.test_secrets.secret_arns
}

output "all_secret_versions" {
  description = "Map of all secret version IDs"
  value       = module.test_secrets.secret_versions
}

output "secrets_details" {
  description = "Complete details of all secrets"
  value       = module.test_secrets.secrets
}
