# Google Cloud Storage (GCS) Bucket Terraform Module

```bash

## Features

- Security First Google-managed encryption by default, optional CMEK support
- Public Access Prevention Public access blocked by default
- Versioning Enabled by default to protect against accidental deletion
- Uniform Bucket-Level Access IAM-only access control enabled by default
- Lifecycle Management Flexible lifecycle rules for cost optimization
- Compliance Ready Follows Google Cloud security best practices
- Fully Tested Includes test configurations and passes trivy security scans

## Quick Start

```hcl
module "gcs" {
  source = "github.com/llamandcoco/infra-modules//terraform/gcp/gcs?ref=<commit-sha>"

  # Add required variables here
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|----------|
| Basic | [`tests/basic/main.tf`](tests/basic/main.tf) |

**Usage:**
```bash
# View example
cat tests/basic/

# Copy and adapt
cp -r tests/basic/ my-project/
```

## Testing

```bash
cd tests/basic && terraform init && terraform plan
```

<details>
<summary>Terraform Documentation</summary>

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
</details>
