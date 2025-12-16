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

# Test the module with multiple origins and path-based routing
# This demonstrates a hybrid setup: static content from S3, dynamic API from ALB
# Common use case: Single-page application (SPA) with API backend
module "test_multi_origin" {
  source = "../../"

  distribution_name   = "test-cloudfront-multi-origin"
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_200"

  # Multiple origins: S3 for static content, ALB for API
  origins = [
    # S3 origin for static website content
    {
      origin_id   = "s3-static"
      domain_name = "static-assets.s3.amazonaws.com"
      origin_path = "/production"

      s3_origin_config = {
        origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
      }

      connection_attempts = 3
      connection_timeout  = 10
    },
    # ALB origin for API endpoints
    {
      origin_id   = "alb-api"
      domain_name = "api-alb-1234567890.us-east-1.elb.amazonaws.com"
      origin_path = ""

      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
        origin_keepalive_timeout = 60
        origin_read_timeout      = 60
      }

      custom_headers = [
        {
          name  = "X-Custom-Secret"
          value = "api-secret-token"
        }
      ]

      origin_shield = {
        enabled              = true
        origin_shield_region = "us-east-1"
      }

      connection_attempts = 3
      connection_timeout  = 10
    },
    # S3 origin for media/large files
    {
      origin_id   = "s3-media"
      domain_name = "media-bucket.s3.us-west-2.amazonaws.com"
      origin_path = ""

      s3_origin_config = {
        origin_access_identity = "origin-access-identity/cloudfront/HIJKLMN7890123"
      }

      connection_attempts = 3
      connection_timeout  = 10
    }
  ]

  # Default cache behavior - routes to static S3 content
  default_cache_behavior = {
    target_origin_id       = "s3-static"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = true

    # Optimized caching for static content
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
  }

  # Ordered cache behaviors - evaluated in order, first match wins
  ordered_cache_behaviors = [
    # API requests - no caching, forward everything
    {
      path_pattern           = "/api/*"
      target_origin_id       = "alb-api"
      viewer_protocol_policy = "https-only"
      allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods         = ["GET", "HEAD", "OPTIONS"]
      compress               = true

      # Disable caching for API
      cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled

      # Forward all viewer data to origin
      origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # AllViewer

      min_ttl     = 0
      default_ttl = 0
      max_ttl     = 0
    },
    # Static assets with versioned filenames - aggressive caching
    {
      path_pattern           = "/static/*"
      target_origin_id       = "s3-static"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD", "OPTIONS"]
      compress               = true

      # Use cache policy optimized for static content
      cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized

      # Very long TTL for versioned assets
      min_ttl     = 31536000
      default_ttl = 31536000
      max_ttl     = 31536000
    },
    # Media files (images, videos) - long caching
    {
      path_pattern           = "/media/*"
      target_origin_id       = "s3-media"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD", "OPTIONS"]
      compress               = false # Don't compress already-compressed media

      # Optimized for uncompressed objects (images, videos)
      cache_policy_id = "b2884449-e4de-46a7-ac36-70bc7f1ddd6d" # CachingOptimizedForUncompressedObjects

      min_ttl     = 86400
      default_ttl = 604800  # 7 days
      max_ttl     = 31536000
    },
    # Images with specific extensions - long caching
    {
      path_pattern           = "/images/*.{jpg,jpeg,png,gif,webp}"
      target_origin_id       = "s3-static"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["GET", "HEAD"]
      cached_methods         = ["GET", "HEAD"]
      compress               = false

      cache_policy_id = "b2884449-e4de-46a7-ac36-70bc7f1ddd6d" # CachingOptimizedForUncompressedObjects

      min_ttl     = 86400
      default_ttl = 2592000  # 30 days
      max_ttl     = 31536000
    }
  ]

  # Use default CloudFront certificate
  viewer_certificate = {
    cloudfront_default_certificate = true
  }

  # Geographic restrictions - example: only allow US and Canada
  geo_restriction = {
    restriction_type = "whitelist"
    locations        = ["US", "CA", "GB", "DE", "FR"]
  }

  # Custom error responses
  custom_error_responses = [
    {
      error_code         = 403
      response_code      = 404
      response_page_path = "/404.html"
      error_caching_min_ttl = 300
    },
    {
      error_code         = 404
      response_code      = 404
      response_page_path = "/404.html"
      error_caching_min_ttl = 300
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    TestType    = "multi-origin"
  }
}

# Test outputs
output "distribution_id" {
  description = "The CloudFront distribution ID"
  value       = module.test_multi_origin.distribution_id
}

output "distribution_domain_name" {
  description = "The CloudFront distribution domain name"
  value       = module.test_multi_origin.distribution_domain_name
}

output "distribution_url" {
  description = "The full HTTPS URL of the distribution"
  value       = module.test_multi_origin.distribution_url
}

output "origins" {
  description = "List of configured origins"
  value       = module.test_multi_origin.origins
}

output "ordered_cache_behaviors_count" {
  description = "Number of ordered cache behaviors"
  value       = module.test_multi_origin.ordered_cache_behaviors_count
}

output "default_cache_behavior_target" {
  description = "Target origin for default cache behavior"
  value       = module.test_multi_origin.default_cache_behavior_target_origin_id
}
