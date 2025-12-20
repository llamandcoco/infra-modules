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

# Test the module with basic S3 origin configuration
# This is the simplest CloudFront setup: static website from S3 with default CloudFront certificate
module "test_basic" {
  source = "../../"

  distribution_name   = "test-cloudfront-basic"
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  # Single S3 origin
  origins = [
    {
      origin_id   = "s3-origin"
      domain_name = "my-bucket.s3.amazonaws.com"
      origin_path = ""

      # Using legacy S3 origin config (no OAC in this basic test)
      s3_origin_config = {
        origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
      }
    }
  ]

  # Default cache behavior - optimized for static content
  default_cache_behavior = {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = true

    # Using AWS managed cache policy for static content
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized

    # Legacy TTL settings (not used when cache_policy_id is set)
    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
  }

  # Use default CloudFront certificate (*.cloudfront.net)
  viewer_certificate = {
    cloudfront_default_certificate = true
  }

  # No geographic restrictions
  geo_restriction = {
    restriction_type = "none"
    locations        = []
  }

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    TestType    = "basic"
  }
}

# Test outputs to verify module behavior
output "distribution_id" {
  description = "The CloudFront distribution ID"
  value       = module.test_basic.distribution_id
}

output "distribution_domain_name" {
  description = "The CloudFront distribution domain name"
  value       = module.test_basic.distribution_domain_name
}

output "distribution_url" {
  description = "The full HTTPS URL of the distribution"
  value       = module.test_basic.distribution_url
}

output "distribution_status" {
  description = "The current status of the distribution"
  value       = module.test_basic.distribution_status
}

output "distribution_enabled" {
  description = "Whether the distribution is enabled"
  value       = module.test_basic.distribution_enabled
}
