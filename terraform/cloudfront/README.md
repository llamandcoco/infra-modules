# CloudFront Terraform Module

- [AWS CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/) - [CloudFront Developer Guide](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/) - [Lambda@Edge Guide](https://docs.aws.amazon.com/lambda/latest/dg/lambda-edge.html) - [CloudFront Functions Guide](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cloudfront-functions.html)

## Features

- Multiple Origin Support S3, ALB, API Gateway, and custom origins
- Origin Access Control (OAC) Modern S3 access (replaces legacy OAI)
- Advanced Caching Managed cache policies and custom TTL configurations
- Edge Computing Lambda@Edge and CloudFront Functions integration
- Security WAF integration, custom SSL certificates, signed URLs, geographic restrictions
- Path-Based Routing Multiple cache behaviors with different origins and caching strategies
- Custom Error Pages User-friendly error responses
- Monitoring CloudWatch integration and access logging

## Quick Start

```hcl
module "cloudfront" {
  source = "github.com/llamandcoco/infra-modules//terraform/cloudfront?ref=<commit-sha>"

  # Add required variables here
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|----------|
| Alb Origin | [`tests/alb_origin/`](tests/alb_origin/) |
| Basic | [`tests/basic/`](tests/basic/) |
| Lambda Edge | [`tests/lambda_edge/`](tests/lambda_edge/) |
| Multi Origin | [`tests/multi_origin/`](tests/multi_origin/) |
| S3 Oac | [`tests/s3_oac/`](tests/s3_oac/) |

**Usage:**
```bash
# View example
cat tests/alb_origin/

# Copy and adapt
cp -r tests/alb_origin/ my-project/
```

## Testing

```bash
cd tests/alb_origin && terraform init && terraform plan
```

<details>
<summary>Terraform Documentation</summary>

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_control.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aliases"></a> [aliases](#input\_aliases) | List of CNAMEs (alternate domain names) for this distribution.<br/>Examples: ["www.example.com", "example.com"]<br/><br/>IMPORTANT: Requires a custom SSL certificate (acm\_certificate\_arn) that matches these domains.<br/>Certificate MUST be in us-east-1 region. | `list(string)` | `[]` | no |
| <a name="input_create_origin_access_control"></a> [create\_origin\_access\_control](#input\_create\_origin\_access\_control) | Whether to create an Origin Access Control resource for S3 origins. Recommended over legacy OAI. | `bool` | `false` | no |
| <a name="input_custom_error_responses"></a> [custom\_error\_responses](#input\_custom\_error\_responses) | List of custom error responses for specific HTTP error codes.<br/><br/>Useful for providing user-friendly error pages (404, 500, etc.).<br/>Each error response can specify:<br/>- error\_code: HTTP error code to handle (400-599)<br/>- response\_code: Custom HTTP response code to return (optional)<br/>- response\_page\_path: Path to custom error page (optional)<br/>- error\_caching\_min\_ttl: Minimum time to cache this error (default: 300 seconds) | <pre>list(object({<br/>    error_code            = number<br/>    response_code         = optional(number)<br/>    response_page_path    = optional(string)<br/>    error_caching_min_ttl = optional(number, 300)<br/>  }))</pre> | `[]` | no |
| <a name="input_default_cache_behavior"></a> [default\_cache\_behavior](#input\_default\_cache\_behavior) | Default cache behavior for the distribution. This behavior is used when no ordered cache behavior matches.<br/><br/>Required fields:<br/>- target\_origin\_id: Must match an origin\_id from the origins list<br/>- viewer\_protocol\_policy: How viewers can access content (allow-all, redirect-to-https, https-only)<br/><br/>Recommended: Use managed cache policies (cache\_policy\_id) instead of legacy forwarded\_values. | <pre>object({<br/>    target_origin_id       = string<br/>    viewer_protocol_policy = string<br/>    allowed_methods        = optional(list(string), ["GET", "HEAD", "OPTIONS"])<br/>    cached_methods         = optional(list(string), ["GET", "HEAD", "OPTIONS"])<br/>    compress               = optional(bool, true)<br/><br/>    cache_policy_id            = optional(string)<br/>    origin_request_policy_id   = optional(string)<br/>    response_headers_policy_id = optional(string)<br/>    realtime_log_config_arn    = optional(string)<br/><br/>    min_ttl     = optional(number, 0)<br/>    default_ttl = optional(number, 86400)<br/>    max_ttl     = optional(number, 31536000)<br/><br/>    forwarded_values = optional(object({<br/>      query_string = bool<br/>      cookies = optional(object({<br/>        forward           = string<br/>        whitelisted_names = optional(list(string))<br/>      }))<br/>      headers = optional(list(string))<br/>    }))<br/><br/>    lambda_function_associations = optional(list(object({<br/>      event_type   = string<br/>      lambda_arn   = string<br/>      include_body = optional(bool, false)<br/>    })), [])<br/><br/>    function_associations = optional(list(object({<br/>      event_type   = string<br/>      function_arn = string<br/>    })), [])<br/><br/>    field_level_encryption_id = optional(string)<br/>    trusted_signers           = optional(list(string), [])<br/>    trusted_key_groups        = optional(list(string), [])<br/>    smooth_streaming          = optional(bool, false)<br/>  })</pre> | n/a | yes |
| <a name="input_default_root_object"></a> [default\_root\_object](#input\_default\_root\_object) | The object CloudFront returns when a user requests the root URL. Typically 'index.html' for S3-hosted websites. | `string` | `"index.html"` | no |
| <a name="input_distribution_name"></a> [distribution\_name](#input\_distribution\_name) | Name of the CloudFront distribution. Used for the comment field and resource naming. | `string` | n/a | yes |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether the distribution is enabled to accept end user requests for content. | `bool` | `true` | no |
| <a name="input_geo_restriction"></a> [geo\_restriction](#input\_geo\_restriction) | Geographic restrictions for content distribution.<br/><br/>- restriction\_type: none, whitelist, or blacklist<br/>- locations: List of ISO 3166-1-alpha-2 country codes (e.g., ["US", "CA", "GB"])<br/><br/>Set to null to disable geographic restrictions. | <pre>object({<br/>    restriction_type = string<br/>    locations        = optional(list(string), [])<br/>  })</pre> | <pre>{<br/>  "locations": [],<br/>  "restriction_type": "none"<br/>}</pre> | no |
| <a name="input_http_version"></a> [http\_version](#input\_http\_version) | Maximum HTTP version to support. Options: http1.1, http2, http2and3, http3. | `string` | `"http2and3"` | no |
| <a name="input_is_ipv6_enabled"></a> [is\_ipv6\_enabled](#input\_is\_ipv6\_enabled) | Whether IPv6 is enabled for the distribution. Recommended to leave enabled. | `bool` | `true` | no |
| <a name="input_logging_config"></a> [logging\_config](#input\_logging\_config) | Logging configuration for the distribution.<br/><br/>- bucket: S3 bucket domain name for logs (e.g., "logs.s3.amazonaws.com")<br/>- prefix: Optional prefix for log files<br/>- include\_cookies: Whether to include cookies in logs (default: false)<br/><br/>Set to null to disable logging. | <pre>object({<br/>    bucket          = string<br/>    prefix          = optional(string, "")<br/>    include_cookies = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_ordered_cache_behaviors"></a> [ordered\_cache\_behaviors](#input\_ordered\_cache\_behaviors) | List of ordered cache behaviors for specific path patterns.<br/>Evaluated in order, first match wins. Each behavior has the same structure as default\_cache\_behavior<br/>but requires a path\_pattern field. | <pre>list(object({<br/>    path_pattern           = string<br/>    target_origin_id       = string<br/>    viewer_protocol_policy = string<br/>    allowed_methods        = optional(list(string), ["GET", "HEAD", "OPTIONS"])<br/>    cached_methods         = optional(list(string), ["GET", "HEAD", "OPTIONS"])<br/>    compress               = optional(bool, true)<br/><br/>    cache_policy_id            = optional(string)<br/>    origin_request_policy_id   = optional(string)<br/>    response_headers_policy_id = optional(string)<br/>    realtime_log_config_arn    = optional(string)<br/><br/>    min_ttl     = optional(number, 0)<br/>    default_ttl = optional(number, 86400)<br/>    max_ttl     = optional(number, 31536000)<br/><br/>    forwarded_values = optional(object({<br/>      query_string = bool<br/>      cookies = optional(object({<br/>        forward           = string<br/>        whitelisted_names = optional(list(string))<br/>      }))<br/>      headers = optional(list(string))<br/>    }))<br/><br/>    lambda_function_associations = optional(list(object({<br/>      event_type   = string<br/>      lambda_arn   = string<br/>      include_body = optional(bool, false)<br/>    })), [])<br/><br/>    function_associations = optional(list(object({<br/>      event_type   = string<br/>      function_arn = string<br/>    })), [])<br/><br/>    field_level_encryption_id = optional(string)<br/>    trusted_signers           = optional(list(string), [])<br/>    trusted_key_groups        = optional(list(string), [])<br/>    smooth_streaming          = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_origin_access_control_description"></a> [origin\_access\_control\_description](#input\_origin\_access\_control\_description) | Description for the Origin Access Control. Only used if create\_origin\_access\_control is true. | `string` | `"Origin Access Control for CloudFront distribution"` | no |
| <a name="input_origin_access_control_name"></a> [origin\_access\_control\_name](#input\_origin\_access\_control\_name) | Name for the Origin Access Control. Only used if create\_origin\_access\_control is true. | `string` | `null` | no |
| <a name="input_origin_access_control_origin_type"></a> [origin\_access\_control\_origin\_type](#input\_origin\_access\_control\_origin\_type) | Origin type for OAC. Valid values: s3, mediastore. | `string` | `"s3"` | no |
| <a name="input_origin_access_control_signing_behavior"></a> [origin\_access\_control\_signing\_behavior](#input\_origin\_access\_control\_signing\_behavior) | Signing behavior for OAC. Valid values: always, never, no-override. | `string` | `"always"` | no |
| <a name="input_origin_access_control_signing_protocol"></a> [origin\_access\_control\_signing\_protocol](#input\_origin\_access\_control\_signing\_protocol) | Signing protocol for OAC. Valid values: sigv4. | `string` | `"sigv4"` | no |
| <a name="input_origins"></a> [origins](#input\_origins) | List of origins for this distribution. At least one origin is required.<br/><br/>Each origin must specify:<br/>- origin\_id: Unique identifier for this origin (referenced in cache behaviors)<br/>- domain\_name: The domain name of the origin (S3 bucket, ALB DNS, or custom domain)<br/><br/>For S3 origins, use either:<br/>- s3\_origin\_config with origin\_access\_control\_id (recommended)<br/>- s3\_origin\_config with origin\_access\_identity (legacy, deprecated)<br/><br/>For custom origins (ALB, API Gateway, web server), use:<br/>- custom\_origin\_config with protocol and SSL settings | <pre>list(object({<br/>    origin_id   = string<br/>    domain_name = string<br/>    origin_path = optional(string)<br/><br/>    s3_origin_config = optional(object({<br/>      origin_access_control_id = optional(string)<br/>      origin_access_identity   = optional(string)<br/>    }))<br/><br/>    custom_origin_config = optional(object({<br/>      http_port                = optional(number, 80)<br/>      https_port               = optional(number, 443)<br/>      origin_protocol_policy   = string<br/>      origin_ssl_protocols     = list(string)<br/>      origin_keepalive_timeout = optional(number, 5)<br/>      origin_read_timeout      = optional(number, 30)<br/>    }))<br/><br/>    custom_headers = optional(list(object({<br/>      name  = string<br/>      value = string<br/>    })), [])<br/><br/>    origin_shield = optional(object({<br/>      enabled              = bool<br/>      origin_shield_region = optional(string)<br/>    }))<br/><br/>    connection_attempts = optional(number, 3)<br/>    connection_timeout  = optional(number, 10)<br/>  }))</pre> | n/a | yes |
| <a name="input_price_class"></a> [price\_class](#input\_price\_class) | Price class determines which edge locations are used for content delivery.<br/><br/>- PriceClass\_100: US, Canada, Europe (lowest cost)<br/>- PriceClass\_200: PriceClass\_100 + Asia, Africa, South America (medium cost)<br/>- PriceClass\_All: All edge locations worldwide (highest cost, lowest latency) | `string` | `"PriceClass_All"` | no |
| <a name="input_retain_on_delete"></a> [retain\_on\_delete](#input\_retain\_on\_delete) | Whether to disable the distribution instead of deleting it when destroyed. Useful for preventing accidental deletion. | `bool` | `false` | no |
| <a name="input_staging"></a> [staging](#input\_staging) | Whether to create a staging distribution. Experimental feature for blue/green deployments. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. Use this to add consistent tagging across your infrastructure. | `map(string)` | `{}` | no |
| <a name="input_viewer_certificate"></a> [viewer\_certificate](#input\_viewer\_certificate) | SSL/TLS certificate configuration for the distribution.<br/><br/>For default CloudFront domain (*.cloudfront.net):<br/>- Set cloudfront\_default\_certificate = true<br/><br/>For custom domains (requires aliases):<br/>- Set acm\_certificate\_arn with certificate ARN (MUST be in us-east-1)<br/>- Set ssl\_support\_method to "sni-only" (recommended) or "vip" ($600/month for dedicated IP)<br/>- Set minimum\_protocol\_version (TLSv1.2\_2021 recommended) | <pre>object({<br/>    cloudfront_default_certificate = optional(bool, true)<br/>    acm_certificate_arn            = optional(string)<br/>    iam_certificate_id             = optional(string)<br/>    ssl_support_method             = optional(string, "sni-only")<br/>    minimum_protocol_version       = optional(string, "TLSv1.2_2021")<br/>  })</pre> | <pre>{<br/>  "cloudfront_default_certificate": true<br/>}</pre> | no |
| <a name="input_wait_for_deployment"></a> [wait\_for\_deployment](#input\_wait\_for\_deployment) | Whether to wait for the distribution deployment to complete. Deployments can take 15-30 minutes. | `bool` | `true` | no |
| <a name="input_web_acl_id"></a> [web\_acl\_id](#input\_web\_acl\_id) | AWS WAF Web ACL ARN to associate with the distribution for DDoS protection and security rules. Set to null to disable WAF. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_cache_behavior_target_origin_id"></a> [default\_cache\_behavior\_target\_origin\_id](#output\_default\_cache\_behavior\_target\_origin\_id) | The origin ID that the default cache behavior routes to. |
| <a name="output_distribution_aliases"></a> [distribution\_aliases](#output\_distribution\_aliases) | List of CNAMEs (alternate domain names) configured for the distribution. |
| <a name="output_distribution_arn"></a> [distribution\_arn](#output\_distribution\_arn) | The ARN of the CloudFront distribution. Use this for IAM policies and resource references. |
| <a name="output_distribution_comment"></a> [distribution\_comment](#output\_distribution\_comment) | The comment/name of the distribution. |
| <a name="output_distribution_domain_name"></a> [distribution\_domain\_name](#output\_distribution\_domain\_name) | The domain name of the CloudFront distribution (e.g., d123abc.cloudfront.net). Use this for DNS CNAME or A/AAAA alias records. |
| <a name="output_distribution_enabled"></a> [distribution\_enabled](#output\_distribution\_enabled) | Whether the distribution is enabled. |
| <a name="output_distribution_etag"></a> [distribution\_etag](#output\_distribution\_etag) | The current version ETag of the distribution. Used for updates and modifications. |
| <a name="output_distribution_hosted_zone_id"></a> [distribution\_hosted\_zone\_id](#output\_distribution\_hosted\_zone\_id) | The CloudFront Route 53 zone ID (Z2FDTNDATAQYW2). Use this for Route53 alias records pointing to the distribution. |
| <a name="output_distribution_http_version"></a> [distribution\_http\_version](#output\_distribution\_http\_version) | The maximum HTTP version supported by the distribution. |
| <a name="output_distribution_id"></a> [distribution\_id](#output\_distribution\_id) | The identifier for the CloudFront distribution. Use this for cache invalidations and CLI operations. |
| <a name="output_distribution_ipv6_enabled"></a> [distribution\_ipv6\_enabled](#output\_distribution\_ipv6\_enabled) | Whether IPv6 is enabled for the distribution. |
| <a name="output_distribution_price_class"></a> [distribution\_price\_class](#output\_distribution\_price\_class) | The price class of the distribution. |
| <a name="output_distribution_status"></a> [distribution\_status](#output\_distribution\_status) | The current status of the distribution (InProgress or Deployed). |
| <a name="output_distribution_url"></a> [distribution\_url](#output\_distribution\_url) | The full HTTPS URL of the CloudFront distribution. Use this to test the distribution. |
| <a name="output_invalidation_command"></a> [invalidation\_command](#output\_invalidation\_command) | AWS CLI command template for creating cache invalidations. |
| <a name="output_ordered_cache_behaviors_count"></a> [ordered\_cache\_behaviors\_count](#output\_ordered\_cache\_behaviors\_count) | The number of ordered cache behaviors configured. |
| <a name="output_origin_access_control_etag"></a> [origin\_access\_control\_etag](#output\_origin\_access\_control\_etag) | The ETag of the Origin Access Control resource, if created. |
| <a name="output_origin_access_control_id"></a> [origin\_access\_control\_id](#output\_origin\_access\_control\_id) | The ID of the Origin Access Control resource, if created. Use this in origin configurations. |
| <a name="output_origins"></a> [origins](#output\_origins) | List of origins configured for the distribution. |
| <a name="output_tags"></a> [tags](#output\_tags) | All tags applied to the distribution, including default and custom tags. |
| <a name="output_trusted_key_groups"></a> [trusted\_key\_groups](#output\_trusted\_key\_groups) | List of nested attributes for active trusted key groups configured for the distribution. |
| <a name="output_trusted_signers"></a> [trusted\_signers](#output\_trusted\_signers) | List of nested attributes for active trusted signers configured for the distribution. |
| <a name="output_viewer_certificate"></a> [viewer\_certificate](#output\_viewer\_certificate) | The SSL/TLS certificate configuration for the distribution. |
| <a name="output_web_acl_id"></a> [web\_acl\_id](#output\_web\_acl\_id) | The AWS WAF Web ACL ID associated with the distribution, if configured. |
<!-- END_TF_DOCS -->
</details>
