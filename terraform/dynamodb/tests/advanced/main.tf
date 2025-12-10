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

# Advanced test: PROVISIONED mode with GSI, LSI, Streams, TTL, and Auto Scaling
module "test_advanced" {
  source = "../../"

  table_name   = "test-advanced-table"
  hash_key     = "user_id"
  range_key    = "timestamp"
  billing_mode = "PROVISIONED"

  # Provisioned capacity
  read_capacity  = 10
  write_capacity = 10

  # Enable auto-scaling
  enable_autoscaling             = true
  autoscaling_read_min_capacity  = 10
  autoscaling_read_max_capacity  = 50
  autoscaling_write_min_capacity = 10
  autoscaling_write_max_capacity = 50

  # Additional attributes for indexes
  attributes = [
    {
      name = "email"
      type = "S"
    },
    {
      name = "status"
      type = "S"
    },
    {
      name = "created_date"
      type = "S"
    }
  ]

  # Global Secondary Index
  global_secondary_indexes = [
    {
      name            = "email-index"
      hash_key        = "email"
      projection_type = "ALL"
      read_capacity   = 5
      write_capacity  = 5
    },
    {
      name               = "status-created-index"
      hash_key           = "status"
      range_key          = "created_date"
      projection_type    = "INCLUDE"
      non_key_attributes = ["email"]
      read_capacity      = 5
      write_capacity     = 5
    }
  ]

  # Local Secondary Index
  local_secondary_indexes = [
    {
      name            = "status-index"
      range_key       = "status"
      projection_type = "KEYS_ONLY"
    }
  ]

  # Enable DynamoDB Streams
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  # Enable TTL
  ttl_enabled        = true
  ttl_attribute_name = "expires_at"

  # Point-in-time recovery
  point_in_time_recovery_enabled = true

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "advanced-module-testing"
    TestType    = "provisioned-with-indexes-and-streams"
  }
}

# Test outputs
output "table_name" {
  value = module.test_advanced.table_name
}

output "table_arn" {
  value = module.test_advanced.table_arn
}

output "stream_enabled" {
  value = module.test_advanced.stream_enabled
}

output "stream_arn" {
  value = module.test_advanced.stream_arn
}

output "global_secondary_indexes" {
  value = module.test_advanced.global_secondary_indexes
}

output "local_secondary_indexes" {
  value = module.test_advanced.local_secondary_indexes
}

output "autoscaling_enabled" {
  value = module.test_advanced.autoscaling_enabled
}

output "ttl_enabled" {
  value = module.test_advanced.ttl_enabled
}

output "ttl_attribute_name" {
  value = module.test_advanced.ttl_attribute_name
}
