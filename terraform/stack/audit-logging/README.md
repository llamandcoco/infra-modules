# Audit Logging Stack

All-in-one AWS CloudTrail audit logging solution. Combines S3 + CloudTrail with security best practices for quick deployment.

## Features

- 📦 **All-in-one** - S3 bucket + CloudTrail configured together
- 💰 **Cost optimized** - First trail is free, S3-only storage (~$2-5/month)
- 🔒 **Secure by default** - Versioning, encryption, public access blocked
- 📊 **Lifecycle managed** - Auto-archive to Glacier and expiration
- 🌍 **Multi-region** - Capture events from all AWS regions

## Cost Breakdown

| Configuration | Monthly Cost | Use Case |
|--------------|--------------|----------|
| **Minimum** (Management events + S3) | ~$2-5 | Most organizations |
| **+ CloudWatch Logs** | ~$50-100 | Real-time analysis needed |
| **+ Insights** | +$0.35/100k writes | Anomaly detection |
| **+ Data Events** | +$0.10/100k events | S3/Lambda detailed logging |

## Usage

### Minimum Configuration (Recommended)

```hcl
module "audit_logging" {
  source = "github.com/your-org/infra-modules//terraform/stack/audit-logging"

  trail_name     = "organization-audit-trail"
  s3_bucket_name = "my-org-cloudtrail-logs-us-east-1"

  # Multi-region for complete visibility (free!)
  is_multi_region_trail         = true
  include_global_service_events = true

  # Security best practices (free!)
  enable_log_file_validation = true

  # Cost optimization
  enable_lifecycle_policy = true
  glacier_transition_days = 90   # Archive to Glacier after 90 days
  log_retention_days      = 365  # Delete after 1 year

  tags = {
    Environment = "production"
    Compliance  = "required"
  }
}
```

**Estimated cost:** ~$2-5/month

### With CloudWatch Logs (Real-time Analysis)

```hcl
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/audit"
  retention_in_days = 7  # Keep logs for 7 days
}

module "audit_logging" {
  source = "github.com/your-org/infra-modules//terraform/stack/audit-logging"

  trail_name                = "audit-trail-with-cloudwatch"
  s3_bucket_name            = "my-org-cloudtrail-logs"
  cloudwatch_logs_group_arn = aws_cloudwatch_log_group.cloudtrail.arn

  is_multi_region_trail = true

  tags = {
    Environment = "production"
  }
}
```

**Estimated cost:** ~$50-100/month (CloudWatch Logs ingestion)

### Organization Trail

```hcl
module "audit_logging" {
  source = "github.com/your-org/infra-modules//terraform/stack/audit-logging"

  trail_name            = "organization-trail"
  s3_bucket_name        = "org-cloudtrail-logs"
  is_organization_trail = true  # Requires AWS Organizations

  # Captures events from ALL accounts in the organization
  is_multi_region_trail = true

  tags = {
    Organization = "true"
  }
}
```

### With KMS Encryption

```hcl
resource "aws_kms_key" "cloudtrail" {
  description = "CloudTrail log encryption key"
  policy      = data.aws_iam_policy_document.cloudtrail_kms.json
}

module "audit_logging" {
  source = "github.com/your-org/infra-modules//terraform/stack/audit-logging"

  trail_name     = "encrypted-trail"
  s3_bucket_name = "encrypted-cloudtrail-logs"
  kms_key_id     = aws_kms_key.cloudtrail.arn

  is_multi_region_trail = true

  tags = {
    Encrypted = "true"
  }
}
```

### With CloudTrail Insights

```hcl
module "audit_logging" {
  source = "github.com/your-org/infra-modules//terraform/stack/audit-logging"

  trail_name      = "trail-with-insights"
  s3_bucket_name  = "cloudtrail-logs-insights"
  enable_insights = true  # Anomaly detection: +$0.35/100k write events

  is_multi_region_trail = true

  tags = {
    Insights = "enabled"
  }
}
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

## What's Included

This stack automatically configures:

### S3 Bucket
- ✅ Versioning enabled
- ✅ Public access blocked
- ✅ Server-side encryption (SSE-S3 or KMS)
- ✅ Lifecycle policy for cost optimization
- ✅ Bucket policy for CloudTrail access

### CloudTrail
- ✅ Multi-region trail (optional)
- ✅ Log file validation
- ✅ Global service events (IAM, STS, etc.)
- ✅ Management events logging
- ✅ Optional CloudWatch Logs integration
- ✅ Optional Insights for anomaly detection

## Cost Optimization Tips

1. **Disable CloudWatch Logs** - Use S3-only for most use cases (default)
2. **Enable Lifecycle Policy** - Archive to Glacier after 90 days (default)
3. **Avoid Data Events** - Unless you specifically need S3/Lambda event logging
4. **Single Trail** - First multi-region trail is free
5. **Use EventBridge** - For alerting instead of CloudWatch Logs

## Multi-Region Behavior

When `is_multi_region_trail = true`:
- ✅ Captures events from **all AWS regions**
- ✅ Single trail, single S3 bucket
- ✅ Includes global services (IAM, CloudFront, etc.)
- ✅ **No additional cost** - First trail is free!

## Security Best Practices

```hcl
module "audit_logging" {
  source = "github.com/your-org/infra-modules//terraform/stack/audit-logging"

  trail_name     = "secure-audit-trail"
  s3_bucket_name = "secure-cloudtrail-logs"

  # Enable all security features
  enable_log_file_validation    = true  # Detect log tampering
  include_global_service_events = true  # Include IAM, STS, etc.
  is_multi_region_trail         = true  # Complete visibility
  kms_key_id                    = aws_kms_key.cloudtrail.arn  # Encryption

  # Restrict to write events only (optional)
  read_write_type = "WriteOnly"  # Only log changes, not reads

  # Prevent accidental deletion
  force_destroy = false

  tags = {
    Compliance = "required"
    Security   = "high"
  }
}
```

## Integration with EventBridge (for Slack Alerts)

CloudTrail automatically sends events to EventBridge. Create rules for specific events:

```hcl
module "audit_logging" {
  source = "github.com/your-org/infra-modules//terraform/stack/audit-logging"

  trail_name     = "monitored-trail"
  s3_bucket_name = "monitored-cloudtrail-logs"

  is_multi_region_trail = true
}

# Create EventBridge rule for console login
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

## When to Use This Stack vs Individual Modules

- **Use this stack** when:
  - You're starting fresh
  - You want quick deployment
  - You want standard security best practices
  - You need S3 + CloudTrail together

- **Use individual modules** when:
  - You have an existing S3 bucket
  - You need custom S3 bucket configuration
  - You're building a custom composite solution
  - You need more granular control

## Testing

```bash
cd tests/basic
terraform init -backend=false
terraform plan
```

## Related Modules

- [`terraform/cloudtrail`](../../cloudtrail) - Focused CloudTrail module (for custom S3 integration)
- [`terraform/s3`](../../s3) - S3 bucket module
