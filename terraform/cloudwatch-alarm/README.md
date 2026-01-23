# CloudWatch Metric Alarm Terraform Module

## Features

- **Flexible Alarm Configuration** Support for standard CloudWatch metrics with customizable thresholds and comparison operators
- **Action Integration** Wire alarm and OK state transitions to SNS topics, Auto Scaling policies, or Lambda functions
- **Dimension Support** Configure metric dimensions for targeted monitoring (e.g., specific EC2 instances, load balancers)
- **Missing Data Handling** Configurable behavior for handling missing data points
- **Comprehensive Statistics** Support for Average, Sum, Minimum, Maximum, and SampleCount statistics
- **Input Validation** Built-in validation for parameters to catch configuration errors early

## Quick Start

```hcl
module "cloudwatch_alarm" {
  source = "github.com/llamandcoco/infra-modules//terraform/cloudwatch-alarm?ref=<commit-sha>"

  alarm_name          = "high-cpu-alarm"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 80
  period              = 300
  evaluation_periods  = 2
  statistic           = "Average"

  dimensions = {
    InstanceId = "i-1234567890abcdef0"
  }

  alarm_actions = ["arn:aws:sns:us-east-1:123456789012:alert-topic"]

  tags = {
    Environment = "production"
    Team        = "platform"
  }
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
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | List of ARNs to execute when the alarm transitions to the ALARM state.<br/>Can include SNS topic ARNs, Auto Scaling policy ARNs, or Lambda function ARNs. | `list(string)` | `[]` | no |
| <a name="input_alarm_name"></a> [alarm\_name](#input\_alarm\_name) | Name of the CloudWatch alarm. Used for identification and the Name tag. | `string` | n/a | yes |
| <a name="input_comparison_operator"></a> [comparison\_operator](#input\_comparison\_operator) | The arithmetic operation to use when comparing the specified statistic and threshold.<br/>Valid values: GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold. | `string` | n/a | yes |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions) | The dimensions for the metric. Each metric has specific valid dimensions.<br/>Example: {InstanceId = "i-1234567890abcdef0"} for EC2 metrics. | `map(string)` | `{}` | no |
| <a name="input_evaluation_periods"></a> [evaluation\_periods](#input\_evaluation\_periods) | The number of periods over which data is compared to the specified threshold.<br/>Must be a positive integer. | `number` | n/a | yes |
| <a name="input_metric_name"></a> [metric\_name](#input\_metric\_name) | The name of the metric to monitor.<br/>Examples: CPUUtilization, NetworkIn, DiskReadOps. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace for the metric associated with the alarm.<br/>Examples: AWS/EC2, AWS/RDS, AWS/Lambda, or custom namespaces. | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | List of ARNs to execute when the alarm transitions to the OK state.<br/>Can include SNS topic ARNs, Auto Scaling policy ARNs, or Lambda function ARNs. | `list(string)` | `[]` | no |
| <a name="input_period"></a> [period](#input\_period) | The period in seconds over which the specified statistic is applied.<br/>Valid values are 10, 30, or any multiple of 60. | `number` | n/a | yes |
| <a name="input_statistic"></a> [statistic](#input\_statistic) | The statistic to apply to the metric.<br/>Valid values: Average, Sum, Minimum, Maximum, SampleCount. | `string` | `"Average"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to the CloudWatch alarm. | `map(string)` | `{}` | no |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | The value to compare the metric against. | `number` | n/a | yes |
| <a name="input_treat_missing_data"></a> [treat\_missing\_data](#input\_treat\_missing\_data) | How to handle missing data points.<br/>Valid values:<br/>- notBreaching: Missing data is treated as good (within threshold)<br/>- breaching: Missing data is treated as bad (breaching threshold)<br/>- ignore: The alarm continues its current state<br/>- missing: The alarm does not consider missing data when evaluating | `string` | `"ignore"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alarm_arn"></a> [alarm\_arn](#output\_alarm\_arn) | The ARN of the CloudWatch metric alarm. |
| <a name="output_alarm_id"></a> [alarm\_id](#output\_alarm\_id) | The ID of the CloudWatch metric alarm. |
| <a name="output_alarm_name"></a> [alarm\_name](#output\_alarm\_name) | The name of the CloudWatch metric alarm. |
<!-- END_TF_DOCS -->
</details>
