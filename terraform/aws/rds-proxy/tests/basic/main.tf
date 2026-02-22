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

# Test the module with a basic MySQL RDS Proxy configuration
module "test_basic" {
  source = "../../"

  name          = "test-mysql-proxy"
  engine_family = "MYSQL"
  role_arn      = "arn:aws:iam::123456789012:role/rds-proxy-role"

  auth = [
    {
      auth_scheme = "SECRETS"
      iam_auth    = "DISABLED"
      secret_arn  = "arn:aws:secretsmanager:us-east-1:123456789012:secret:myapp/db-credentials"
    }
  ]

  # Network configuration
  vpc_id         = "vpc-12345678"
  vpc_subnet_ids = ["subnet-12345678", "subnet-87654321"]
  port           = 3306

  # Connection pool settings
  max_connections_percent      = 100
  max_idle_connections_percent = 50
  connection_borrow_timeout    = 120

  # Target RDS instance
  target_db_instance_identifier = "myapp-mysql-db"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
  }
}

# Test outputs to verify module behavior
output "proxy_endpoint" {
  value = module.test_basic.proxy_endpoint
}

output "proxy_arn" {
  value = module.test_basic.proxy_arn
}

output "proxy_name" {
  value = module.test_basic.proxy_name
}

output "security_group_id" {
  value = module.test_basic.security_group_id
}

output "target_group_name" {
  value = module.test_basic.target_group_name
}
