# S3

Production-ready S3 bucket module demonstrating secure defaults and clear patterns for other AWS modules.

## Usage

```hcl
module "logging_bucket" {
  source = "github.com/your-org/infra-modules//terraform/s3"

  bucket_name        = "my-logging-bucket"
  encryption_type    = "SSE-KMS"             # use your own key when required
  kms_key_id         = "arn:aws:kms:us-east-1:123456789012:key/abcd-1234"
  versioning_enabled = true

  lifecycle_rules = [
    {
      id                                     = "glacier-archive"
      enabled                                = true
      prefix                                 = "logs/"
      expiration_days                        = 365
      noncurrent_version_expiration_days     = 90
      abort_incomplete_multipart_upload_days = 7
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 180
          storage_class = "GLACIER"
        }
      ]
    }
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

For a minimal setup that still enforces secure defaults:

```hcl
module "basic_bucket" {
  source = "github.com/your-org/infra-modules//terraform/s3"

  bucket_name = "my-basic-bucket"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_block_public_acls"></a> [block_public_acls](#input_block_public_acls) | Whether Amazon S3 should block public ACLs for this bucket. | `bool` | `true` | no |
| <a name="input_block_public_policy"></a> [block_public_policy](#input_block_public_policy) | Whether Amazon S3 should block public bucket policies for this bucket. | `bool` | `true` | no |
| <a name="input_bucket_key_enabled"></a> [bucket_key_enabled](#input_bucket_key_enabled) | Enable S3 Bucket Keys when using SSE-KMS to reduce cost. Ignored for SSE-S3. | `bool` | `true` | no |
| <a name="input_bucket_name"></a> [bucket_name](#input_bucket_name) | Unique name for the S3 bucket. Use lowercase letters, numbers, and hyphens only. | `string` | n/a | yes |
| <a name="input_encryption_type"></a> [encryption_type](#input_encryption_type) | Server-side encryption type to apply. Use SSE-KMS to bring your own KMS key. | `string` | "SSE-S3" | no |
| <a name="input_force_destroy"></a> [force_destroy](#input_force_destroy) | When true, bucket and all objects are destroyed without recovery. Use cautiously. | `bool` | `false` | no |
| <a name="input_ignore_public_acls"></a> [ignore_public_acls](#input_ignore_public_acls) | Whether Amazon S3 should ignore public ACLs for this bucket. | `bool` | `true` | no |
| <a name="input_kms_key_id"></a> [kms_key_id](#input_kms_key_id) | KMS key ARN or ID to use when encryption_type is SSE-KMS. Leave null to use default S3 key. | `string` | `null` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle_rules](#input_lifecycle_rules) | Lifecycle rules to apply to the bucket. Leave empty to disable lifecycle configuration. | `list(object({ id = string, enabled = bool, prefix = optional(string), expiration_days = optional(number), noncurrent_version_expiration_days = optional(number), abort_incomplete_multipart_upload_days = optional(number), transitions = optional(list(object({ days = number, storage_class = string })), []) }))` | `[]` | no |
| <a name="input_public_access_block_enabled"></a> [public_access_block_enabled](#input_public_access_block_enabled) | Create a public access block to prevent accidental public exposure. | `bool` | `true` | no |
| <a name="input_restrict_public_buckets"></a> [restrict_public_buckets](#input_restrict_public_buckets) | Whether Amazon S3 should restrict public bucket policies for this bucket. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input_tags) | A map of tags to add to all resources. Name is automatically set to bucket_name. | `map(string)` | `{}` | no |
| <a name="input_versioning_enabled"></a> [versioning_enabled](#input_versioning_enabled) | Enable object versioning. Recommended for auditability and recovery. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket_arn](#output_bucket_arn) | The ARN of the S3 bucket. |
| <a name="output_bucket_domain_name"></a> [bucket_domain_name](#output_bucket_domain_name) | The bucket domain name (legacy global endpoint). |
| <a name="output_bucket_hosted_zone_id"></a> [bucket_hosted_zone_id](#output_bucket_hosted_zone_id) | The Route 53 hosted zone ID for the bucket endpoint. |
| <a name="output_bucket_id"></a> [bucket_id](#output_bucket_id) | The name of the S3 bucket. |
| <a name="output_bucket_regional_domain_name"></a> [bucket_regional_domain_name](#output_bucket_regional_domain_name) | The bucket regional domain name. |
| <a name="output_public_access_block"></a> [public_access_block](#output_public_access_block) | Public access block configuration applied to the bucket. Null when disabled. |
| <a name="output_versioning_status"></a> [versioning_status](#output_versioning_status) | Current versioning status (Enabled or Suspended). |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
