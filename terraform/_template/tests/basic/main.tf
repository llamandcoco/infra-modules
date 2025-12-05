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

# Test the module with basic configuration
module "test" {
  source = "../../"

  resource_name = "test-resource"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
  }
}

# TODO: Add outputs to verify module behavior
# output "test_output" {
#   value = module.test.resource_id
# }
