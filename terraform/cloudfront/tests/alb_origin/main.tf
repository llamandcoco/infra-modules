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

# Test the module with ALB custom origin configuration
# This demonstrates CloudFront in front of an Application Load Balancer
# Common use case: Dynamic web application with API backend
module "test_alb_origin" {
  source = "../../"

  distribution_name   = "test-cloudfront-alb"
  enabled             = true
  default_root_object = ""
  price_class         = "PriceClass_All"

  # Custom domain names for the distribution
  aliases = ["api.example.com", "www.example.com"]

  # ALB as custom origin
  origins = [
    {
      origin_id   = "alb-origin"
      domain_name = "my-alb-1234567890.us-east-1.elb.amazonaws.com"
      origin_path = ""

      # Custom origin configuration for ALB
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only" # Always use HTTPS to origin
        origin_ssl_protocols   = ["TLSv1.2"]
        origin_keepalive_timeout = 5
        origin_read_timeout      = 30
      }

      # Custom header for origin authentication
      # ALB can validate this header to ensure requests come through CloudFront
      custom_headers = [
        {
          name  = "X-Custom-Secret"
          value = "super-secret-value-12345"
        },
        {
          name  = "X-Origin-Verify"
          value = "cloudfront-verification-token"
        }
      ]

      # Enable Origin Shield for additional caching layer
      origin_shield = {
        enabled              = true
        origin_shield_region = "us-east-1"
      }

      connection_attempts = 3
      connection_timeout  = 10
    }
  ]

  # Default cache behavior - minimal caching for dynamic content
  default_cache_behavior = {
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "https-only"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = true

    # Using AWS managed cache policy for caching disabled (dynamic content)
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled

    # Use managed origin request policy to forward all headers, query strings, cookies
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # AllViewer

    # TTL settings (not used when cache_policy_id is set)
    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  # Custom SSL certificate for custom domains
  viewer_certificate = {
    cloudfront_default_certificate = false
    acm_certificate_arn            = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  # No geographic restrictions
  geo_restriction = {
    restriction_type = "none"
    locations        = []
  }

  # Custom error responses for better user experience
  custom_error_responses = [
    {
      error_code         = 404
      response_code      = 404
      response_page_path = "/errors/404.html"
      error_caching_min_ttl = 300
    },
    {
      error_code         = 500
      response_code      = 500
      response_page_path = "/errors/500.html"
      error_caching_min_ttl = 60
    },
    {
      error_code         = 503
      response_code      = 503
      response_page_path = "/errors/503.html"
      error_caching_min_ttl = 0
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    TestType    = "alb-origin"
  }
}

# Test outputs
output "distribution_id" {
  description = "The CloudFront distribution ID"
  value       = module.test_alb_origin.distribution_id
}

output "distribution_domain_name" {
  description = "The CloudFront distribution domain name"
  value       = module.test_alb_origin.distribution_domain_name
}

output "distribution_aliases" {
  description = "The custom domain names configured"
  value       = module.test_alb_origin.distribution_aliases
}

output "distribution_url" {
  description = "The full HTTPS URL of the distribution"
  value       = module.test_alb_origin.distribution_url
}

output "origins" {
  description = "List of configured origins"
  value       = module.test_alb_origin.origins
}
