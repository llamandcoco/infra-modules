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

# Test the module with multiple parameters
module "test_parameters" {
  source = "../../"

  parameters = {
    # SecureString with default KMS key
    "/app/production/database/password" = {
      value       = "super-secret-password-123"
      type        = "SecureString"
      description = "Database password for production environment"
      tags = {
        Purpose = "database-credentials"
      }
    }

    # SecureString with custom KMS key
    "/app/production/api/key" = {
      value       = "api-key-value-xyz"
      type        = "SecureString"
      kms_key_id  = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
      description = "API key encrypted with custom KMS key"
      tags = {
        Purpose = "api-credentials"
      }
    }

    # String type (non-encrypted)
    "/app/production/config/endpoint" = {
      value       = "https://api.example.com"
      type        = "String"
      description = "API endpoint URL (non-sensitive)"
      tags = {
        Purpose = "configuration"
      }
    }

    # StringList type
    "/app/production/config/allowed-ips" = {
      value       = "10.0.0.1,10.0.0.2,10.0.0.3"
      type        = "StringList"
      description = "List of allowed IP addresses"
      tags = {
        Purpose = "security-config"
      }
    }

    # Parameter with Advanced tier
    "/app/production/large-config" = {
      value       = "large-configuration-data-that-exceeds-4kb-limit"
      type        = "String"
      tier        = "Advanced"
      description = "Large configuration data (Advanced tier)"
    }
  }

  # Common tags applied to all parameters
  common_tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Team        = "platform"
  }

  # Default values for parameters that don't specify them
  default_type      = "SecureString"
  default_tier      = "Standard"
  default_overwrite = true
}

# Test outputs to verify module behavior
output "all_parameter_names" {
  description = "Map of all parameter names"
  value       = module.test_parameters.parameter_names
}

output "all_parameter_arns" {
  description = "Map of all parameter ARNs"
  value       = module.test_parameters.parameter_arns
}

output "all_parameter_versions" {
  description = "Map of all parameter versions"
  value       = module.test_parameters.parameter_versions
}

output "parameters_details" {
  description = "Complete details of all parameters"
  value       = module.test_parameters.parameters
}
