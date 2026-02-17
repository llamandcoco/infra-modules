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

# Test the module with basic Redis configuration
module "test_basic_redis" {
  source = "../../"

  cluster_id         = "test-redis-cluster"
  engine             = "redis"
  node_type          = "cache.t3.micro"
  engine_version     = "7.0"
  num_cache_nodes    = 1
  subnet_ids         = ["subnet-12345678", "subnet-87654321"]
  security_group_ids = ["sg-12345678"]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
  }
}

# Test outputs
output "redis_cluster_id" {
  value = module.test_basic_redis.cluster_id
}

output "redis_primary_endpoint" {
  value = module.test_basic_redis.redis_primary_endpoint_address
}

output "redis_port" {
  value = module.test_basic_redis.port
}
