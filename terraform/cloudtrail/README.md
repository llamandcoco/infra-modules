# CloudTrail Module

Focused AWS CloudTrail module for audit logging. Accepts an external S3 bucket for flexible integration.

## Features

- 🌍 **Multi-region support** - Capture events from all AWS regions
- 🔒 **Security** - Log file validation, encryption support
- 🎯 **Flexible** - Optional CloudWatch Logs, Insights, advanced selectors
- 🔌 **Composable** - Works with existing S3 buckets

## Usage

### With Existing S3 Bucket

```hcl
# Create or reference existing S3 bucket
module "cloudtrail_s3" {
  source = "github.com/your-org/infra-modules//terraform/s3"

  bucket_name   = "my-org-cloudtrail-logs"
  force_destroy = false

  # Security best practices
  enable_versioning           = true
  block_public_access_enabled = true

  # Cost optimization
  lifecycle_rules = [
    {
      id     = "archive-old-logs"
      status = "Enabled"

      transitions = [
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]

      expiration = {
        days = 365
      }
    }
  ]

  tags = {
    Purpose = "CloudTrail logs"
  }
}

# CloudTrail module
module "cloudtrail" {
  source = "github.com/your-org/infra-modules//terraform/cloudtrail"

  trail_name    = "organization-audit-trail"
  s3_bucket_id  = module.cloudtrail_s3.bucket_id
  s3_bucket_arn = module.cloudtrail_s3.bucket_arn

  # Multi-region for complete visibility (free!)
  is_multi_region_trail         = true
  include_global_service_events = true

  # Security best practices (free!)
  enable_log_file_validation = true

  tags = {
    Environment = "production"
    Compliance  = "required"
  }
}
```

### With CloudWatch Logs

```hcl
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/audit"
  retention_in_days = 7
}

module "cloudtrail" {
  source = "github.com/your-org/infra-modules//terraform/cloudtrail"

  trail_name                = "audit-trail-with-cloudwatch"
  s3_bucket_id              = module.cloudtrail_s3.bucket_id
  s3_bucket_arn             = module.cloudtrail_s3.bucket_arn
  cloudwatch_logs_group_arn = aws_cloudwatch_log_group.cloudtrail.arn

  # ... other settings
}
```

**Estimated cost:** ~$50-100/month (CloudWatch Logs ingestion)

### Organization Trail

```hcl
module "cloudtrail" {
  source = "github.com/your-org/infra-modules//terraform/cloudtrail"

  trail_name        = "organization-trail"
  s3_bucket_id      = module.cloudtrail_s3.bucket_id
  s3_bucket_arn     = module.cloudtrail_s3.bucket_arn
  is_organization_trail = true  # Requires AWS Organizations

  # Captures events from ALL accounts in the organization
  is_multi_region_trail = true
}
```

### With KMS Encryption

```hcl
resource "aws_kms_key" "cloudtrail" {
  description = "CloudTrail log encryption key"
  policy      = data.aws_iam_policy_document.cloudtrail_kms.json
}

module "cloudtrail" {
  source = "github.com/your-org/infra-modules//terraform/cloudtrail"

  trail_name    = "encrypted-trail"
  s3_bucket_id  = module.cloudtrail_s3.bucket_id
  s3_bucket_arn = module.cloudtrail_s3.bucket_arn
  kms_key_id    = aws_kms_key.cloudtrail.arn
}
```

### With CloudTrail Insights

```hcl
module "cloudtrail" {
  source = "github.com/your-org/infra-modules//terraform/cloudtrail"

  trail_name     = "trail-with-insights"
  s3_bucket_id   = module.cloudtrail_s3.bucket_id
  s3_bucket_arn  = module.cloudtrail_s3.bucket_arn
  enable_insights = true  # Anomaly detection: +$0.35/100k write events
}
```

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

## Cost Optimization Tips

1. **Disable CloudWatch Logs** - Use S3-only for most use cases
2. **Use S3 Lifecycle Policy** - Archive to Glacier after 90 days
3. **Avoid Data Events** - Unless you specifically need S3/Lambda event logging
4. **Single Trail** - First multi-region trail is free
5. **Use EventBridge** - For alerting instead of CloudWatch Logs

## Multi-Region Behavior

When `is_multi_region_trail = true`:
- ✅ Captures events from **all AWS regions**
- ✅ Single trail, single S3 bucket
- ✅ Includes global services (IAM, CloudFront, etc.)
- ✅ **No additional cost** - First trail is free!

Example: Trail created in `us-east-1` will capture:
- EC2 events from `ap-northeast-2`
- RDS events from `eu-west-1`
- IAM events (global)
- All other regions

## Security Best Practices

```hcl
module "cloudtrail" {
  source = "github.com/your-org/infra-modules//terraform/cloudtrail"

  trail_name    = "secure-trail"
  s3_bucket_id  = module.cloudtrail_s3.bucket_id
  s3_bucket_arn = module.cloudtrail_s3.bucket_arn

  # Enable all security features
  enable_log_file_validation    = true  # Detect log tampering
  include_global_service_events = true  # Include IAM, STS, etc.
  is_multi_region_trail         = true  # Complete visibility
  kms_key_id                    = aws_kms_key.cloudtrail.arn  # Encryption

  # Restrict to write events only (optional)
  read_write_type = "WriteOnly"  # Only log changes, not reads
}
```

## Integration with EventBridge

CloudTrail automatically sends events to EventBridge. Use for cost-effective alerting:

```hcl
# Create EventBridge rule for specific events
resource "aws_cloudwatch_event_rule" "console_login" {
  name = "detect-console-login"

  event_pattern = jsonencode({
    source      = ["aws.signin"]
    detail-type = ["AWS Console Sign In via CloudTrail"]
  })
}

# Lambda to send Slack notification
resource "aws_cloudwatch_event_target" "slack_notifier" {
  rule = aws_cloudwatch_event_rule.console_login.name
  arn  = aws_lambda_function.slack_notifier.arn
}
```

**Cost:** ~$0 (EventBridge + Lambda are within free tier for typical usage)

## When to Use This Module vs Stack

- **Use this module** when:
  - You have an existing S3 bucket
  - You need custom S3 bucket configuration
  - You're building a custom composite module

- **Use `stack/audit-logging`** when:
  - You want an all-in-one solution
  - You're starting fresh
  - You want standard security best practices

## Testing

```bash
cd tests/basic
terraform init -backend=false
terraform plan
```
