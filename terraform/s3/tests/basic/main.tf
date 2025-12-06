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
# This allows terraform plan to run without requiring AWS credentials
provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  access_key = "test"
  secret_key = "test"
}

# Test the S3 module with minimal required configuration
# This test uses default values for most settings, which implement security best practices
module "test_basic" {
  source = "../../"

  bucket_name = "test-s3-module-basic-12345"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
  }
}

# Test the module with custom encryption (KMS)
module "test_kms" {
  source = "../../"

  bucket_name       = "test-s3-module-kms-67890"
  encryption_type   = "aws:kms"
  kms_master_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing-kms"
  }
}

# Test the module with lifecycle rules
module "test_lifecycle" {
  source = "../../"

  bucket_name = "test-s3-module-lifecycle-11111"

  lifecycle_rules = [
    {
      id      = "test-archive-rule"
      enabled = true

      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]

      expiration = {
        days = 365
      }
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing-lifecycle"
  }
}

# Output the bucket details for verification
output "basic_bucket_id" {
  description = "ID of the basic test bucket"
  value       = module.test_basic.bucket_id
}

output "basic_bucket_arn" {
  description = "ARN of the basic test bucket"
  value       = module.test_basic.bucket_arn
}

output "kms_bucket_id" {
  description = "ID of the KMS test bucket"
  value       = module.test_kms.bucket_id
}

output "lifecycle_bucket_id" {
  description = "ID of the lifecycle test bucket"
  value       = module.test_lifecycle.bucket_id
}
