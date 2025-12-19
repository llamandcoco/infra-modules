# Google Cloud Storage (GCS) Bucket Terraform Module

Production-ready Terraform module for creating secure, well-configured Google Cloud Storage buckets with versioning, encryption, and lifecycle management.

## Features

- **Security First**: Google-managed encryption by default, optional CMEK support
- **Public Access Prevention**: Public access blocked by default
- **Versioning**: Enabled by default to protect against accidental deletion
- **Uniform Bucket-Level Access**: IAM-only access control enabled by default
- **Lifecycle Management**: Flexible lifecycle rules for cost optimization
- **Compliance Ready**: Follows Google Cloud security best practices
- **Fully Tested**: Includes test configurations and passes trivy security scans

## Usage

### Basic Example

```hcl
module "my_bucket" {
  source = "github.com/your-org/infra-modules//terraform/gcp?ref=v1.0.0"

  bucket_name = "my-application-data-bucket"
  location    = "us-central1"

  labels = {
    environment = "production"
    application = "my-app"
    managed_by  = "terraform"
  }
}
```

### Advanced Example with CMEK Encryption

```hcl
module "secure_bucket" {
  source = "github.com/your-org/infra-modules//terraform/gcp?ref=v1.0.0"

  bucket_name = "my-secure-bucket"
  location    = "us-central1"

  # Use Customer-Managed Encryption Key (CMEK) instead of Google-managed
  encryption_key_name = "projects/my-project/locations/us-central1/keyRings/my-keyring/cryptoKeys/my-key"

  # Enable versioning for compliance
  versioning_enabled = true

  # Uniform bucket-level access for IAM-only control
  uniform_bucket_level_access = true

  labels = {
    environment = "production"
    compliance  = "required"
    data_class  = "sensitive"
  }
}
```

### Example with Lifecycle Rules

```hcl
module "archive_bucket" {
  source = "github.com/your-org/infra-modules//terraform/gcp?ref=v1.0.0"

  bucket_name = "my-archive-bucket"
  location    = "us"  # Multi-region

  # Define lifecycle rules for cost optimization
  lifecycle_rules = [
    {
      action_type          = "SetStorageClass"
      action_storage_class = "NEARLINE"
      age                  = 30
      matches_prefix       = ["logs/"]
      with_state          = "LIVE"
    },
    {
      action_type          = "SetStorageClass"
      action_storage_class = "COLDLINE"
      age                  = 90
      matches_prefix       = ["logs/"]
      with_state          = "LIVE"
    },
    {
      action_type          = "SetStorageClass"
      action_storage_class = "ARCHIVE"
      age                  = 180
      matches_prefix       = ["logs/"]
      with_state          = "LIVE"
    },
    {
      action_type    = "Delete"
      age            = 2555  # 7 years
      matches_prefix = ["logs/"]
      with_state    = "LIVE"
    },
    {
      action_type        = "Delete"
      num_newer_versions = 3
      with_state        = "ARCHIVED"
    },
    {
      action_type = "AbortIncompleteMultipartUpload"
      age         = 7
    }
  ]

  labels = {
    environment = "production"
    purpose     = "archival"
  }
}
```

### Example with Logging

```hcl
# First, create a bucket for logs
module "logs_bucket" {
  source = "github.com/your-org/infra-modules//terraform/gcp?ref=v1.0.0"

  bucket_name = "my-logs-bucket"
  location    = "us-central1"

  labels = {
    environment = "production"
    purpose     = "logging"
  }
}

# Then, create a bucket with logging enabled
module "monitored_bucket" {
  source = "github.com/your-org/infra-modules//terraform/gcp?ref=v1.0.0"

  bucket_name = "my-monitored-bucket"
  location    = "us-central1"

  logging_config = {
    log_bucket        = module.logs_bucket.bucket_name
    log_object_prefix = "bucket-access-logs/"
  }

  labels = {
    environment = "production"
    purpose     = "data-storage"
  }
}
```

### Example with Public Access (Use with Caution)

