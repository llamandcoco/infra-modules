# AWS S3 Bucket Terraform Module

Production-ready Terraform module for creating secure, well-configured AWS S3 buckets with versioning, encryption, and lifecycle management.

## Features

- **Security First**: Encryption enabled by default (SSE-S3 or SSE-KMS)
- **Public Access Protection**: All public access blocked by default
- **Versioning**: Enabled by default to protect against accidental deletion
- **Lifecycle Management**: Flexible lifecycle rules for cost optimization
- **Compliance Ready**: Follows AWS security best practices
- **Fully Tested**: Includes test configurations and passes trivy security scans

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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
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
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | Block public ACLs on this bucket. Recommended to keep enabled for security. | `bool` | `true` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | Block public bucket policies on this bucket. Recommended to keep enabled for security. | `bool` | `true` | no |
| <a name="input_bucket_key_enabled"></a> [bucket\_key\_enabled](#input\_bucket\_key\_enabled) | Enable S3 Bucket Keys to reduce KMS costs by decreasing request traffic from S3 to KMS. Only applies when using KMS encryption. | `bool` | `true` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the S3 bucket. Must be globally unique across all AWS accounts. | `string` | n/a | yes |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Allow deletion of non-empty bucket. Use with caution in production environments. | `bool` | `false` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | Ignore public ACLs on this bucket. Recommended to keep enabled for security. | `bool` | `true` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN of the KMS key to use for SSE-KMS encryption. If not specified, SSE-S3 (AES256) encryption will be used. | `string` | `null` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | List of lifecycle rules to manage object transitions and expiration.<br/>Each rule can include:<br/>- id: Unique identifier for the rule<br/>- enabled: Whether the rule is active<br/>- prefix: Object key prefix to apply the rule (optional)<br/>- tags: Map of tags to filter objects (optional)<br/>- transitions: List of storage class transitions with days and storage\_class<br/>- expiration\_days: Number of days until objects expire (optional)<br/>- abort\_incomplete\_multipart\_upload\_days: Days to abort incomplete uploads (optional)<br/>- noncurrent\_version\_transitions: List of transitions for old versions (optional)<br/>- noncurrent\_version\_expiration\_days: Days until old versions expire (optional) | <pre>list(object({<br/>    id      = string<br/>    enabled = bool<br/>    prefix  = optional(string)<br/>    tags    = optional(map(string), {})<br/>    transitions = optional(list(object({<br/>      days          = number<br/>      storage_class = string<br/>    })), [])<br/>    expiration_days                        = optional(number)<br/>    abort_incomplete_multipart_upload_days = optional(number)<br/>    noncurrent_version_transitions = optional(list(object({<br/>      days          = number<br/>      storage_class = string<br/>    })), [])<br/>    noncurrent_version_expiration_days = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_logging_target_bucket"></a> [logging\_target\_bucket](#input\_logging\_target\_bucket) | Name of the target bucket for access logs. If not specified, logging is disabled. The target bucket must exist and have appropriate permissions. | `string` | `null` | no |
| <a name="input_logging_target_prefix"></a> [logging\_target\_prefix](#input\_logging\_target\_prefix) | Prefix for access log objects stored in the target bucket. Only used if logging\_target\_bucket is specified. | `string` | `"logs/"` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | Restrict public bucket policies for this bucket. Recommended to keep enabled for security. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. Use this to add consistent tagging across your infrastructure. | `map(string)` | `{}` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Enable versioning to protect against accidental deletion and provide object history. Recommended for production buckets. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | The ARN of the S3 bucket. Use this for IAM policies and cross-account access configurations. |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | The bucket domain name. Use this for CloudFront distributions or direct S3 website hosting. |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | The name/ID of the S3 bucket. Use this for bucket policy references and other resource configurations. |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | The name of the bucket (same as bucket\_id). Provided for convenience and clarity in module outputs. |
| <a name="output_bucket_region"></a> [bucket\_region](#output\_bucket\_region) | The AWS region where the bucket is deployed. |
| <a name="output_bucket_regional_domain_name"></a> [bucket\_regional\_domain\_name](#output\_bucket\_regional\_domain\_name) | The bucket region-specific domain name. Use this when you need region-specific endpoints. |
| <a name="output_encryption_algorithm"></a> [encryption\_algorithm](#output\_encryption\_algorithm) | The server-side encryption algorithm used (AES256 for SSE-S3, aws:kms for SSE-KMS). |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | The KMS key ID used for encryption, if SSE-KMS is enabled. |
| <a name="output_tags"></a> [tags](#output\_tags) | All tags applied to the bucket, including default and custom tags. |
| <a name="output_versioning_enabled"></a> [versioning\_enabled](#output\_versioning\_enabled) | Whether versioning is enabled on the bucket. Important for compliance and data protection verification. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

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
