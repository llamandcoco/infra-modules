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

# Test the module with basic MySQL 8.0 parameter group
module "test_basic" {
  source = "../../"

  name        = "test-mysql-params"
  family      = "mysql8.0"
  description = "Basic MySQL 8.0 parameter group for testing"

  parameters = [
    {
      name  = "max_connections"
      value = "200"
    },
    {
      name  = "slow_query_log"
      value = "1"
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
  }
}

# Test output to verify module behavior
output "parameter_group_id" {
  value = module.test_basic.id
}

output "parameter_group_arn" {
  value = module.test_basic.arn
}

output "parameter_group_name" {
  value = module.test_basic.name
}

output "parameter_group_family" {
  value = module.test_basic.family
}
