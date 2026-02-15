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

# Test the module with MySQL engine and MEMCACHED option
module "test_mysql_memcached" {
  source = "../../"

  name                 = "mysql-memcached-option-group"
  engine_name          = "mysql"
  major_engine_version = "8.0"
  description          = "MySQL 8.0 option group with MEMCACHED"

  options = [
    {
      option_name                    = "MEMCACHED"
      port                           = 11211
      vpc_security_group_memberships = ["sg-12345678"]
      option_settings = [
        {
          name  = "CHUNK_SIZE"
          value = "32"
        },
        {
          name  = "BINDING_PROTOCOL"
          value = "ascii"
        }
      ]
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "testing"
  }
}

# Test the module with Oracle engine and multiple options
module "test_oracle_options" {
  source = "../../"

  name                 = "oracle-ee-option-group"
  engine_name          = "oracle-ee"
  major_engine_version = "19"
  description          = "Oracle Enterprise Edition 19c option group"

  options = [
    {
      option_name = "NATIVE_NETWORK_ENCRYPTION"
      option_settings = [
        {
          name  = "SQLNET.ENCRYPTION_SERVER"
          value = "REQUIRED"
        },
        {
          name  = "SQLNET.ENCRYPTION_TYPES_SERVER"
          value = "AES256,AES192,AES128"
        }
      ]
    },
    {
      option_name = "OEM"
      port        = 1158
      option_settings = [
        {
          name  = "OMS_PORT"
          value = "1158"
        }
      ]
    }
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Database    = "oracle"
  }
}

# Test the module with SQL Server and basic configuration
module "test_sqlserver_basic" {
  source = "../../"

  name                 = "sqlserver-ee-option-group"
  engine_name          = "sqlserver-ee"
  major_engine_version = "15.00"
  description          = "SQL Server Enterprise Edition option group"

  tags = {
    Environment = "development"
    ManagedBy   = "terraform"
  }
}

# Test outputs to verify module behavior
output "mysql_option_group_id" {
  description = "ID of the MySQL option group"
  value       = module.test_mysql_memcached.id
}

output "mysql_option_group_arn" {
  description = "ARN of the MySQL option group"
  value       = module.test_mysql_memcached.arn
}

output "oracle_option_group_details" {
  description = "Complete details of Oracle option group"
  value       = module.test_oracle_options.option_group
}

output "sqlserver_option_group_name" {
  description = "Name of the SQL Server option group"
  value       = module.test_sqlserver_basic.name
}
