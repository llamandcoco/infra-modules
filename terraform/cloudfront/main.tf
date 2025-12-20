terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Local values for resolving S3 origin configuration
# Handles AWS provider requirement that origin_access_identity must be present
# even when using modern Origin Access Control (OAC)
locals {
  # Transform origins to ensure s3_origin_config has origin_access_identity set
  # When using OAC, origin_access_identity is set to empty string (provider requirement)
  # When using OAI, origin_access_identity is passed through as-is
  transformed_origins = [
    for origin in var.origins : merge(
      origin,
      origin.s3_origin_config != null ? {
        s3_origin_config = merge(
          origin.s3_origin_config,
          {
            # AWS provider requires origin_access_identity to be present in the schema
            # even when using OAC. Set to empty string if using OAC (origin_access_control_id provided)
            origin_access_identity = (
              origin.s3_origin_config.origin_access_control_id != null && origin.s3_origin_config.origin_access_control_id != "" ?
              "" :
              origin.s3_origin_config.origin_access_identity
            )
          }
        )
      } : {}
    )
  ]
}


resource "aws_cloudfront_origin_access_control" "this" {
  count = var.create_origin_access_control ? 1 : 0

  name                              = coalesce(var.origin_access_control_name, "${var.distribution_name}-oac")
  description                       = var.origin_access_control_description
  origin_access_control_origin_type = var.origin_access_control_origin_type
  signing_behavior                  = var.origin_access_control_signing_behavior
  signing_protocol                  = var.origin_access_control_signing_protocol
}

# -----------------------------------------------------------------------------
# CloudFront Distribution
# Main CDN distribution resource
# -----------------------------------------------------------------------------

