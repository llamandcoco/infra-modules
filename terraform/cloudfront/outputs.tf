# -----------------------------------------------------------------------------
# Distribution Identification Outputs
# -----------------------------------------------------------------------------

output "distribution_id" {
  description = "The identifier for the CloudFront distribution. Use this for cache invalidations and CLI operations."
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_arn" {
  description = "The ARN of the CloudFront distribution. Use this for IAM policies and resource references."
  value       = aws_cloudfront_distribution.this.arn
}

output "distribution_domain_name" {
  description = "The domain name of the CloudFront distribution (e.g., d123abc.cloudfront.net). Use this for DNS CNAME or A/AAAA alias records."
  value       = aws_cloudfront_distribution.this.domain_name
}

output "distribution_hosted_zone_id" {
  description = "The CloudFront Route 53 zone ID (Z2FDTNDATAQYW2). Use this for Route53 alias records pointing to the distribution."
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}

output "distribution_status" {
  description = "The current status of the distribution (InProgress or Deployed)."
  value       = aws_cloudfront_distribution.this.status
}

# -----------------------------------------------------------------------------
# Origin Access Control Outputs
# -----------------------------------------------------------------------------

output "origin_access_control_id" {
  description = "The ID of the Origin Access Control resource, if created. Use this in origin configurations."
  value       = var.create_origin_access_control ? aws_cloudfront_origin_access_control.this[0].id : null
}

output "origin_access_control_etag" {
  description = "The ETag of the Origin Access Control resource, if created."
  value       = var.create_origin_access_control ? aws_cloudfront_origin_access_control.this[0].etag : null
}

# -----------------------------------------------------------------------------
# Distribution Configuration Outputs
# -----------------------------------------------------------------------------

output "distribution_enabled" {
  description = "Whether the distribution is enabled."
  value       = aws_cloudfront_distribution.this.enabled
}

output "distribution_comment" {
  description = "The comment/name of the distribution."
  value       = aws_cloudfront_distribution.this.comment
}

output "distribution_aliases" {
  description = "List of CNAMEs (alternate domain names) configured for the distribution."
  value       = aws_cloudfront_distribution.this.aliases
}

output "distribution_price_class" {
  description = "The price class of the distribution."
  value       = aws_cloudfront_distribution.this.price_class
}

output "distribution_http_version" {
  description = "The maximum HTTP version supported by the distribution."
  value       = aws_cloudfront_distribution.this.http_version
}

output "distribution_ipv6_enabled" {
  description = "Whether IPv6 is enabled for the distribution."
  value       = aws_cloudfront_distribution.this.is_ipv6_enabled
}

# -----------------------------------------------------------------------------
# Security Outputs
# -----------------------------------------------------------------------------

output "distribution_etag" {
  description = "The current version ETag of the distribution. Used for updates and modifications."
  value       = aws_cloudfront_distribution.this.etag
}

output "web_acl_id" {
  description = "The AWS WAF Web ACL ID associated with the distribution, if configured."
  value       = aws_cloudfront_distribution.this.web_acl_id
}

output "trusted_signers" {
  description = "List of nested attributes for active trusted signers configured for the distribution."
  value       = aws_cloudfront_distribution.this.trusted_signers
}

output "trusted_key_groups" {
  description = "List of nested attributes for active trusted key groups configured for the distribution."
  value       = aws_cloudfront_distribution.this.trusted_key_groups
}

# -----------------------------------------------------------------------------
# Certificate Outputs
# -----------------------------------------------------------------------------

output "viewer_certificate" {
  description = "The SSL/TLS certificate configuration for the distribution."
  value = {
    acm_certificate_arn      = var.viewer_certificate.acm_certificate_arn
    ssl_support_method       = var.viewer_certificate.ssl_support_method
    minimum_protocol_version = var.viewer_certificate.minimum_protocol_version
  }
}

# -----------------------------------------------------------------------------
# Origin Outputs
# -----------------------------------------------------------------------------

output "origins" {
  description = "List of origins configured for the distribution."
  value = [
    for origin in aws_cloudfront_distribution.this.origin :
    {
      origin_id   = origin.origin_id
      domain_name = origin.domain_name
      origin_path = origin.origin_path
    }
  ]
}

# -----------------------------------------------------------------------------
# Cache Behavior Outputs
# -----------------------------------------------------------------------------

output "default_cache_behavior_target_origin_id" {
  description = "The origin ID that the default cache behavior routes to."
  value       = aws_cloudfront_distribution.this.default_cache_behavior[0].target_origin_id
}

output "ordered_cache_behaviors_count" {
  description = "The number of ordered cache behaviors configured."
  value       = length(var.ordered_cache_behaviors)
}

# -----------------------------------------------------------------------------
# Resource Tags
# -----------------------------------------------------------------------------

output "tags" {
  description = "All tags applied to the distribution, including default and custom tags."
  value       = aws_cloudfront_distribution.this.tags_all
}

# -----------------------------------------------------------------------------
# Useful Information for Operations
# -----------------------------------------------------------------------------

output "distribution_url" {
  description = "The full HTTPS URL of the CloudFront distribution. Use this to test the distribution."
  value       = "https://${aws_cloudfront_distribution.this.domain_name}"
}

output "invalidation_command" {
  description = "AWS CLI command template for creating cache invalidations."
  value       = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.this.id} --paths '/*'"
}
