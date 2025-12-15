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

# Test the module with default configuration (ca-central-1 and ap-northeast-2)
module "test_default" {
  source = "../../"

  policy_name = "test-region-restriction-default"
  description = "Test SCP with default allowed regions"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
  }
}

# Test the module with custom regions
module "test_custom" {
  source = "../../"

  policy_name           = "test-region-restriction-custom"
  description           = "Test SCP with custom allowed regions"
  allowed_regions       = ["us-east-1", "us-west-2", "eu-west-1"]
  allow_global_services = true

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
  }
}

# Test the module without global services
module "test_no_global" {
  source = "../../"

  policy_name           = "test-region-restriction-no-global"
  description           = "Test SCP without global services exemption"
  allowed_regions       = ["ca-central-1", "ap-northeast-2"]
  allow_global_services = false

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
  }
}

# Outputs to verify module behavior
output "default_policy_id" {
  description = "Policy ID for default configuration"
  value       = module.test_default.policy_id
}

output "default_allowed_regions" {
  description = "Allowed regions for default configuration"
  value       = module.test_default.allowed_regions
}

output "custom_policy_id" {
  description = "Policy ID for custom configuration"
  value       = module.test_custom.policy_id
}

output "custom_allowed_regions" {
  description = "Allowed regions for custom configuration"
  value       = module.test_custom.allowed_regions
}

output "default_policy_content" {
  description = "Policy content for verification"
  value       = module.test_default.policy_content
}
