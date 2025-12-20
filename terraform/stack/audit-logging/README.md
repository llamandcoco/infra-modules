# Audit Logging Stack

## Features

- 📦 All-in-one - S3 bucket + CloudTrail configured together
- 💰 Cost optimized - First trail is free, S3-only storage (~$2-5/month)
- 🔒 Secure by default - Versioning, encryption, public access blocked
- 📊 Lifecycle managed - Auto-archive to Glacier and expiration
- 🌍 Multi-region - Capture events from all AWS regions

## Quick Start

```hcl
module "audit-logging" {
  source = "github.com/llamandcoco/infra-modules//terraform/stack/audit-logging?ref=<commit-sha>"

  # Add required variables here
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|----------|
| Basic | [`tests/basic/`](tests/basic/) |

**Usage:**
```bash
# View example
cat tests/basic/main.tf

# Copy and adapt
cp -r tests/basic/ my-project/
```

## Testing

```bash
cd tests/basic && terraform init && terraform plan
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudtrail"></a> [cloudtrail](#module\_cloudtrail) | ../../cloudtrail | n/a |
| <a name="module_s3"></a> [s3](#module\_s3) | ../../s3 | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_advanced_event_selectors"></a> [advanced\_event\_selectors](#input\_advanced\_event\_selectors) | Advanced event selectors for granular control over logged events. | <pre>list(object({<br/>    name = string<br/>    field_selectors = list(object({<br/>      field           = string<br/>      equals          = optional(list(string))<br/>      not_equals      = optional(list(string))<br/>      starts_with     = optional(list(string))<br/>      not_starts_with = optional(list(string))<br/>      ends_with       = optional(list(string))<br/>      not_ends_with   = optional(list(string))<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_cloudwatch_logs_group_arn"></a> [cloudwatch\_logs\_group\_arn](#input\_cloudwatch\_logs\_group\_arn) | CloudWatch Logs group ARN for real-time log analysis. Leave null to disable (cost optimization). | `string` | `null` | no |
| <a name="input_enable_insights"></a> [enable\_insights](#input\_enable\_insights) | Enable CloudTrail Insights for anomaly detection. Additional cost: $0.35 per 100k write events. | `bool` | `false` | no |
| <a name="input_enable_lifecycle_policy"></a> [enable\_lifecycle\_policy](#input\_enable\_lifecycle\_policy) | Enable S3 lifecycle policy to archive and delete old logs (cost optimization). | `bool` | `true` | no |
| <a name="input_enable_log_file_validation"></a> [enable\_log\_file\_validation](#input\_enable\_log\_file\_validation) | Enable log file integrity validation (recommended for security). | `bool` | `true` | no |
| <a name="input_exclude_management_event_sources"></a> [exclude\_management\_event\_sources](#input\_exclude\_management\_event\_sources) | List of management event sources to exclude (e.g., kms.amazonaws.com, rdsdata.amazonaws.com). | `list(string)` | `[]` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Allow deletion of S3 bucket even if it contains logs. Use with caution. | `bool` | `false` | no |
| <a name="input_glacier_transition_days"></a> [glacier\_transition\_days](#input\_glacier\_transition\_days) | Number of days after which logs are transitioned to Glacier. | `number` | `90` | no |
| <a name="input_include_global_service_events"></a> [include\_global\_service\_events](#input\_include\_global\_service\_events) | Whether to include global service events (IAM, STS, CloudFront, etc.). | `bool` | `true` | no |
| <a name="input_is_multi_region_trail"></a> [is\_multi\_region\_trail](#input\_is\_multi\_region\_trail) | Whether the trail is created in all regions. Recommended for complete visibility. | `bool` | `true` | no |
| <a name="input_is_organization_trail"></a> [is\_organization\_trail](#input\_is\_organization\_trail) | Whether the trail is an organization trail. Requires AWS Organizations. | `bool` | `false` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key ARN for encrypting CloudTrail logs and S3 bucket. If null, uses S3-managed encryption (SSE-S3). | `string` | `null` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Number of days to retain logs before deletion. Set to 0 to disable expiration. | `number` | `365` | no |
| <a name="input_read_write_type"></a> [read\_write\_type](#input\_read\_write\_type) | Type of events to log: All, ReadOnly, or WriteOnly. | `string` | `"All"` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Name of the S3 bucket for CloudTrail logs. Must be globally unique. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_trail_name"></a> [trail\_name](#input\_trail\_name) | Name of the CloudTrail trail. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_logs_role_arn"></a> [cloudwatch\_logs\_role\_arn](#output\_cloudwatch\_logs\_role\_arn) | ARN of the IAM role for CloudWatch Logs integration (null if disabled). |
| <a name="output_is_multi_region_trail"></a> [is\_multi\_region\_trail](#output\_is\_multi\_region\_trail) | Whether the trail captures events from all regions. |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | ARN of the S3 bucket storing CloudTrail logs. |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | ID of the S3 bucket storing CloudTrail logs. |
| <a name="output_s3_bucket_region"></a> [s3\_bucket\_region](#output\_s3\_bucket\_region) | Region of the S3 bucket storing CloudTrail logs. |
| <a name="output_trail_arn"></a> [trail\_arn](#output\_trail\_arn) | ARN of the CloudTrail trail. |
| <a name="output_trail_home_region"></a> [trail\_home\_region](#output\_trail\_home\_region) | Region in which the CloudTrail trail was created. |
| <a name="output_trail_id"></a> [trail\_id](#output\_trail\_id) | ID of the CloudTrail trail. |
<!-- END_TF_DOCS -->
