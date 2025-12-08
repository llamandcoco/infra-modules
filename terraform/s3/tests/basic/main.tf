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

# -----------------------------------------------------------------------------
# Test 1: Basic S3 bucket with default security settings
# -----------------------------------------------------------------------------

module "basic_bucket" {
  source = "../../"

  bucket_name = "test-basic-bucket-12345"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "basic-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 2: S3 bucket with KMS encryption
# -----------------------------------------------------------------------------

module "kms_encrypted_bucket" {
  source = "../../"

  bucket_name = "test-kms-bucket-12345"

  # Use mock KMS key ARN for testing
  kms_key_id         = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  bucket_key_enabled = true

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "kms-encryption-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 3: S3 bucket with lifecycle rules
# -----------------------------------------------------------------------------

module "lifecycle_bucket" {
  source = "../../"

  bucket_name = "test-lifecycle-bucket-12345"

  lifecycle_rules = [
    {
      id      = "archive-logs"
      enabled = true
      prefix  = "logs/"
      tags = {
        Archive = "true"
      }

      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER_IR"
        }
      ]

      expiration_days                        = 365
      abort_incomplete_multipart_upload_days = 7

      noncurrent_version_transitions = [
        {
          days          = 30
          storage_class = "GLACIER"
        }
      ]
      noncurrent_version_expiration_days = 90
    },
    {
      id      = "cleanup-temp"
      enabled = true
      prefix  = "temp/"

      expiration_days                        = 7
      abort_incomplete_multipart_upload_days = 1
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "lifecycle-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 4: S3 bucket with versioning disabled
# -----------------------------------------------------------------------------

module "no_versioning_bucket" {
  source = "../../"

  bucket_name        = "test-no-version-bucket-12345"
  versioning_enabled = false

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "no-versioning-testing"
  }
}

# -----------------------------------------------------------------------------
# Test Outputs
# -----------------------------------------------------------------------------

output "basic_bucket_arn" {
  description = "ARN of the basic test bucket"
  value       = module.basic_bucket.bucket_arn
}

output "basic_bucket_id" {
  description = "ID of the basic test bucket"
  value       = module.basic_bucket.bucket_id
}

output "kms_bucket_encryption" {
  description = "Encryption algorithm used for KMS bucket"
  value       = module.kms_encrypted_bucket.encryption_algorithm
}

output "lifecycle_bucket_id" {
  description = "ID of the lifecycle test bucket"
  value       = module.lifecycle_bucket.bucket_id
}

output "no_versioning_bucket_versioning_enabled" {
  description = "Versioning status of the no-versioning test bucket"
  value       = module.no_versioning_bucket.versioning_enabled
}
