# S3 Bucket Module

Production-ready Terraform module for creating secure AWS S3 buckets with best practices enabled by default.

## Features

- **Secure by Default**: Encryption enabled, public access blocked, versioning enabled
- **Flexible Encryption**: Support for both SSE-S3 and SSE-KMS encryption
- **Lifecycle Management**: Optional lifecycle rules for transitioning and expiring objects
- **Comprehensive Outputs**: All common bucket attributes available as outputs
- **Validation**: Input validation to prevent common configuration mistakes

## Usage

### Basic Usage

```hcl
module "s3_bucket" {
  source = "github.com/llamandcoco/infra-modules//terraform/s3?ref=v1.0.0"

  bucket_name = "my-application-data-bucket"
  
  tags = {
    Environment = "production"
    Application = "my-app"
  }
}
```

### Advanced Usage with KMS Encryption

```hcl
module "s3_bucket" {
  source = "github.com/llamandcoco/infra-modules//terraform/s3?ref=v1.0.0"

  bucket_name       = "my-application-data-bucket"
  encryption_type   = "aws:kms"
  kms_master_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  
  tags = {
    Environment = "production"
    Application = "my-app"
  }
}
```

### Advanced Usage with Lifecycle Rules

```hcl
module "s3_bucket" {
  source = "github.com/llamandcoco/infra-modules//terraform/s3?ref=v1.0.0"

  bucket_name = "my-application-logs-bucket"
  
  lifecycle_rules = [
    {
      id      = "archive-old-logs"
      enabled = true
      filter_prefix = "logs/"
      
      transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
        },
        {
          days          = 180
          storage_class = "GLACIER"
        }
      ]
      
      expiration = {
        days = 365
      }
    }
  ]
  
  tags = {
    Environment = "production"
    Application = "my-app"
    DataType    = "logs"
  }
}
```

## Security Considerations

This module implements AWS S3 security best practices:

1. **Encryption at Rest**: All buckets are encrypted by default using SSE-S3 (AES-256)
2. **Public Access Blocking**: All public access is blocked by default
3. **Versioning**: Enabled by default to protect against accidental deletions
4. **Force Destroy Protection**: Disabled by default to prevent accidental data loss

### Security Recommendations

- Use KMS encryption (`encryption_type = "aws:kms"`) for sensitive data
- Enable MFA Delete in production environments (configure via AWS CLI)
- Implement bucket policies for fine-grained access control
- Enable S3 access logging for audit trails
- Use lifecycle policies to reduce storage costs and comply with data retention policies

## Examples

See the [tests](./tests/) directory for complete working examples:

- [Basic Example](./tests/basic/main.tf) - Minimal configuration
- Additional examples can be added as needed

## Testing

To test this module locally:

```bash
cd tests/basic
terraform init -backend=false
terraform plan
```

## Migration Guide

If migrating from legacy S3 bucket configurations (single `aws_s3_bucket` resource with inline configurations), note that AWS Provider v4.0+ requires separate resources for:

- Versioning: `aws_s3_bucket_versioning`
- Encryption: `aws_s3_bucket_server_side_encryption_configuration`
- Public Access Block: `aws_s3_bucket_public_access_block`
- Lifecycle: `aws_s3_bucket_lifecycle_configuration`

This module follows the current AWS provider patterns.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
