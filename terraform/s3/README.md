name: s3

This module creates a secure, production-ready S3 bucket that follows security best practices: versioning on by default, server-side encryption enabled, and public access blocked by default.

Usage example

```hcl
module "s3" {
  source = "../..//terraform/s3"

  # Provide either bucket_name OR bucket_prefix
  bucket_name   = "my-org-app-prod-logs"
  versioning_enabled = true
  encryption_algorithm = "AES256"

  tags = {
    Environment = "prod"
    Team        = "platform"
  }
}
```

Notes
- By default the module uses SSE-S3 (AES256). To use KMS, set encryption_algorithm = "aws:kms" and optionally provide kms_master_key_id.
- Lifecycle rules are optional and can be used to transition older objects to cheaper storage classes or expire them.
- Be careful with force_destroy = true — it will remove all objects in the bucket on destroy.

Outputs
- bucket_id: The bucket name
- bucket_arn: The bucket ARN
- bucket_domain_name: The bucket DNS name