resource "aws_cloudfront_distribution" "this" {
  enabled             = var.enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  comment             = var.distribution_name
  default_root_object = var.default_root_object
  price_class         = var.price_class
  http_version        = var.http_version
  web_acl_id          = var.web_acl_id
  retain_on_delete    = var.retain_on_delete
  wait_for_deployment = var.wait_for_deployment
  staging             = var.staging

  aliases = var.aliases

  # Origins configuration
  dynamic "origin" {
    for_each = local.transformed_origins

    content {
      origin_id   = origin.value.origin_id
      domain_name = origin.value.domain_name
      origin_path = try(origin.value.origin_path, "")

      connection_attempts = origin.value.connection_attempts
      connection_timeout  = origin.value.connection_timeout

      # S3 origin configuration
      dynamic "s3_origin_config" {
        for_each = origin.value.s3_origin_config != null ? [origin.value.s3_origin_config] : []

        content {
          origin_access_identity = s3_origin_config.value.origin_access_identity
        }
      }

      # Origin Access Control (OAC) - modern approach for S3
      origin_access_control_id = try(
        origin.value.s3_origin_config.origin_access_control_id,
        null
      )

      # Custom origin configuration (ALB, API Gateway, custom server)
      dynamic "custom_origin_config" {
        for_each = origin.value.custom_origin_config != null ? [origin.value.custom_origin_config] : []

        content {
          http_port                = custom_origin_config.value.http_port
          https_port               = custom_origin_config.value.https_port
          origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
          origin_keepalive_timeout = custom_origin_config.value.origin_keepalive_timeout
          origin_read_timeout      = custom_origin_config.value.origin_read_timeout
        }
      }

      # Custom headers sent to origin
      dynamic "custom_header" {
        for_each = origin.value.custom_headers

        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }

      # Origin Shield - additional caching layer to reduce origin load
      dynamic "origin_shield" {
        for_each = origin.value.origin_shield != null ? [origin.value.origin_shield] : []

        content {
          enabled              = origin_shield.value.enabled
          origin_shield_region = origin_shield.value.origin_shield_region
        }
      }
    }
  }

  # Default cache behavior
  default_cache_behavior {
    target_origin_id       = var.default_cache_behavior.target_origin_id
    viewer_protocol_policy = var.default_cache_behavior.viewer_protocol_policy
    allowed_methods        = var.default_cache_behavior.allowed_methods
    cached_methods         = var.default_cache_behavior.cached_methods
    compress               = var.default_cache_behavior.compress

    # Managed cache policies (recommended)
    cache_policy_id            = var.default_cache_behavior.cache_policy_id
    origin_request_policy_id   = var.default_cache_behavior.origin_request_policy_id
    response_headers_policy_id = var.default_cache_behavior.response_headers_policy_id
    realtime_log_config_arn    = var.default_cache_behavior.realtime_log_config_arn

    # Legacy cache settings (used when cache_policy_id is not set)
    min_ttl     = var.default_cache_behavior.min_ttl
    default_ttl = var.default_cache_behavior.default_ttl
    max_ttl     = var.default_cache_behavior.max_ttl

    # Legacy forwarded values (prefer managed policies)
    dynamic "forwarded_values" {
      for_each = var.default_cache_behavior.forwarded_values != null ? [var.default_cache_behavior.forwarded_values] : []

      content {
        query_string = forwarded_values.value.query_string
        headers      = try(forwarded_values.value.headers, [])

        cookies {
          forward           = try(forwarded_values.value.cookies.forward, "none")
          whitelisted_names = try(forwarded_values.value.cookies.whitelisted_names, [])
        }
      }
    }

    # Lambda@Edge function associations
    dynamic "lambda_function_association" {
      for_each = var.default_cache_behavior.lambda_function_associations

      content {
        event_type   = lambda_function_association.value.event_type
        lambda_arn   = lambda_function_association.value.lambda_arn
        include_body = lambda_function_association.value.include_body
      }
    }

    # CloudFront Functions (lightweight transforms)
    dynamic "function_association" {
      for_each = var.default_cache_behavior.function_associations

      content {
        event_type   = function_association.value.event_type
        function_arn = function_association.value.function_arn
      }
    }

    # Field-level encryption
    field_level_encryption_id = var.default_cache_behavior.field_level_encryption_id

    # Trusted signers for private content
    trusted_signers    = var.default_cache_behavior.trusted_signers
    trusted_key_groups = var.default_cache_behavior.trusted_key_groups

    # Smooth streaming for media
    smooth_streaming = var.default_cache_behavior.smooth_streaming
  }

  # Ordered cache behaviors - evaluated in order, first match wins
  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors

    content {
      path_pattern           = ordered_cache_behavior.value.path_pattern
      target_origin_id       = ordered_cache_behavior.value.target_origin_id
      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy
      allowed_methods        = ordered_cache_behavior.value.allowed_methods
      cached_methods         = ordered_cache_behavior.value.cached_methods
      compress               = ordered_cache_behavior.value.compress

      # Managed cache policies
      cache_policy_id            = ordered_cache_behavior.value.cache_policy_id
      origin_request_policy_id   = ordered_cache_behavior.value.origin_request_policy_id
      response_headers_policy_id = ordered_cache_behavior.value.response_headers_policy_id
      realtime_log_config_arn    = ordered_cache_behavior.value.realtime_log_config_arn

      # Legacy cache settings
      min_ttl     = ordered_cache_behavior.value.min_ttl
      default_ttl = ordered_cache_behavior.value.default_ttl
      max_ttl     = ordered_cache_behavior.value.max_ttl

      # Legacy forwarded values
      dynamic "forwarded_values" {
        for_each = ordered_cache_behavior.value.forwarded_values != null ? [ordered_cache_behavior.value.forwarded_values] : []

        content {
          query_string = forwarded_values.value.query_string
          headers      = try(forwarded_values.value.headers, [])

          cookies {
            forward           = try(forwarded_values.value.cookies.forward, "none")
            whitelisted_names = try(forwarded_values.value.cookies.whitelisted_names, [])
          }
        }
      }

      # Lambda@Edge function associations
      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value.lambda_function_associations

        content {
          event_type   = lambda_function_association.value.event_type
          lambda_arn   = lambda_function_association.value.lambda_arn
          include_body = lambda_function_association.value.include_body
        }
      }

      # CloudFront Functions
      dynamic "function_association" {
        for_each = ordered_cache_behavior.value.function_associations

        content {
          event_type   = function_association.value.event_type
          function_arn = function_association.value.function_arn
        }
      }

      # Additional settings
      field_level_encryption_id = ordered_cache_behavior.value.field_level_encryption_id
      trusted_signers           = ordered_cache_behavior.value.trusted_signers
      trusted_key_groups        = ordered_cache_behavior.value.trusted_key_groups
      smooth_streaming          = ordered_cache_behavior.value.smooth_streaming
    }
  }

  # SSL/TLS certificate configuration
  viewer_certificate {
    cloudfront_default_certificate = var.viewer_certificate.cloudfront_default_certificate
    acm_certificate_arn            = var.viewer_certificate.acm_certificate_arn
    iam_certificate_id             = var.viewer_certificate.iam_certificate_id
    ssl_support_method             = var.viewer_certificate.acm_certificate_arn != null ? var.viewer_certificate.ssl_support_method : null
    minimum_protocol_version       = var.viewer_certificate.acm_certificate_arn != null ? var.viewer_certificate.minimum_protocol_version : "TLSv1"
  }

  # Geographic restrictions
  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction.restriction_type
      locations        = var.geo_restriction.locations
    }
  }

  # Access logging configuration
  dynamic "logging_config" {
    for_each = var.logging_config != null ? [var.logging_config] : []

    content {
      bucket          = logging_config.value.bucket
      prefix          = logging_config.value.prefix
      include_cookies = logging_config.value.include_cookies
    }
  }

  # Custom error responses
  dynamic "custom_error_response" {
    for_each = var.custom_error_responses

    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.distribution_name
    }
  )
}
