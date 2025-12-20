# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "distribution_name" {
  description = "Name of the CloudFront distribution. Used for the comment field and resource naming."
  type        = string

  validation {
    condition     = length(var.distribution_name) >= 1 && length(var.distribution_name) <= 128
    error_message = "Distribution name must be between 1 and 128 characters long."
  }
}

variable "enabled" {
  description = "Whether the distribution is enabled to accept end user requests for content."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Origin Configuration
# -----------------------------------------------------------------------------

variable "origins" {
  description = <<-EOT
    List of origins for this distribution. At least one origin is required.

    Each origin must specify:
    - origin_id: Unique identifier for this origin (referenced in cache behaviors)
    - domain_name: The domain name of the origin (S3 bucket, ALB DNS, or custom domain)

    For S3 origins, use either:
    - s3_origin_config with origin_access_control_id (recommended)
    - s3_origin_config with origin_access_identity (legacy, deprecated)

    For custom origins (ALB, API Gateway, web server), use:
    - custom_origin_config with protocol and SSL settings
  EOT
  type = list(object({
    origin_id   = string
    domain_name = string
    origin_path = optional(string)

    s3_origin_config = optional(object({
      origin_access_control_id = optional(string)
      origin_access_identity   = optional(string)
    }))

    custom_origin_config = optional(object({
      http_port                = optional(number, 80)
      https_port               = optional(number, 443)
      origin_protocol_policy   = string
      origin_ssl_protocols     = list(string)
      origin_keepalive_timeout = optional(number, 5)
      origin_read_timeout      = optional(number, 30)
    }))

    custom_headers = optional(list(object({
      name  = string
      value = string
    })), [])

    origin_shield = optional(object({
      enabled              = bool
      origin_shield_region = optional(string)
    }))

    connection_attempts = optional(number, 3)
    connection_timeout  = optional(number, 10)
  }))

  validation {
    condition     = length(var.origins) >= 1
    error_message = "At least one origin must be specified."
  }

  validation {
    condition = alltrue([
      for origin in var.origins :
      origin.connection_attempts >= 1 && origin.connection_attempts <= 3
    ])
    error_message = "Connection attempts must be between 1 and 3."
  }

  validation {
    condition = alltrue([
      for origin in var.origins :
      origin.connection_timeout >= 1 && origin.connection_timeout <= 10
    ])
    error_message = "Connection timeout must be between 1 and 10 seconds."
  }

  validation {
    condition = alltrue([
      for origin in var.origins :
      origin.custom_origin_config == null ? true : contains(
        ["http-only", "https-only", "match-viewer"],
        origin.custom_origin_config.origin_protocol_policy
      )
    ])
    error_message = "Origin protocol policy must be one of: http-only, https-only, match-viewer."
  }
}

# -----------------------------------------------------------------------------
# Default Cache Behavior
# -----------------------------------------------------------------------------

variable "default_cache_behavior" {
  description = <<-EOT
    Default cache behavior for the distribution. This behavior is used when no ordered cache behavior matches.

    Required fields:
    - target_origin_id: Must match an origin_id from the origins list
    - viewer_protocol_policy: How viewers can access content (allow-all, redirect-to-https, https-only)

    Recommended: Use managed cache policies (cache_policy_id) instead of legacy forwarded_values.
  EOT
  type = object({
    target_origin_id       = string
    viewer_protocol_policy = string
    allowed_methods        = optional(list(string), ["GET", "HEAD", "OPTIONS"])
    cached_methods         = optional(list(string), ["GET", "HEAD", "OPTIONS"])
    compress               = optional(bool, true)

    cache_policy_id            = optional(string)
    origin_request_policy_id   = optional(string)
    response_headers_policy_id = optional(string)
    realtime_log_config_arn    = optional(string)

    min_ttl     = optional(number, 0)
    default_ttl = optional(number, 86400)
    max_ttl     = optional(number, 31536000)

    forwarded_values = optional(object({
      query_string = bool
      cookies = optional(object({
        forward           = string
        whitelisted_names = optional(list(string))
      }))
      headers = optional(list(string))
    }))

    lambda_function_associations = optional(list(object({
      event_type   = string
      lambda_arn   = string
      include_body = optional(bool, false)
    })), [])

    function_associations = optional(list(object({
      event_type   = string
      function_arn = string
    })), [])

    field_level_encryption_id = optional(string)
    trusted_signers           = optional(list(string), [])
    trusted_key_groups        = optional(list(string), [])
    smooth_streaming          = optional(bool, false)
  })

  validation {
    condition = contains(
      ["allow-all", "redirect-to-https", "https-only"],
      var.default_cache_behavior.viewer_protocol_policy
    )
    error_message = "Viewer protocol policy must be one of: allow-all, redirect-to-https, https-only."
  }

  validation {
    condition = (
      var.default_cache_behavior.min_ttl <= var.default_cache_behavior.default_ttl &&
      var.default_cache_behavior.default_ttl <= var.default_cache_behavior.max_ttl
    )
    error_message = "TTL values must satisfy: min_ttl <= default_ttl <= max_ttl."
  }

  validation {
    condition = alltrue([
      for assoc in var.default_cache_behavior.lambda_function_associations :
      contains(
        ["viewer-request", "origin-request", "origin-response", "viewer-response"],
        assoc.event_type
      )
    ])
    error_message = "Lambda function event_type must be one of: viewer-request, origin-request, origin-response, viewer-response."
  }

  validation {
    condition = alltrue([
      for assoc in var.default_cache_behavior.function_associations :
      contains(["viewer-request", "viewer-response"], assoc.event_type)
    ])
    error_message = "CloudFront function event_type must be one of: viewer-request, viewer-response."
  }
}

# -----------------------------------------------------------------------------
# Ordered Cache Behaviors
# -----------------------------------------------------------------------------

variable "ordered_cache_behaviors" {
  description = <<-EOT
    List of ordered cache behaviors for specific path patterns.
    Evaluated in order, first match wins. Each behavior has the same structure as default_cache_behavior
    but requires a path_pattern field.
  EOT
  type = list(object({
    path_pattern           = string
    target_origin_id       = string
    viewer_protocol_policy = string
    allowed_methods        = optional(list(string), ["GET", "HEAD", "OPTIONS"])
    cached_methods         = optional(list(string), ["GET", "HEAD", "OPTIONS"])
    compress               = optional(bool, true)

    cache_policy_id            = optional(string)
    origin_request_policy_id   = optional(string)
    response_headers_policy_id = optional(string)
    realtime_log_config_arn    = optional(string)

    min_ttl     = optional(number, 0)
    default_ttl = optional(number, 86400)
    max_ttl     = optional(number, 31536000)

    forwarded_values = optional(object({
      query_string = bool
      cookies = optional(object({
        forward           = string
        whitelisted_names = optional(list(string))
      }))
      headers = optional(list(string))
    }))

    lambda_function_associations = optional(list(object({
      event_type   = string
      lambda_arn   = string
      include_body = optional(bool, false)
    })), [])

    function_associations = optional(list(object({
      event_type   = string
      function_arn = string
    })), [])

    field_level_encryption_id = optional(string)
    trusted_signers           = optional(list(string), [])
    trusted_key_groups        = optional(list(string), [])
    smooth_streaming          = optional(bool, false)
  }))
  default = []

  validation {
    condition = alltrue([
      for behavior in var.ordered_cache_behaviors :
      can(regex("^/.*", behavior.path_pattern))
    ])
    error_message = "Path pattern must start with '/'."
  }

  validation {
    condition = alltrue([
      for behavior in var.ordered_cache_behaviors :
      contains(["allow-all", "redirect-to-https", "https-only"], behavior.viewer_protocol_policy)
    ])
    error_message = "Viewer protocol policy must be one of: allow-all, redirect-to-https, https-only."
  }
}

# -----------------------------------------------------------------------------
# SSL/TLS Configuration
# -----------------------------------------------------------------------------

variable "viewer_certificate" {
  description = <<-EOT
    SSL/TLS certificate configuration for the distribution.

    For default CloudFront domain (*.cloudfront.net):
    - Set cloudfront_default_certificate = true

    For custom domains (requires aliases):
    - Set acm_certificate_arn with certificate ARN (MUST be in us-east-1)
    - Set ssl_support_method to "sni-only" (recommended) or "vip" ($600/month for dedicated IP)
    - Set minimum_protocol_version (TLSv1.2_2021 recommended)
  EOT
  type = object({
    cloudfront_default_certificate = optional(bool, true)
    acm_certificate_arn            = optional(string)
    iam_certificate_id             = optional(string)
    ssl_support_method             = optional(string, "sni-only")
    minimum_protocol_version       = optional(string, "TLSv1.2_2021")
  })
  default = {
    cloudfront_default_certificate = true
  }

  validation {
    condition = (
      var.viewer_certificate.ssl_support_method == null ||
      contains(["sni-only", "vip"], var.viewer_certificate.ssl_support_method)
    )
    error_message = "SSL support method must be one of: sni-only, vip."
  }

  validation {
    condition = (
      var.viewer_certificate.minimum_protocol_version == null ||
      contains(
        ["TLSv1", "TLSv1_2016", "TLSv1.1_2016", "TLSv1.2_2018", "TLSv1.2_2019", "TLSv1.2_2021"],
        var.viewer_certificate.minimum_protocol_version
      )
    )
    error_message = "Minimum protocol version must be a valid TLS version identifier."
  }
}

# -----------------------------------------------------------------------------
# Domain Configuration
# -----------------------------------------------------------------------------

variable "aliases" {
  description = <<-EOT
    List of CNAMEs (alternate domain names) for this distribution.
    Examples: ["www.example.com", "example.com"]

    IMPORTANT: Requires a custom SSL certificate (acm_certificate_arn) that matches these domains.
    Certificate MUST be in us-east-1 region.
  EOT
  type        = list(string)
  default     = []
}

variable "default_root_object" {
  description = "The object CloudFront returns when a user requests the root URL. Typically 'index.html' for S3-hosted websites."
  type        = string
  default     = "index.html"
}

# -----------------------------------------------------------------------------
# Geographic Restrictions
# -----------------------------------------------------------------------------

variable "geo_restriction" {
  description = <<-EOT
    Geographic restrictions for content distribution.

    - restriction_type: none, whitelist, or blacklist
    - locations: List of ISO 3166-1-alpha-2 country codes (e.g., ["US", "CA", "GB"])

    Set to null to disable geographic restrictions.
  EOT
  type = object({
    restriction_type = string
    locations        = optional(list(string), [])
  })
  default = {
    restriction_type = "none"
    locations        = []
  }

  validation {
    condition = (
      var.geo_restriction == null ||
      contains(["none", "whitelist", "blacklist"], var.geo_restriction.restriction_type)
    )
    error_message = "Geo restriction type must be one of: none, whitelist, blacklist."
  }
}

# -----------------------------------------------------------------------------
# Logging Configuration
# -----------------------------------------------------------------------------

variable "logging_config" {
  description = <<-EOT
    Logging configuration for the distribution.

    - bucket: S3 bucket domain name for logs (e.g., "logs.s3.amazonaws.com")
    - prefix: Optional prefix for log files
    - include_cookies: Whether to include cookies in logs (default: false)

    Set to null to disable logging.
  EOT
  type = object({
    bucket          = string
    prefix          = optional(string, "")
    include_cookies = optional(bool, false)
  })
  default = null
}

# -----------------------------------------------------------------------------
# Performance & Cost Configuration
# -----------------------------------------------------------------------------

variable "price_class" {
  description = <<-EOT
    Price class determines which edge locations are used for content delivery.

    - PriceClass_100: US, Canada, Europe (lowest cost)
    - PriceClass_200: PriceClass_100 + Asia, Africa, South America (medium cost)
    - PriceClass_All: All edge locations worldwide (highest cost, lowest latency)
  EOT
  type        = string
  default     = "PriceClass_All"

  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.price_class)
    error_message = "Price class must be one of: PriceClass_100, PriceClass_200, PriceClass_All."
  }
}

