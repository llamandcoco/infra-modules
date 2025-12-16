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

# Test the module with Lambda@Edge and CloudFront Functions
# This demonstrates edge computing capabilities for request/response manipulation
#
# Lambda@Edge vs CloudFront Functions:
# - CloudFront Functions: Sub-millisecond, viewer events only, JavaScript, <10KB, cheaper
# - Lambda@Edge: Milliseconds, all events, Node.js/Python, up to 50MB, more powerful
module "test_lambda_edge" {
  source = "../../"

  distribution_name   = "test-cloudfront-lambda-edge"
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  # S3 origin
  origins = [
    {
      origin_id   = "s3-origin"
      domain_name = "my-bucket.s3.amazonaws.com"
      origin_path = ""

      s3_origin_config = {
        origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
      }

      connection_attempts = 3
      connection_timeout  = 10
    }
  ]

  # Default cache behavior with Lambda@Edge and CloudFront Functions
  default_cache_behavior = {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = true

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized

    # CloudFront Functions - lightweight, fast transformations
    function_associations = [
      # Viewer request: Add security headers, URL rewrites
      {
        event_type   = "viewer-request"
        function_arn = "arn:aws:cloudfront::123456789012:function/url-rewrite-function"
      },
      # Viewer response: Add security headers
      {
        event_type   = "viewer-response"
        function_arn = "arn:aws:cloudfront::123456789012:function/add-security-headers"
      }
    ]

    # Lambda@Edge functions - more complex logic
    lambda_function_associations = [
      # Viewer request: A/B testing, authentication
      {
        event_type   = "viewer-request"
        lambda_arn   = "arn:aws:lambda:us-east-1:123456789012:function:ab-testing:1"
        include_body = false
      },
      # Origin request: Modify request before origin, add headers
      {
        event_type   = "origin-request"
        lambda_arn   = "arn:aws:lambda:us-east-1:123456789012:function:origin-request-handler:2"
        include_body = false
      },
      # Origin response: Transform response, resize images
      {
        event_type   = "origin-response"
        lambda_arn   = "arn:aws:lambda:us-east-1:123456789012:function:image-resize:3"
        include_body = false
      },
      # Viewer response: Final response manipulation
      {
        event_type   = "viewer-response"
        lambda_arn   = "arn:aws:lambda:us-east-1:123456789012:function:response-customizer:1"
        include_body = false
      }
    ]

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
  }

  # Ordered cache behavior for API paths with different Lambda functions
  ordered_cache_behaviors = [
    {
      path_pattern           = "/api/*"
      target_origin_id       = "s3-origin"
      viewer_protocol_policy = "https-only"
      allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods         = ["GET", "HEAD", "OPTIONS"]
      compress               = true

      cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled

      # Different Lambda@Edge function for API endpoints
      lambda_function_associations = [
        {
          event_type   = "viewer-request"
          lambda_arn   = "arn:aws:lambda:us-east-1:123456789012:function:api-auth:5"
          include_body = true # Include request body for API calls
        }
      ]

      min_ttl     = 0
      default_ttl = 0
      max_ttl     = 0
    }
  ]

  # Use default CloudFront certificate
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
    TestType    = "lambda-edge"
  }
}

# Test outputs
output "distribution_id" {
  description = "The CloudFront distribution ID"
  value       = module.test_lambda_edge.distribution_id
}

output "distribution_domain_name" {
  description = "The CloudFront distribution domain name"
  value       = module.test_lambda_edge.distribution_domain_name
}

output "distribution_url" {
  description = "The full HTTPS URL of the distribution"
  value       = module.test_lambda_edge.distribution_url
}

# Example Lambda@Edge function code snippets
output "example_cloudfront_function_url_rewrite" {
  description = "Example CloudFront Function for URL rewriting"
  value = <<-EOT
    // CloudFront Function - URL Rewrite
    // Redirects /old-path to /new-path
    function handler(event) {
        var request = event.request;
        var uri = request.uri;

        // Redirect old paths to new paths
        if (uri === '/old-path' || uri === '/old-path/') {
            request.uri = '/new-path';
        }

        // Add index.html to directory requests
        if (uri.endsWith('/')) {
            request.uri += 'index.html';
        }

        return request;
    }
  EOT
}

output "example_cloudfront_function_security_headers" {
  description = "Example CloudFront Function for adding security headers"
  value = <<-EOT
    // CloudFront Function - Add Security Headers
    function handler(event) {
        var response = event.response;
        var headers = response.headers;

        // Add security headers
        headers['strict-transport-security'] = { value: 'max-age=63072000; includeSubdomains; preload' };
        headers['x-content-type-options'] = { value: 'nosniff' };
        headers['x-frame-options'] = { value: 'DENY' };
        headers['x-xss-protection'] = { value: '1; mode=block' };
        headers['referrer-policy'] = { value: 'same-origin' };

        return response;
    }
  EOT
}

output "example_lambda_edge_ab_testing" {
  description = "Example Lambda@Edge function for A/B testing (Node.js)"
  value = <<-EOT
    // Lambda@Edge - A/B Testing (viewer-request)
    exports.handler = async (event) => {
        const request = event.Records[0].cf.request;
        const headers = request.headers;

        // Check if user already has a variant cookie
        const cookies = headers.cookie || [];
        let variant = null;

        for (const cookie of cookies) {
            if (cookie.value.includes('ab-test-variant=')) {
                variant = cookie.value.split('ab-test-variant=')[1].split(';')[0];
            }
        }

        // Assign random variant if not set
        if (!variant) {
            variant = Math.random() < 0.5 ? 'A' : 'B';

            // Set cookie
            headers['cookie'] = headers['cookie'] || [];
            headers['cookie'].push({
                key: 'Cookie',
                value: `ab-test-variant=$${variant}; Path=/; Max-Age=86400`
            });
        }

        // Add custom header for origin
        headers['x-ab-variant'] = [{ key: 'X-AB-Variant', value: variant }];

        return request;
    };
  EOT
}

output "example_lambda_edge_image_resize" {
  description = "Example Lambda@Edge concept for image resizing (origin-response)"
  value = <<-EOT
    // Lambda@Edge - Image Resize (origin-response)
    // Note: Actual implementation requires Sharp library
    exports.handler = async (event) => {
        const response = event.Records[0].cf.response;
        const request = event.Records[0].cf.request;

        // Parse query string for width parameter
        const params = new URLSearchParams(request.querystring);
        const width = parseInt(params.get('width') || '0');

        if (width > 0 && response.status === '200') {
            // In real implementation:
            // 1. Decode base64 body
            // 2. Use Sharp to resize image
            // 3. Encode back to base64
            // 4. Update response body

            response.headers['x-resized'] = [{ key: 'X-Resized', value: 'true' }];
        }

        return response;
    };
  EOT
}
