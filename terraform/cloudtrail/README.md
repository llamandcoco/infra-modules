# CloudTrail Module

A comprehensive Terraform module for creating and managing AWS CloudTrail with multi-region support, S3 logging, encryption, and optional CloudWatch Logs integration.

## Features

- 🌍 Multi-region support - Capture events from all AWS regions
- 🔒 Security - Log file validation, encryption support
- 🎯 Flexible - Optional CloudWatch Logs, Insights, advanced selectors
- 🔌 Composable - Works with existing S3 buckets

## Quick Start

```hcl
module "cloudtrail" {
  source = "github.com/llamandcoco/infra-modules//terraform/cloudtrail?ref=<commit-sha>"

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

## Features

- 🌍 Multi-region support - Capture events from all AWS regions
- 🔒 Security - Log file validation, encryption support
- 🎯 Flexible - Optional CloudWatch Logs, Insights, advanced selectors
- 🔌 Composable - Works with existing S3 buckets

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
| [aws_cloudtrail.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_iam_role.cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_s3_bucket_policy.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_advanced_event_selectors"></a> [advanced\_event\_selectors](#input\_advanced\_event\_selectors) | Advanced event selectors for granular control over logged events. | <pre>list(object({<br/>    name = string<br/>    field_selectors = list(object({<br/>      field           = string<br/>      equals          = optional(list(string))<br/>      not_equals      = optional(list(string))<br/>      starts_with     = optional(list(string))<br/>      not_starts_with = optional(list(string))<br/>      ends_with       = optional(list(string))<br/>      not_ends_with   = optional(list(string))<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_cloudwatch_logs_group_arn"></a> [cloudwatch\_logs\_group\_arn](#input\_cloudwatch\_logs\_group\_arn) | CloudWatch Logs group ARN for real-time log analysis. Leave null to disable (cost optimization). | `string` | `null` | no |
| <a name="input_create_s3_bucket_policy"></a> [create\_s3\_bucket\_policy](#input\_create\_s3\_bucket\_policy) | Whether to create the S3 bucket policy for CloudTrail. Set to false if managing the policy externally. | `bool` | `true` | no |
| <a name="input_enable_insights"></a> [enable\_insights](#input\_enable\_insights) | Enable CloudTrail Insights for anomaly detection. Additional cost: $0.35 per 100k write events. | `bool` | `false` | no |
| <a name="input_enable_log_file_validation"></a> [enable\_log\_file\_validation](#input\_enable\_log\_file\_validation) | Enable log file integrity validation (recommended for security). | `bool` | `true` | no |
| <a name="input_exclude_management_event_sources"></a> [exclude\_management\_event\_sources](#input\_exclude\_management\_event\_sources) | List of management event sources to exclude (e.g., kms.amazonaws.com, rdsdata.amazonaws.com). | `list(string)` | `[]` | no |
| <a name="input_include_global_service_events"></a> [include\_global\_service\_events](#input\_include\_global\_service\_events) | Whether to include global service events (IAM, STS, CloudFront, etc.). | `bool` | `true` | no |
| <a name="input_is_multi_region_trail"></a> [is\_multi\_region\_trail](#input\_is\_multi\_region\_trail) | Whether the trail is created in all regions. Recommended for complete visibility. | `bool` | `true` | no |
| <a name="input_is_organization_trail"></a> [is\_organization\_trail](#input\_is\_organization\_trail) | Whether the trail is an organization trail. Requires AWS Organizations. | `bool` | `false` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key ARN for encrypting CloudTrail logs. If null, uses S3-managed encryption (SSE-S3). | `string` | `null` | no |
| <a name="input_read_write_type"></a> [read\_write\_type](#input\_read\_write\_type) | Type of events to log: All, ReadOnly, or WriteOnly. | `string` | `"All"` | no |
| <a name="input_s3_bucket_arn"></a> [s3\_bucket\_arn](#input\_s3\_bucket\_arn) | ARN of the existing S3 bucket for CloudTrail logs. | `string` | n/a | yes |
| <a name="input_s3_bucket_id"></a> [s3\_bucket\_id](#input\_s3\_bucket\_id) | ID of the existing S3 bucket for CloudTrail logs. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_trail_name"></a> [trail\_name](#input\_trail\_name) | Name of the CloudTrail trail. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_logs_role_arn"></a> [cloudwatch\_logs\_role\_arn](#output\_cloudwatch\_logs\_role\_arn) | ARN of the IAM role for CloudWatch Logs integration (null if disabled). |
| <a name="output_is_multi_region_trail"></a> [is\_multi\_region\_trail](#output\_is\_multi\_region\_trail) | Whether the trail captures events from all regions. |
| <a name="output_trail_arn"></a> [trail\_arn](#output\_trail\_arn) | ARN of the CloudTrail trail. |
| <a name="output_trail_home_region"></a> [trail\_home\_region](#output\_trail\_home\_region) | Region in which the CloudTrail trail was created. |
| <a name="output_trail_id"></a> [trail\_id](#output\_trail\_id) | ID of the CloudTrail trail. |
<!-- END_TF_DOCS -->
</details>
