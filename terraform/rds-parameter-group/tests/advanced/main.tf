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

# Test the module with advanced PostgreSQL 15 parameter group with custom settings
module "test_advanced" {
  source = "../../"

  name        = "test-postgres-params-advanced"
  family      = "postgres15"
  description = "Advanced PostgreSQL 15 parameter group with performance tuning"

  parameters = [
    {
      name  = "max_connections"
      value = "500"
    },
    {
      name  = "shared_buffers"
      value = "262144"
    },
    {
      name  = "effective_cache_size"
      value = "524288"
    },
    {
      name  = "maintenance_work_mem"
      value = "524288"
    },
    {
      name  = "work_mem"
      value = "32768"
    },
    {
      name  = "log_statement"
      value = "all"
    },
    {
      name         = "rds.force_ssl"
      value        = "1"
      apply_method = "pending-reboot"
    },
    {
      name  = "log_min_duration_statement"
      value = "1000"
    }
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Purpose     = "performance-tuned"
    Database    = "postgresql"
  }
}

# Test output to verify module behavior
output "parameter_group_id" {
  value = module.test_advanced.id
}

output "parameter_group_arn" {
  value = module.test_advanced.arn
}

output "parameter_group_name" {
  value = module.test_advanced.name
}

output "parameter_group_family" {
  value = module.test_advanced.family
}

output "parameter_group_description" {
  value = module.test_advanced.description
}
