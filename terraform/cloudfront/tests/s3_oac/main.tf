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

# Test the module with Origin Access Control (OAC) for S3
# OAC is the modern, recommended approach for CloudFront + S3 (replaces legacy OAI)
# Supports all S3 features including SSE-KMS encryption
module "test_s3_oac" {
  source = "../../"

  distribution_name   = "test-cloudfront-s3-oac"
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  # Create Origin Access Control resource
  create_origin_access_control       = true
  origin_access_control_name         = "test-s3-oac"
  origin_access_control_description  = "OAC for S3 bucket access"
  origin_access_control_signing_behavior = "always"
  origin_access_control_signing_protocol = "sigv4"
  origin_access_control_origin_type      = "s3"

  # S3 origin using OAC (not legacy OAI)
  origins = [
    {
      origin_id   = "s3-oac-origin"
      domain_name = "my-website-bucket.s3.us-east-1.amazonaws.com"
      origin_path = ""

      # Use OAC instead of OAI
      # Note: The OAC ID is referenced from the created resource
      # In a real scenario, you would use: origin_access_control_id = aws_cloudfront_origin_access_control.this.id
      # For this test, we'll use a placeholder that matches the module's output
      s3_origin_config = {
        origin_access_control_id = "E1234567890ABC" # Placeholder - module creates this
      }

      connection_attempts = 3
      connection_timeout  = 10
    }
  ]

  # Default cache behavior optimized for static website
  default_cache_behavior = {
    target_origin_id       = "s3-oac-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = true

    # AWS managed cache policy for static content
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
  }

  # Use default CloudFront certificate
  viewer_certificate = {
    cloudfront_default_certificate = true
  }

  # No geographic restrictions
  geo_restriction = {
    restriction_type = "none"
    locations        = []
  }

  # Custom error responses for SPA (Single Page Application) pattern
  # Redirect 403/404 to index.html for client-side routing
  custom_error_responses = [
    {
      error_code         = 403
      response_code      = 200
      response_page_path = "/index.html"
      error_caching_min_ttl = 300
    },
    {
      error_code         = 404
      response_code      = 200
      response_page_path = "/index.html"
      error_caching_min_ttl = 300
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    TestType    = "s3-oac"
  }
}

# Test outputs
output "distribution_id" {
  description = "The CloudFront distribution ID"
  value       = module.test_s3_oac.distribution_id
}

output "distribution_arn" {
  description = "The CloudFront distribution ARN"
  value       = module.test_s3_oac.distribution_arn
}

output "distribution_domain_name" {
  description = "The CloudFront distribution domain name"
  value       = module.test_s3_oac.distribution_domain_name
}

output "distribution_url" {
  description = "The full HTTPS URL of the distribution"
  value       = module.test_s3_oac.distribution_url
}

output "origin_access_control_id" {
  description = "The OAC ID created by the module"
  value       = module.test_s3_oac.origin_access_control_id
}

output "invalidation_command" {
  description = "Command to invalidate cache"
  value       = module.test_s3_oac.invalidation_command
}

# Example S3 bucket policy for OAC
# This would be applied to the S3 bucket to allow CloudFront access
output "example_s3_bucket_policy" {
  description = "Example S3 bucket policy for OAC (apply this to your S3 bucket)"
  value = <<-EOT
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "AllowCloudFrontServicePrincipal",
          "Effect": "Allow",
          "Principal": {
            "Service": "cloudfront.amazonaws.com"
          },
          "Action": "s3:GetObject",
          "Resource": "arn:aws:s3:::my-website-bucket/*",
          "Condition": {
            "StringEquals": {
              "AWS:SourceArn": "${module.test_s3_oac.distribution_arn}"
            }
          }
        }
      ]
    }
  EOT
}
