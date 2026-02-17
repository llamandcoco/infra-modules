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

# Test the module with basic PAY_PER_REQUEST configuration
module "test_basic" {
  source = "../../"

  table_name = "test-dynamodb-table"
  hash_key   = "id"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
  }
}

# Test output to verify module behavior
output "table_name" {
  value = module.test_basic.table_name
}

output "table_arn" {
  value = module.test_basic.table_arn
}

output "stream_enabled" {
  value = module.test_basic.stream_enabled
}

output "point_in_time_recovery_enabled" {
  value = module.test_basic.point_in_time_recovery_enabled
}