variable "http_version" {
  description = "Maximum HTTP version to support. Options: http1.1, http2, http2and3, http3."
  type        = string
  default     = "http2and3"

  validation {
    condition     = contains(["http1.1", "http2", "http2and3", "http3"], var.http_version)
    error_message = "HTTP version must be one of: http1.1, http2, http2and3, http3."
  }
}

variable "is_ipv6_enabled" {
  description = "Whether IPv6 is enabled for the distribution. Recommended to leave enabled."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Custom Error Responses
# -----------------------------------------------------------------------------

variable "custom_error_responses" {
  description = <<-EOT
    List of custom error responses for specific HTTP error codes.

    Useful for providing user-friendly error pages (404, 500, etc.).
    Each error response can specify:
    - error_code: HTTP error code to handle (400-599)
    - response_code: Custom HTTP response code to return (optional)
    - response_page_path: Path to custom error page (optional)
    - error_caching_min_ttl: Minimum time to cache this error (default: 300 seconds)
  EOT
  type = list(object({
    error_code            = number
    response_code         = optional(number)
    response_page_path    = optional(string)
    error_caching_min_ttl = optional(number, 300)
  }))
  default = []

  validation {
    condition = alltrue([
      for error in var.custom_error_responses :
      error.error_code >= 400 && error.error_code <= 599
    ])
    error_message = "Error code must be between 400 and 599."
  }
}

# -----------------------------------------------------------------------------
# Web Application Firewall
# -----------------------------------------------------------------------------

variable "web_acl_id" {
  description = "AWS WAF Web ACL ARN to associate with the distribution for DDoS protection and security rules. Set to null to disable WAF."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Origin Access Control (OAC)
# -----------------------------------------------------------------------------

variable "create_origin_access_control" {
  description = "Whether to create an Origin Access Control resource for S3 origins. Recommended over legacy OAI."
  type        = bool
  default     = false
}

variable "origin_access_control_name" {
  description = "Name for the Origin Access Control. Only used if create_origin_access_control is true."
  type        = string
  default     = null
}

variable "origin_access_control_description" {
  description = "Description for the Origin Access Control. Only used if create_origin_access_control is true."
  type        = string
  default     = "Origin Access Control for CloudFront distribution"
}

variable "origin_access_control_signing_behavior" {
  description = "Signing behavior for OAC. Valid values: always, never, no-override."
  type        = string
  default     = "always"

  validation {
    condition     = contains(["always", "never", "no-override"], var.origin_access_control_signing_behavior)
    error_message = "Signing behavior must be one of: always, never, no-override."
  }
}

variable "origin_access_control_signing_protocol" {
  description = "Signing protocol for OAC. Valid values: sigv4."
  type        = string
  default     = "sigv4"

  validation {
    condition     = var.origin_access_control_signing_protocol == "sigv4"
    error_message = "Signing protocol must be sigv4."
  }
}

variable "origin_access_control_origin_type" {
  description = "Origin type for OAC. Valid values: s3, mediastore."
  type        = string
  default     = "s3"

  validation {
    condition     = contains(["s3", "mediastore"], var.origin_access_control_origin_type)
    error_message = "Origin type must be one of: s3, mediastore."
  }
}

# -----------------------------------------------------------------------------
# Advanced Settings
# -----------------------------------------------------------------------------

variable "retain_on_delete" {
  description = "Whether to disable the distribution instead of deleting it when destroyed. Useful for preventing accidental deletion."
  type        = bool
  default     = false
}

variable "wait_for_deployment" {
  description = "Whether to wait for the distribution deployment to complete. Deployments can take 15-30 minutes."
  type        = bool
  default     = true
}

variable "staging" {
  description = "Whether to create a staging distribution. Experimental feature for blue/green deployments."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to all resources. Use this to add consistent tagging across your infrastructure."
  type        = map(string)
  default     = {}
}
