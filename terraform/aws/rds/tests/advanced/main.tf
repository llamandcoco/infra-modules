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

# IAM role for Enhanced Monitoring (mocked)
resource "aws_iam_role" "rds_monitoring" {
  name = "test-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

# Test the module with advanced PostgreSQL configuration
module "test_advanced" {
  source = "../../"

  # Required variables
  identifier        = "test-postgres-db"
  engine            = "postgres"
  engine_version    = "15.4"
  instance_class    = "db.r5.large"
  allocated_storage = 100

  # Storage autoscaling
  max_allocated_storage = 500
  storage_type          = "gp3"
  storage_throughput    = 250

  # Credentials
  master_username = "dbadmin"
  master_password = "SecurePassword123!"

  # Database name
  database_name = "production_db"

  # Network configuration
  vpc_id     = "vpc-12345678"
  subnet_ids = ["subnet-12345678", "subnet-87654321", "subnet-11111111"]

  # Security groups
  allowed_security_groups = {
    app_servers = "sg-app12345"
    bastion     = "sg-bastion67890"
  }

  # High availability
  multi_az = true

  # Security
  storage_encrypted = true
  kms_key_id        = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  # Enhanced backup configuration
  backup_retention_period = 30
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"
  copy_tags_to_snapshot   = true
  skip_final_snapshot     = false

  # Monitoring and logging
  enabled_cloudwatch_logs_exports       = ["postgresql", "upgrade"]
  monitoring_interval                   = 60
  monitoring_role_arn                   = aws_iam_role.rds_monitoring.arn
  performance_insights_enabled          = true
  performance_insights_retention_period = 731

  # Upgrade settings
  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false
  apply_immediately           = false

  # Deletion protection
  deletion_protection = true

  # IAM authentication
  iam_database_authentication_enabled = true

  # Read replicas
  read_replicas = {
    replica1 = {
      instance_class    = "db.r5.large"
      availability_zone = "us-east-1b"
    }
    replica2 = {
      instance_class    = "db.r5.xlarge"
      availability_zone = "us-east-1c"
      tags = {
        Replica = "primary-read"
      }
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    Team        = "platform"
  }
}

# Test outputs to verify module behavior
output "db_instance_endpoint" {
  value = module.test_advanced.db_instance_endpoint
}

output "db_instance_arn" {
  value = module.test_advanced.db_instance_arn
}

output "db_instance_id" {
  value = module.test_advanced.db_instance_id
}

output "db_instance_multi_az" {
  value = module.test_advanced.db_instance_multi_az
}

output "security_group_id" {
  value = module.test_advanced.security_group_id
}

output "db_instance_storage_encrypted" {
  value = module.test_advanced.db_instance_storage_encrypted
}

output "db_instance_performance_insights_enabled" {
  value = module.test_advanced.db_instance_performance_insights_enabled
}

output "read_replica_endpoints" {
  value = module.test_advanced.read_replica_endpoints
}

output "read_replica_ids" {
  value = module.test_advanced.read_replica_ids
}
