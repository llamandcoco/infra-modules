# CloudWatch Metric Alarm

Minimal Terraform module to create CloudWatch metric alarms with optional actions for integration with Auto Scaling step policies or notifications.

## Features
- Metric alarms with dimensions
- Alarm/OK actions wiring
- Treat missing data configuration

## Quick Start
See tests/basic for example usage.

## Testing
```
terraform init -backend=false
terraform plan
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.28.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | List of ARNs to execute when alarm transitions to ALARM | `list(string)` | `[]` | no |
| <a name="input_alarm_name"></a> [alarm\_name](#input\_alarm\_name) | Alarm name | `string` | n/a | yes |
| <a name="input_comparison_operator"></a> [comparison\_operator](#input\_comparison\_operator) | Comparison operator (e.g., GreaterThanThreshold) | `string` | n/a | yes |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions) | Metric dimensions | `map(string)` | `{}` | no |
| <a name="input_evaluation_periods"></a> [evaluation\_periods](#input\_evaluation\_periods) | Number of periods to evaluate | `number` | n/a | yes |
| <a name="input_metric_name"></a> [metric\_name](#input\_metric\_name) | Metric name | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Metric namespace | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | List of ARNs to execute when alarm transitions to OK | `list(string)` | `[]` | no |
| <a name="input_period"></a> [period](#input\_period) | Metric period in seconds | `number` | n/a | yes |
| <a name="input_statistic"></a> [statistic](#input\_statistic) | Statistic (Average\|Sum\|Minimum\|Maximum\|SampleCount) | `string` | `"Average"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply | `map(string)` | `{}` | no |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | Alarm threshold | `number` | n/a | yes |
| <a name="input_treat_missing_data"></a> [treat\_missing\_data](#input\_treat\_missing\_data) | Treat missing data (notBreaching\|breaching\|ignore\|missing) | `string` | `"ignore"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alarm_arn"></a> [alarm\_arn](#output\_alarm\_arn) | CloudWatch alarm ARN |
<!-- END_TF_DOCS -->
