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

# Test Redis with high availability, encryption, and backups
module "test_advanced_redis" {
  source = "../../"

  cluster_id      = "test-redis-ha"
  engine          = "redis"
  node_type       = "cache.r6g.large"
  engine_version  = "7.0"
  num_cache_nodes = 3

  subnet_ids         = ["subnet-12345678", "subnet-87654321", "subnet-abcdef12"]
  security_group_ids = ["sg-12345678"]

  # High availability
  automatic_failover_enabled = true
  multi_az_enabled           = true

  # Security
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = "VerySecurePassword123456"
  kms_key_id                 = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  # Backups
  snapshot_retention_limit  = 7
  snapshot_window           = "03:00-05:00"
  final_snapshot_identifier = "test-redis-ha-final-snapshot"

  # Maintenance
  maintenance_window         = "sun:05:00-sun:09:00"
  auto_minor_version_upgrade = true

  # Custom parameters
  parameters = [
    {
      name  = "maxmemory-policy"
      value = "allkeys-lru"
    },
    {
      name  = "timeout"
      value = "300"
    }
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Purpose     = "advanced-testing"
    Compliance  = "encrypted"
  }
}

# Test Memcached cluster
module "test_memcached" {
  source = "../../"

  cluster_id             = "test-memcached"
  engine                 = "memcached"
  node_type              = "cache.t3.micro"
  engine_version         = "1.6.17"
  num_cache_nodes        = 2
  availability_zones     = ["us-east-1a", "us-east-1b"]
  parameter_group_family = "memcached1.6"

  subnet_ids         = ["subnet-12345678", "subnet-87654321"]
  security_group_ids = ["sg-12345678"]

  # Maintenance
  maintenance_window         = "mon:05:00-mon:07:00"
  auto_minor_version_upgrade = true

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "memcached-testing"
  }
}

# Test outputs for Redis HA
output "redis_ha_cluster_id" {
  value = module.test_advanced_redis.cluster_id
}

output "redis_ha_primary_endpoint" {
  value = module.test_advanced_redis.redis_primary_endpoint_address
}

output "redis_ha_reader_endpoint" {
  value = module.test_advanced_redis.redis_reader_endpoint_address
}

output "redis_ha_encryption_enabled" {
  value = {
    at_rest    = module.test_advanced_redis.at_rest_encryption_enabled
    in_transit = module.test_advanced_redis.transit_encryption_enabled
  }
}

# Test outputs for Memcached
output "memcached_cluster_id" {
  value = module.test_memcached.cluster_id
}

output "memcached_configuration_endpoint" {
  value = module.test_memcached.memcached_configuration_endpoint
}

output "memcached_cluster_address" {
  value = module.test_memcached.memcached_cluster_address
}
