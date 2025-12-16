# CloudFront Terraform Module

A production-ready Terraform module for creating and managing Amazon CloudFront distributions with comprehensive support for all CloudFront features including Origin Access Control (OAC), Lambda@Edge, multiple origins, and advanced caching strategies.

## Features

- **Multiple Origin Support**: S3, ALB, API Gateway, and custom origins
- **Origin Access Control (OAC)**: Modern S3 access (replaces legacy OAI)
- **Advanced Caching**: Managed cache policies and custom TTL configurations
- **Edge Computing**: Lambda@Edge and CloudFront Functions integration
- **Security**: WAF integration, custom SSL certificates, signed URLs, geographic restrictions
- **Path-Based Routing**: Multiple cache behaviors with different origins and caching strategies
- **Custom Error Pages**: User-friendly error responses
- **Monitoring**: CloudWatch integration and access logging
- **Performance Optimization**: Origin Shield, HTTP/3, compression, price class selection

## Usage

### Basic S3 Static Website

```hcl
module "cloudfront_static_site" {
  source = "../../terraform/cloudfront"

  distribution_name   = "my-static-website"
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  # Create Origin Access Control for S3
  create_origin_access_control = true
  origin_access_control_name   = "my-site-oac"

  origins = [
    {
      origin_id   = "s3-origin"
      domain_name = "my-bucket.s3.us-east-1.amazonaws.com"

      s3_origin_config = {
        # Reference the created OAC ID
        origin_access_control_id = module.cloudfront_static_site.origin_access_control_id
      }
    }
  ]

  default_cache_behavior = {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = true

    # Use AWS managed cache policy for static content
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
  }

  viewer_certificate = {
    cloudfront_default_certificate = true
  }

  tags = {
    Environment = "production"
  }
}
```

### ALB Origin with Custom Domain

```hcl
module "cloudfront_alb" {
  source = "../../terraform/cloudfront"

  distribution_name = "my-api"
  enabled          = true
  price_class      = "PriceClass_All"

  aliases = ["api.example.com"]

  origins = [
    {
      origin_id   = "alb-origin"
      domain_name = "my-alb-1234567890.us-east-1.elb.amazonaws.com"

      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }

      # Custom header for origin security
      custom_headers = [
        {
          name  = "X-Custom-Secret"
          value = "secret-value-123"
        }
      ]
    }
  ]

  default_cache_behavior = {
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "https-only"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = true

    # Disable caching for dynamic content
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # AllViewer
  }

  viewer_certificate = {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Environment = "production"
  }
}
```

### Multi-Origin Setup (Static + Dynamic)

```hcl
module "cloudfront_hybrid" {
  source = "../../terraform/cloudfront"

  distribution_name   = "hybrid-app"
  enabled             = true
  default_root_object = "index.html"

  origins = [
    # S3 for static assets
    {
      origin_id   = "s3-static"
      domain_name = "static-assets.s3.amazonaws.com"

      s3_origin_config = {
        origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG"
      }
    },
    # ALB for API
    {
      origin_id   = "alb-api"
      domain_name = "api-alb.us-east-1.elb.amazonaws.com"

      custom_origin_config = {
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  ]

  # Default: serve static content from S3
  default_cache_behavior = {
    target_origin_id       = "s3-static"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = true
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  # Route /api/* to ALB
  ordered_cache_behaviors = [
    {
      path_pattern           = "/api/*"
      target_origin_id       = "alb-api"
      viewer_protocol_policy = "https-only"
      allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods         = ["GET", "HEAD", "OPTIONS"]
      compress               = true
      cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    }
  ]

  viewer_certificate = {
    cloudfront_default_certificate = true
  }

  tags = {
    Environment = "production"
  }
}
```

## AWS Managed Cache Policies

Common AWS managed cache policies that you can use:

| Policy ID | Name | Use Case |
|-----------|------|----------|
| `658327ea-f89d-4fab-a63d-7e88639e58f6` | CachingOptimized | Static content (recommended default) |
| `4135ea2d-6df8-44a3-9df3-4b5a84be39ad` | CachingDisabled | Dynamic content, APIs |
| `b2884449-e4de-46a7-ac36-70bc7f1ddd6d` | CachingOptimizedForUncompressedObjects | Images, videos |
| `08627262-05a9-4f76-9ded-b50ca2e3a84f` | Elemental-MediaPackage | Video streaming |

## Origin Access Control (OAC) vs OAI

### Origin Access Control (OAC) - **Recommended**

- ✅ Supports SSE-KMS encryption
- ✅ Supports all AWS regions
- ✅ Works with S3 bucket policies using service principal
- ✅ Supports dynamic requests (PUT, POST, DELETE)
- ✅ Future-proof, actively maintained

### Origin Access Identity (OAI) - **Legacy**

