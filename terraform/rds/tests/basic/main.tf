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

# Test the module with basic MySQL configuration
module "test_basic" {
  source = "../../"

  # Required variables
  identifier        = "test-mysql-db"
  engine            = "mysql"
  engine_version    = "8.0.35"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  # Credentials
  master_username = "admin"
  master_password = "TestPassword123!"

  # Database name
  database_name = "myapp"

  # Network configuration
  vpc_id     = "vpc-12345678"
  subnet_ids = ["subnet-12345678", "subnet-87654321"]

  # Security
  storage_encrypted = true

  # Backup configuration
  backup_retention_period = 7
  skip_final_snapshot     = true

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
  }
}

# Test outputs to verify module behavior
output "db_instance_endpoint" {
  value = module.test_basic.db_instance_endpoint
}

output "db_instance_arn" {
  value = module.test_basic.db_instance_arn
}

output "db_instance_id" {
  value = module.test_basic.db_instance_id
}

output "security_group_id" {
  value = module.test_basic.security_group_id
}

output "db_instance_storage_encrypted" {
  value = module.test_basic.db_instance_storage_encrypted
}
