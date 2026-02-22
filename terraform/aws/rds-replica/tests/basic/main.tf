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

# Test the module with a basic read replica configuration
module "test_rds_replica" {
  source = "../../"

  # Required variables
  identifier                    = "test-mysql-replica"
  source_db_instance_identifier = "test-mysql-primary"
  instance_class                = "db.t3.micro"

  # Network configuration
  vpc_id = "vpc-12345678"

  # Storage
  storage_type = "gp3"

  # Deletion settings for testing
  skip_final_snapshot = true

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
  }
}

# Test outputs to verify module behavior
output "db_instance_endpoint" {
  value = module.test_rds_replica.db_instance_endpoint
}

output "db_instance_arn" {
  value = module.test_rds_replica.db_instance_arn
}

output "db_instance_id" {
  value = module.test_rds_replica.db_instance_id
}

output "security_group_id" {
  value = module.test_rds_replica.security_group_id
}

output "db_instance_storage_encrypted" {
  value = module.test_rds_replica.db_instance_storage_encrypted
}