- ❌ Limited to SSE-S3 encryption
- ❌ Does not support some S3 features
- ❌ Deprecated by AWS
- ⚠️ Use only for existing distributions

### S3 Bucket Policy for OAC

When using OAC, apply this policy to your S3 bucket:

```json
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
      "Resource": "arn:aws:s3:::your-bucket-name/*",
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": "arn:aws:cloudfront::123456789012:distribution/E1234567890ABC"
        }
      }
    }
  ]
}
```

## Cache Behavior Patterns

### Static Assets (Images, CSS, JS)

```hcl
{
  target_origin_id       = "s3-origin"
  viewer_protocol_policy = "redirect-to-https"
  allowed_methods        = ["GET", "HEAD", "OPTIONS"]
  cached_methods         = ["GET", "HEAD", "OPTIONS"]
  compress               = true
  cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  min_ttl                = 31536000  # 1 year
  default_ttl            = 31536000
  max_ttl                = 31536000
}
```

### Dynamic Content (API, HTML)

```hcl
{
  target_origin_id         = "alb-origin"
  viewer_protocol_policy   = "https-only"
  allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
  cached_methods           = ["GET", "HEAD", "OPTIONS"]
  compress                 = true
  cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
  min_ttl                  = 0
  default_ttl              = 0
  max_ttl                  = 0
}
```

### Private Content (Signed URLs)

```hcl
{
  target_origin_id       = "s3-origin"
  viewer_protocol_policy = "https-only"
  allowed_methods        = ["GET", "HEAD"]
  cached_methods         = ["GET", "HEAD"]
  compress               = true
  cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  trusted_key_groups     = ["key-group-id"]
  min_ttl                = 300
  default_ttl            = 3600
  max_ttl                = 86400
}
```

## Lambda@Edge vs CloudFront Functions

### CloudFront Functions

**Best for:**
- URL rewrites and redirects
- Header manipulation
- Access control based on request headers
- Simple string operations

**Characteristics:**
- ⚡ Sub-millisecond execution
- 📍 Viewer request and viewer response events only
- 💻 JavaScript (ES5.1)
- 📦 < 10KB code size
- 💰 Most cost-effective

**Example use cases:**
```javascript
// URL rewrite
function handler(event) {
    var request = event.request;
    if (request.uri.endsWith('/')) {
        request.uri += 'index.html';
    }
    return request;
}
```

### Lambda@Edge

**Best for:**
- Complex request/response manipulation
- External API calls
- A/B testing with cookies
- Image resizing
- Origin selection logic

**Characteristics:**
- ⚡ Millisecond execution
- 📍 All four events (viewer/origin request/response)
- 💻 Node.js or Python
- 📦 Up to 50MB (viewer), 1MB (origin)
- 💰 Higher cost than CloudFront Functions

**Example use cases:**
```javascript
// A/B testing
exports.handler = async (event) => {
    const request = event.Records[0].cf.request;
    const variant = Math.random() < 0.5 ? 'A' : 'B';
    request.headers['x-variant'] = [{ value: variant }];
    return request;
};
```

## Price Class Selection

Choose based on geographic distribution of users and budget:

| Price Class | Edge Locations | Use Case |
|-------------|----------------|----------|
| `PriceClass_100` | US, Canada, Europe | Lowest cost, users primarily in these regions |
| `PriceClass_200` | Above + Asia, Africa, South America | Medium cost, global except Australia |
| `PriceClass_All` | All edge locations worldwide | Highest cost, lowest latency globally |

## Error Page Best Practices

### Single Page Application (SPA) Pattern

Redirect 403/404 to index.html for client-side routing:

```hcl
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
```

### Custom Error Pages

Provide user-friendly error pages:

```hcl
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
    error_caching_min_ttl = 60  # Lower TTL for quick recovery
  }
]
```

## Custom Headers for Origin Security

Prevent direct origin access by validating custom headers:

**CloudFront Configuration:**
```hcl
custom_headers = [
  {
    name  = "X-Custom-Secret"
    value = "super-secret-value-12345"
  }
]
```

**ALB Listener Rule:**
- Only accept requests with correct `X-Custom-Secret` header
- Reject all other requests (403 Forbidden)

**Application Code:**
```python
# Example in Python/Flask
@app.before_request
def verify_cloudfront():
    if request.headers.get('X-Custom-Secret') != 'super-secret-value-12345':
        abort(403)
```

## Cache Invalidation

### AWS CLI

```bash
# Invalidate specific paths
aws cloudfront create-invalidation \
  --distribution-id E1234567890ABC \
  --paths "/index.html" "/css/*" "/js/*"

# Invalidate everything (costs more after 1,000 paths/month)
aws cloudfront create-invalidation \
  --distribution-id E1234567890ABC \
  --paths "/*"
```

### Cost Optimization

- **First 1,000 paths/month**: Free
- **Additional paths**: $0.005 per path
- **Best practice**: Use versioned filenames instead (e.g., `app.v123.js`)

