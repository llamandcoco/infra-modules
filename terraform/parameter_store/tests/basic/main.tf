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

# Test the module with basic SecureString configuration
module "test_secure_string" {
  source = "../../"

  parameter_name = "/app/production/database/password"
  value          = "super-secret-password-123"
  type           = "SecureString"
  description    = "Database password for production environment"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Purpose     = "database-credentials"
  }
}

# Test the module with custom KMS key
module "test_custom_kms" {
  source = "../../"

  parameter_name = "/app/production/api/key"
  value          = "api-key-value-xyz"
  type           = "SecureString"
  kms_key_id     = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  description    = "API key encrypted with custom KMS key"
  tier           = "Standard"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Purpose     = "api-credentials"
  }
}

# Test the module with String type (non-encrypted)
module "test_string" {
  source = "../../"

  parameter_name = "/app/production/config/endpoint"
  value          = "https://api.example.com"
  type           = "String"
  description    = "API endpoint URL (non-sensitive)"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Purpose     = "configuration"
  }
}

# Test the module with StringList type
module "test_string_list" {
  source = "../../"

  parameter_name = "/app/production/config/allowed-ips"
  value          = "10.0.0.1,10.0.0.2,10.0.0.3"
  type           = "StringList"
  description    = "List of allowed IP addresses"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Purpose     = "security-config"
  }
}

# Test outputs to verify module behavior
output "secure_string_arn" {
  description = "ARN of the SecureString parameter"
  value       = module.test_secure_string.parameter_arn
}

output "secure_string_version" {
  description = "Version of the SecureString parameter"
  value       = module.test_secure_string.parameter_version
}

output "string_parameter_name" {
  description = "Name of the String parameter"
  value       = module.test_string.parameter_name
}

output "string_list_type" {
  description = "Type of the StringList parameter"
  value       = module.test_string_list.parameter_type
}