```hcl
module "public_bucket" {
  source = "github.com/your-org/infra-modules//terraform/gcp?ref=v1.0.0"

  bucket_name = "my-public-assets"
  location    = "us"

  # Allow public access (for static website hosting, CDN, etc.)
  public_access_prevention = "inherited"
  # Note: You'll also need to set appropriate IAM bindings for public access

  labels = {
    environment = "production"
    purpose     = "public-assets"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.45.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_storage_bucket.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the GCS bucket. Must be globally unique across all Google Cloud projects. | `string` | n/a | yes |
| <a name="input_encryption_key_name"></a> [encryption\_key\_name](#input\_encryption\_key\_name) | The full resource name of the Cloud KMS key to use for default encryption. If not specified, Google-managed encryption keys will be used. Format: projects/PROJECT\_ID/locations/LOCATION/keyRings/KEY\_RING/cryptoKeys/KEY\_NAME | `string` | `null` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Allow deletion of non-empty bucket. Use with caution in production environments as this will permanently delete all objects. | `bool` | `false` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | A map of labels (key-value pairs) to add to the bucket. Use this to add consistent labeling across your infrastructure. | `map(string)` | `{}` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | List of lifecycle rules to manage object transitions and deletion.<br/>Each rule supports:<br/>- action\_type: Type of action (Delete, SetStorageClass, AbortIncompleteMultipartUpload)<br/>- action\_storage\_class: Target storage class for SetStorageClass action<br/>- age: Age of object in days<br/>- created\_before: Date in RFC 3339 format (e.g., "2023-01-15")<br/>- custom\_time\_before: Date in RFC 3339 format for custom time metadata<br/>- days\_since\_custom\_time: Days since custom time<br/>- days\_since\_noncurrent\_time: Days since object became noncurrent<br/>- noncurrent\_time\_before: Date in RFC 3339 format<br/>- num\_newer\_versions: Number of newer versions to keep<br/>- with\_state: Match objects with state (LIVE, ARCHIVED, ANY)<br/>- matches\_prefix: List of prefixes to match<br/>- matches\_suffix: List of suffixes to match<br/>- matches\_storage\_class: List of storage classes to match | <pre>list(object({<br/>    action_type                = string<br/>    action_storage_class       = optional(string)<br/>    age                        = optional(number)<br/>    created_before             = optional(string)<br/>    custom_time_before         = optional(string)<br/>    days_since_custom_time     = optional(number)<br/>    days_since_noncurrent_time = optional(number)<br/>    noncurrent_time_before     = optional(string)<br/>    num_newer_versions         = optional(number)<br/>    with_state                 = optional(string, "ANY")<br/>    matches_prefix             = optional(list(string), [])<br/>    matches_suffix             = optional(list(string), [])<br/>    matches_storage_class      = optional(list(string), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | The GCS location (region or multi-region) where the bucket will be created. Examples: 'US', 'EU', 'us-central1', 'europe-west1'. | `string` | `"US"` | no |
| <a name="input_logging_config"></a> [logging\_config](#input\_logging\_config) | Logging configuration for the bucket. If not specified, logging is disabled. The log\_bucket should be the name (not a resource path) of the destination bucket for logs. | <pre>object({<br/>    log_bucket        = string<br/>    log_object_prefix = optional(string, "")<br/>  })</pre> | `null` | no |
| <a name="input_public_access_prevention"></a> [public\_access\_prevention](#input\_public\_access\_prevention) | Prevents public access to the bucket. Set to 'enforced' to block all public access, 'inherited' to inherit from organization policy. | `string` | `"enforced"` | no |
| <a name="input_storage_class"></a> [storage\_class](#input\_storage\_class) | The Storage Class of the bucket. Supported values: STANDARD, NEARLINE, COLDLINE, ARCHIVE. | `string` | `"STANDARD"` | no |
| <a name="input_uniform_bucket_level_access"></a> [uniform\_bucket\_level\_access](#input\_uniform\_bucket\_level\_access) | Enable uniform bucket-level access to use IAM exclusively for access control. Recommended for security and simplicity. | `bool` | `true` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Enable versioning to protect against accidental deletion and provide object history. Recommended for production buckets. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_location"></a> [bucket\_location](#output\_bucket\_location) | The location where the bucket is deployed (region or multi-region). |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | The name of the GCS bucket. Use this for bucket policy references and other resource configurations. |
| <a name="output_bucket_self_link"></a> [bucket\_self\_link](#output\_bucket\_self\_link) | The URI of the bucket for use in other resources. Use this for cross-resource references. |
| <a name="output_bucket_url"></a> [bucket\_url](#output\_bucket\_url) | The base URL of the bucket, in the format gs://<bucket-name>. |
| <a name="output_encryption_key_name"></a> [encryption\_key\_name](#output\_encryption\_key\_name) | The Cloud KMS key name used for encryption, if CMEK is enabled. Null if using Google-managed keys. |
| <a name="output_labels"></a> [labels](#output\_labels) | All labels applied to the bucket, including default and custom labels. |
| <a name="output_project"></a> [project](#output\_project) | The project in which the bucket is created. |
| <a name="output_public_access_prevention"></a> [public\_access\_prevention](#output\_public\_access\_prevention) | The public access prevention setting for the bucket. |
| <a name="output_storage_class"></a> [storage\_class](#output\_storage\_class) | The Storage Class of the bucket. |
| <a name="output_uniform_bucket_level_access"></a> [uniform\_bucket\_level\_access](#output\_uniform\_bucket\_level\_access) | Whether uniform bucket-level access is enabled for IAM-only access control. |
| <a name="output_versioning_enabled"></a> [versioning\_enabled](#output\_versioning\_enabled) | Whether versioning is enabled on the bucket. Important for compliance and data protection verification. |
<!-- END_TF_DOCS -->

## Security Considerations

### Default Security Posture

This module implements security best practices by default:

1. **Encryption**: All objects are encrypted at rest using Google-managed encryption keys by default
2. **Public Access Prevention**: Set to "enforced" by default to block all public access
3. **Uniform Bucket-Level Access**: Enabled by default for simplified IAM management
4. **Versioning**: Enabled by default to protect against accidental deletion
5. **Force Destroy**: Disabled by default to prevent accidental data loss

### Using Customer-Managed Encryption Keys (CMEK)

For sensitive data or compliance requirements, use Customer-Managed Encryption Keys:

```hcl
encryption_key_name = "projects/PROJECT_ID/locations/LOCATION/keyRings/KEY_RING/cryptoKeys/KEY_NAME"
```

Benefits:
- Full control over encryption key lifecycle
- Audit trail of encryption key usage in Cloud Audit Logs
- Fine-grained access control via Cloud IAM
- Support for automatic or manual key rotation

### Lifecycle Best Practices

Use lifecycle rules to:
1. Reduce storage costs by transitioning to cheaper storage classes (NEARLINE, COLDLINE, ARCHIVE)
2. Meet compliance requirements for data retention
3. Clean up incomplete multipart uploads
4. Manage versioned objects efficiently
5. Automatically delete old data

### Storage Classes

- **STANDARD**: Best for frequently accessed data (hot data)
- **NEARLINE**: Best for data accessed less than once per month
- **COLDLINE**: Best for data accessed less than once per quarter
- **ARCHIVE**: Best for data accessed less than once per year (lowest cost)

## Differences from AWS S3 Module

This GCS module is based on the S3 module but adapted for Google Cloud Platform:

| Feature | AWS S3 | Google Cloud Storage |
|---------|--------|---------------------|
| Encryption | SSE-S3 or SSE-KMS | Google-managed or CMEK |
| Access Control | Bucket Policies + ACLs | IAM with Uniform Bucket-Level Access |
| Public Access | Block Public Access settings | Public Access Prevention |
| Locations | Regions | Regions or Multi-regions (US, EU, ASIA) |
| Lifecycle Actions | Transition, Expiration | SetStorageClass, Delete, AbortIncompleteMultipartUpload |
| Metadata | Tags | Labels |

## Testing

Run the basic test:

```bash
cd tests/basic
terraform init -backend=false
terraform plan
```

Run all validation checks:

```bash
# From the terraform/gcp directory
terraform fmt -check
terraform validate
```

## Contributing

When making changes to this module:

1. Update the code following the existing patterns
2. Run `terraform fmt` to format the code
3. Update tests if adding new features
4. Run the test suite to ensure nothing breaks
5. Update this README if adding new variables or outputs