### Terraform

```hcl
resource "aws_cloudfront_invalidation" "example" {
  distribution_id = module.cloudfront.distribution_id
  paths           = ["/*"]
}
```

## Real-World Use Cases

### 1. Static Website (S3 + CloudFront + Route53)

```
User → Route53 → CloudFront → S3 (via OAC)
```

- Host static site in S3
- Use OAC for secure access
- Custom domain with SSL certificate
- Aggressive caching (1 year TTL)

### 2. Single-Page Application (SPA)

```
User → CloudFront → S3 (HTML/JS/CSS)
                  → ALB (API)
```

- Serve static assets from S3
- Route `/api/*` to ALB
- Custom error pages for client-side routing
- Different cache policies per path

### 3. Media Streaming

```
User → CloudFront → S3 (videos) + MediaConvert
```

- Use `CachingOptimizedForUncompressedObjects` policy
- HTTP/3 for better streaming performance
- Origin Shield to reduce S3 costs
- No compression for media files

### 4. API Acceleration

```
User → CloudFront → API Gateway/ALB
```

- Disable caching (`CachingDisabled` policy)
- Global edge locations reduce latency
- WAF for DDoS protection
- Custom headers for origin authentication

### 5. Private Content Delivery

```
User (with signed URL) → CloudFront → S3
```

- Trusted key groups for signing
- Short TTL for security
- Signed URLs with expiration
- Restrict geographic access if needed

## CloudFront-Specific Considerations

### Global Service
- CloudFront is a global service, always in `us-east-1` region
- ACM certificates MUST be in `us-east-1` for CloudFront

### Deployment Time
- Initial distribution creation: 15-30 minutes
- Distribution updates: 15-30 minutes
- Use `wait_for_deployment = false` to skip waiting (not recommended for production)

### Lambda@Edge Regions
- Lambda functions must be in `us-east-1`
- Functions are automatically replicated to edge locations
- Use qualified ARN with version number (not `$LATEST`)

### HTTP/3 (QUIC)
- Requires `http_version = "http2and3"` or `http3"`
- Provides better performance over unreliable networks
- Supported by modern browsers

### Origin Shield
- Additional caching layer between edge and origin
- Reduces origin load and costs
- Recommended for high-traffic origins
- Choose region closest to your origin

## Security Best Practices

1. **Always use HTTPS**: Set `viewer_protocol_policy = "https-only"` or `"redirect-to-https"`
2. **TLS 1.2 or higher**: Set `minimum_protocol_version = "TLSv1.2_2021"`
3. **Use OAC for S3**: Prefer Origin Access Control over legacy OAI
4. **Enable WAF**: Protect against DDoS and common attacks
5. **Custom origin headers**: Prevent direct origin access
6. **Signed URLs/Cookies**: Protect premium content
7. **Geographic restrictions**: Comply with licensing/legal requirements
8. **Field-level encryption**: Encrypt sensitive POST data at edge

## Performance Optimization

1. **Enable compression**: `compress = true` for text content
2. **HTTP/3**: Use `http_version = "http2and3"` for modern clients
3. **Origin Shield**: Reduce origin load for high-traffic sites
4. **Appropriate TTL**: Balance freshness vs. cache hit rate
5. **Price class**: Choose based on user distribution
6. **IPv6**: Keep `is_ipv6_enabled = true` for modern devices

## Monitoring and Logging

### Access Logs

```hcl
logging_config = {
  bucket          = "logs.s3.amazonaws.com"
  prefix          = "cloudfront/"
  include_cookies = false
}
```

### CloudWatch Metrics

CloudFront automatically provides metrics:
- Requests
- Bytes downloaded/uploaded
- Error rates (4xx, 5xx)
- Cache hit rate

### Real-time Logs

For advanced monitoring, configure real-time logs to Kinesis Data Streams.

## Module Inputs

See [variables.tf](variables.tf) for all available input variables.

## Module Outputs

See [outputs.tf](outputs.tf) for all available outputs.

## Testing

The module includes comprehensive tests:

- `tests/basic/`: Basic S3 origin with default settings
- `tests/alb_origin/`: ALB custom origin with custom headers
- `tests/multi_origin/`: Multiple origins with path-based routing
- `tests/s3_oac/`: S3 with Origin Access Control (OAC)
- `tests/lambda_edge/`: Lambda@Edge and CloudFront Functions

Run tests:

```bash
cd tests/basic
terraform init
terraform plan
```

## License

Apache 2.0 Licensed. See LICENSE for full details.

## Authors

Maintained by the infrastructure team.

## References

- [AWS CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [CloudFront Developer Guide](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/)
- [Lambda@Edge Guide](https://docs.aws.amazon.com/lambda/latest/dg/lambda-edge.html)
- [CloudFront Functions Guide](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cloudfront-functions.html)
