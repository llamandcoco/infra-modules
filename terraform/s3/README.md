# AWS S3 Bucket Terraform Module

Production-ready Terraform module for creating secure, well-configured AWS S3 buckets with versioning, encryption, and lifecycle management.

## Features

- **Security First**: Encryption enabled by default (SSE-S3 or SSE-KMS)
- **Public Access Protection**: All public access blocked by default
- **Versioning**: Enabled by default to protect against accidental deletion
- **Lifecycle Management**: Flexible lifecycle rules for cost optimization
- **Compliance Ready**: Follows AWS security best practices
- **Fully Tested**: Includes test configurations and passes tfsec security scans

## Usage

### Basic Example

```hcl
module "my_bucket" {
  source = "github.com/your-org/infra-modules//terraform/s3?ref=v1.0.0"

  bucket_name = "my-application-data-bucket"

  tags = {
    Environment = "production"
    Application = "my-app"
    ManagedBy   = "terraform"
  }
}
```

### Advanced Example with KMS Encryption

```hcl
module "secure_bucket" {
  source = "github.com/your-org/infra-modules//terraform/s3?ref=v1.0.0"

  bucket_name = "my-secure-bucket"

  # Use KMS encryption instead of SSE-S3
  kms_key_id         = aws_kms_key.my_key.arn
  bucket_key_enabled = true

  # Enable versioning for compliance
  versioning_enabled = true

  tags = {
    Environment = "production"
    Compliance  = "required"
    DataClass   = "sensitive"
  }
}
```

### Example with Lifecycle Rules

```hcl
module "archive_bucket" {
  source = "github.com/your-org/infra-modules//terraform/s3?ref=v1.0.0"

  bucket_name = "my-archive-bucket"

  # Define lifecycle rules for cost optimization
  lifecycle_rules = [
    {
      id      = "archive-old-data"
      enabled = true
      prefix  = "logs/"

      # Transition to cheaper storage classes over time
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER_IR"
        },
        {
          days          = 180
          storage_class = "GLACIER"
        }
      ]

      # Delete objects after 7 years
      expiration_days = 2555

      # Clean up incomplete multipart uploads
      abort_incomplete_multipart_upload_days = 7

      # Manage old versions
      noncurrent_version_transitions = [
        {
          days          = 30
          storage_class = "GLACIER"
        }
      ]
      noncurrent_version_expiration_days = 90
    }
  ]

  tags = {
    Environment = "production"
    Purpose     = "archival"
  }
}
```

### Example with Public Access (Use with Caution)

```hcl
module "public_bucket" {
  source = "github.com/your-org/infra-modules//terraform/s3?ref=v1.0.0"

  bucket_name = "my-public-assets"

  # Allow public access (for static website hosting, CDN, etc.)
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  tags = {
    Environment = "production"
    Purpose     = "public-assets"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_versioning.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_public_access_block.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_lifecycle_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | Name of the S3 bucket. Must be globally unique across all AWS accounts. | `string` | n/a | yes |
| versioning_enabled | Enable versioning to protect against accidental deletion and provide object history. | `bool` | `true` | no |
| kms_key_id | ARN of the KMS key to use for SSE-KMS encryption. If not specified, SSE-S3 (AES256) encryption will be used. | `string` | `null` | no |
| bucket_key_enabled | Enable S3 Bucket Keys to reduce KMS costs. Only applies when using KMS encryption. | `bool` | `true` | no |
| block_public_acls | Block public ACLs on this bucket. Recommended to keep enabled for security. | `bool` | `true` | no |
| block_public_policy | Block public bucket policies on this bucket. Recommended to keep enabled for security. | `bool` | `true` | no |
| ignore_public_acls | Ignore public ACLs on this bucket. Recommended to keep enabled for security. | `bool` | `true` | no |
| restrict_public_buckets | Restrict public bucket policies for this bucket. Recommended to keep enabled for security. | `bool` | `true` | no |
| lifecycle_rules | List of lifecycle rules to manage object transitions and expiration. | `list(object)` | `[]` | no |
| force_destroy | Allow deletion of non-empty bucket. Use with caution in production. | `bool` | `false` | no |
| tags | A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | The name/ID of the S3 bucket. |
| bucket_arn | The ARN of the S3 bucket. |
| bucket_domain_name | The bucket domain name. |
| bucket_regional_domain_name | The bucket region-specific domain name. |
| bucket_region | The AWS region where the bucket is deployed. |
| versioning_enabled | Whether versioning is enabled on the bucket. |
| encryption_algorithm | The server-side encryption algorithm used. |
| kms_key_id | The KMS key ID used for encryption, if SSE-KMS is enabled. |
| bucket_name | The name of the bucket. |
| tags | All tags applied to the bucket. |

## Security Considerations

### Default Security Posture

This module implements security best practices by default:

1. **Encryption**: All objects are encrypted at rest using SSE-S3 (AES256) by default
2. **Public Access**: All public access is blocked by default
3. **Versioning**: Enabled by default to protect against accidental deletion
4. **Force Destroy**: Disabled by default to prevent accidental data loss

### Using KMS Encryption

For sensitive data, use KMS encryption:

```hcl
kms_key_id = aws_kms_key.my_key.arn
```

Benefits:
- Audit trail of encryption key usage in CloudTrail
- Fine-grained access control via KMS key policies
- Automatic key rotation (if enabled on KMS key)

Consider enabling S3 Bucket Keys to reduce KMS API costs:

```hcl
bucket_key_enabled = true  # Default
```

### Lifecycle Best Practices

Use lifecycle rules to:
1. Reduce storage costs by transitioning to cheaper storage classes
2. Meet compliance requirements for data retention
3. Clean up incomplete multipart uploads
4. Manage versioned objects efficiently

## Testing

Run the basic test:

```bash
cd tests/basic
terraform init -backend=false
terraform plan
```

## Contributing

This module serves as a reference implementation. When creating new modules:
- Follow the same structure and naming conventions
- Include comprehensive variable validation
- Add detailed descriptions for all inputs and outputs
- Create at least one test case
- Document security considerations

## License

See repository LICENSE file for details.
