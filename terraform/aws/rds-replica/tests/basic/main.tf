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

module "test_basic" {
  source = "../../"

  identifier           = "test-replica-db"
  source_db_identifier = "test-primary-db"
  instance_class       = "db.t3.micro"

  vpc_security_group_ids = ["sg-12345678"]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
  }
}

output "replica_id" {
  value = module.test_basic.id
}

output "replica_arn" {
  value = module.test_basic.arn
}

output "replica_endpoint" {
  value = module.test_basic.endpoint
}
