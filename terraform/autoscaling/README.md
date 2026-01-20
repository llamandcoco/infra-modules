# Auto Scaling Group Terraform Module

## Features

- Launch Template with Amazon Linux 2023 support and IMDSv2 enforced
- Auto Scaling Group with ALB/NLB target group attachment and rich tagging
- Optional target tracking (CPU, ALBRequestCountPerTarget) and step/predictive scaling hooks
- Warm pool, capacity rebalance, and health-check controls for fast recovery
- Exposes policy/metric alarm ARNs so CloudWatch alarms can trigger scaling policies

## Quick Start

```hcl
module "autoscaling" {
  source = "github.com/llamandcoco/infra-modules//terraform/autoscaling?ref=<commit-sha>"

  name           = "example-asg"
  vpc_subnet_ids = ["subnet-123", "subnet-456"]
  min_size       = 1
  max_size       = 3
  desired_capacity = 2
  instance_type  = "t3.micro"
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory | Description |
|---------|-----------|-------------|
| Basic | [`tests/basic/main.tf`](tests/basic/main.tf) | Minimal ASG with target tracking CPU scaling |
| Step Scaling | [`tests/with-step-scaling/main.tf`](tests/with-step-scaling/main.tf) | Aggressive step scaling for CPU/RPS spikes |
| Warm Pool | [`tests/with-warm-pool/main.tf`](tests/with-warm-pool/main.tf) | Pre-warmed instances for faster scale-out |
| With Instance Profile | [`tests/with-instance-profile/main.tf`](tests/with-instance-profile/main.tf) | Integration with instance-profile module |

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
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_policy.predictive](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_policy.step](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_policy.step_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_policy.step_rps](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_policy.tt_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_policy.tt_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_cloudwatch_metric_alarm.cpu_high_step](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.rps_high_step](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_ssm_parameter.al2023](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_target_group_resource_label"></a> [alb\_target\_group\_resource\_label](#input\_alb\_target\_group\_resource\_label) | Target group resource label (suffix) for ALBRequestCountPerTarget metric, format: targetgroup/<name>/<id> | `string` | `null` | no |
| <a name="input_alb_target_value"></a> [alb\_target\_value](#input\_alb\_target\_value) | Target requests per target for ALBRequestCountPerTarget (RPS metric, e.g., 100 RPS per instance) | `number` | `100` | no |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI ID for instances (if provided, overrides SSM lookup) | `string` | `null` | no |
| <a name="input_ami_ssm_parameter_name"></a> [ami\_ssm\_parameter\_name](#input\_ami\_ssm\_parameter\_name) | SSM parameter name for AL2023 AMI | `string` | `"/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"` | no |
| <a name="input_capacity_rebalance"></a> [capacity\_rebalance](#input\_capacity\_rebalance) | Enable capacity rebalance | `bool` | `false` | no |
| <a name="input_cpu_step_adjustments"></a> [cpu\_step\_adjustments](#input\_cpu\_step\_adjustments) | Step adjustments for CPU-based scaling. metric\_interval is relative to threshold. | <pre>list(object({<br/>    metric_interval_lower_bound = optional(number)<br/>    metric_interval_upper_bound = optional(number)<br/>    scaling_adjustment          = number<br/>  }))</pre> | <pre>[<br/>  {<br/>    "metric_interval_lower_bound": 0,<br/>    "metric_interval_upper_bound": 10,<br/>    "scaling_adjustment": 1<br/>  },<br/>  {<br/>    "metric_interval_lower_bound": 10,<br/>    "scaling_adjustment": 3<br/>  }<br/>]</pre> | no |
| <a name="input_cpu_step_evaluation_periods"></a> [cpu\_step\_evaluation\_periods](#input\_cpu\_step\_evaluation\_periods) | Number of periods to evaluate before triggering step scaling (1 = immediate) | `number` | `1` | no |
| <a name="input_cpu_step_instance_warmup"></a> [cpu\_step\_instance\_warmup](#input\_cpu\_step\_instance\_warmup) | Warmup time in seconds for CPU step scaling (null = use default\_instance\_warmup) | `number` | `null` | no |
| <a name="input_cpu_step_threshold"></a> [cpu\_step\_threshold](#input\_cpu\_step\_threshold) | CPU threshold (%) to trigger step scaling (e.g., 75 for aggressive scaling above 75%) | `number` | `75` | no |
| <a name="input_cpu_target_value"></a> [cpu\_target\_value](#input\_cpu\_target\_value) | Target value for ASGAverageCPUUtilization (percentage) | `number` | `50` | no |
| <a name="input_default_instance_warmup"></a> [default\_instance\_warmup](#input\_default\_instance\_warmup) | Default warmup time in seconds for all scaling activities (applies to ASG) | `number` | `null` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | ASG desired capacity | `number` | n/a | yes |
| <a name="input_enable_memory_alarm"></a> [enable\_memory\_alarm](#input\_enable\_memory\_alarm) | Enable memory-based CloudWatch alarm for manual step scaling | `bool` | `false` | no |
| <a name="input_enable_predictive_scaling"></a> [enable\_predictive\_scaling](#input\_enable\_predictive\_scaling) | Enable predictive scaling (requires 14 days of historical data) | `bool` | `false` | no |
| <a name="input_enable_step_scaling_cpu"></a> [enable\_step\_scaling\_cpu](#input\_enable\_step\_scaling\_cpu) | Enable step scaling for CPU (aggressive scaling for sudden spikes) | `bool` | `false` | no |
| <a name="input_enable_step_scaling_rps"></a> [enable\_step\_scaling\_rps](#input\_enable\_step\_scaling\_rps) | Enable step scaling for RPS (ALBRequestCountPerTarget) | `bool` | `false` | no |
| <a name="input_enable_target_tracking_alb"></a> [enable\_target\_tracking\_alb](#input\_enable\_target\_tracking\_alb) | Enable target tracking on ALBRequestCountPerTarget (RPS-based scaling) | `bool` | `false` | no |
| <a name="input_enable_target_tracking_cpu"></a> [enable\_target\_tracking\_cpu](#input\_enable\_target\_tracking\_cpu) | Enable target tracking on ASG average CPU utilization | `bool` | `false` | no |
| <a name="input_enable_warm_pool"></a> [enable\_warm\_pool](#input\_enable\_warm\_pool) | Enable warm pool for faster scale-out | `bool` | `false` | no |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | Seconds to ignore health checks after instance launch | `number` | `120` | no |
| <a name="input_health_check_type"></a> [health\_check\_type](#input\_health\_check\_type) | ASG health check type (EC2 or ELB) | `string` | `"EC2"` | no |
| <a name="input_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#input\_iam\_instance\_profile\_name) | IAM instance profile name for EC2 instances (ECR/SSM permissions) | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type | `string` | n/a | yes |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | ASG max size | `number` | n/a | yes |
| <a name="input_memory_alarm_metric_name"></a> [memory\_alarm\_metric\_name](#input\_memory\_alarm\_metric\_name) | CloudWatch metric name for memory utilization | `string` | `"mem_used_percent"` | no |
| <a name="input_memory_alarm_namespace"></a> [memory\_alarm\_namespace](#input\_memory\_alarm\_namespace) | CloudWatch namespace for memory metric (e.g., CWAgent when using CloudWatch Agent) | `string` | `"CWAgent"` | no |
| <a name="input_memory_alarm_threshold"></a> [memory\_alarm\_threshold](#input\_memory\_alarm\_threshold) | Memory utilization threshold (%) to trigger alarm and scale out | `number` | `80` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | ASG min size | `number` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for ASG and Launch Template | `string` | n/a | yes |
| <a name="input_predictive_max_capacity_breach_behavior"></a> [predictive\_max\_capacity\_breach\_behavior](#input\_predictive\_max\_capacity\_breach\_behavior) | Behavior when forecast exceeds max capacity: HonorMaxCapacity or IncreaseMaxCapacity | `string` | `"HonorMaxCapacity"` | no |
| <a name="input_predictive_metric_type"></a> [predictive\_metric\_type](#input\_predictive\_metric\_type) | Metric type for predictive scaling (cpu or alb) | `string` | `"cpu"` | no |
| <a name="input_predictive_scaling_mode"></a> [predictive\_scaling\_mode](#input\_predictive\_scaling\_mode) | Predictive scaling mode: ForecastAndScale or ForecastOnly | `string` | `"ForecastAndScale"` | no |
| <a name="input_predictive_scheduling_buffer_time"></a> [predictive\_scheduling\_buffer\_time](#input\_predictive\_scheduling\_buffer\_time) | Buffer time in seconds to pre-launch instances (default: 300 = 5 minutes) | `number` | `300` | no |
| <a name="input_predictive_target_value"></a> [predictive\_target\_value](#input\_predictive\_target\_value) | Target value for predictive scaling (e.g., 60 for 60% CPU) | `number` | `60` | no |
| <a name="input_rps_step_adjustments"></a> [rps\_step\_adjustments](#input\_rps\_step\_adjustments) | Step adjustments for RPS-based scaling. metric\_interval is relative to threshold. | <pre>list(object({<br/>    metric_interval_lower_bound = optional(number)<br/>    metric_interval_upper_bound = optional(number)<br/>    scaling_adjustment          = number<br/>  }))</pre> | <pre>[<br/>  {<br/>    "metric_interval_lower_bound": 0,<br/>    "metric_interval_upper_bound": 50,<br/>    "scaling_adjustment": 2<br/>  },<br/>  {<br/>    "metric_interval_lower_bound": 50,<br/>    "scaling_adjustment": 4<br/>  }<br/>]</pre> | no |
| <a name="input_rps_step_evaluation_periods"></a> [rps\_step\_evaluation\_periods](#input\_rps\_step\_evaluation\_periods) | Number of periods to evaluate before triggering RPS step scaling | `number` | `1` | no |
| <a name="input_rps_step_instance_warmup"></a> [rps\_step\_instance\_warmup](#input\_rps\_step\_instance\_warmup) | Warmup time in seconds for RPS step scaling (null = use default\_instance\_warmup) | `number` | `null` | no |
| <a name="input_rps_step_threshold"></a> [rps\_step\_threshold](#input\_rps\_step\_threshold) | RPS threshold per target to trigger step scaling (e.g., 150 RPS per instance) | `number` | `150` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs for instances | `list(string)` | `[]` | no |
| <a name="input_step_adjustment_type"></a> [step\_adjustment\_type](#input\_step\_adjustment\_type) | Adjustment type for step scaling (ChangeInCapacity\|PercentChangeInCapacity\|ExactCapacity) | `string` | `"PercentChangeInCapacity"` | no |
| <a name="input_step_adjustments"></a> [step\_adjustments](#input\_step\_adjustments) | List of step adjustments | <pre>list(object({<br/>    metric_interval_lower_bound = optional(string)<br/>    metric_interval_upper_bound = optional(string)<br/>    scaling_adjustment          = number<br/>  }))</pre> | `[]` | no |
| <a name="input_step_policy_name"></a> [step\_policy\_name](#input\_step\_policy\_name) | Optional Step Scaling policy name (if set, resource is created) | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_target_group_arns"></a> [target\_group\_arns](#input\_target\_group\_arns) | Optional list of ALB/NLB target group ARNs to attach | `list(string)` | `[]` | no |
| <a name="input_termination_policies"></a> [termination\_policies](#input\_termination\_policies) | List of termination policies | `list(string)` | <pre>[<br/>  "Default"<br/>]</pre> | no |
| <a name="input_use_ssm_ami_lookup"></a> [use\_ssm\_ami\_lookup](#input\_use\_ssm\_ami\_lookup) | When true, use SSM parameter to lookup AL2023 AMI | `bool` | `true` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Plain user data script (will be base64-encoded) | `string` | `null` | no |
| <a name="input_user_data_base64"></a> [user\_data\_base64](#input\_user\_data\_base64) | Base64 user data script | `string` | `null` | no |
| <a name="input_vpc_subnet_ids"></a> [vpc\_subnet\_ids](#input\_vpc\_subnet\_ids) | List of subnet IDs for ASG (multiple AZs recommended) | `list(string)` | n/a | yes |
| <a name="input_warm_pool_max_group_prepared_capacity"></a> [warm\_pool\_max\_group\_prepared\_capacity](#input\_warm\_pool\_max\_group\_prepared\_capacity) | Maximum instances (in-service + warm pool). If null, defaults to max\_size | `number` | `null` | no |
| <a name="input_warm_pool_min_size"></a> [warm\_pool\_min\_size](#input\_warm\_pool\_min\_size) | Minimum number of instances in warm pool | `number` | `null` | no |
| <a name="input_warm_pool_reuse_on_scale_in"></a> [warm\_pool\_reuse\_on\_scale\_in](#input\_warm\_pool\_reuse\_on\_scale\_in) | Whether to return instances to warm pool on scale-in | `bool` | `true` | no |
| <a name="input_warm_pool_state"></a> [warm\_pool\_state](#input\_warm\_pool\_state) | Warm pool instance state (Stopped, Running, Hibernated) | `string` | `"Stopped"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_asg_name"></a> [asg\_name](#output\_asg\_name) | Auto Scaling Group name |
| <a name="output_cpu_high_step_alarm_arn"></a> [cpu\_high\_step\_alarm\_arn](#output\_cpu\_high\_step\_alarm\_arn) | CPU high step scaling alarm ARN (if created) |
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | Launch Template ID |
| <a name="output_memory_alarm_arn"></a> [memory\_alarm\_arn](#output\_memory\_alarm\_arn) | Memory-based CloudWatch alarm ARN (if created) |
| <a name="output_rps_high_step_alarm_arn"></a> [rps\_high\_step\_alarm\_arn](#output\_rps\_high\_step\_alarm\_arn) | RPS high step scaling alarm ARN (if created) |
| <a name="output_step_cpu_policy_arn"></a> [step\_cpu\_policy\_arn](#output\_step\_cpu\_policy\_arn) | Step scaling CPU policy ARN (if created) |
| <a name="output_step_policy_arn"></a> [step\_policy\_arn](#output\_step\_policy\_arn) | Step scaling policy ARN (if created) |
| <a name="output_step_rps_policy_arn"></a> [step\_rps\_policy\_arn](#output\_step\_rps\_policy\_arn) | Step scaling RPS policy ARN (if created) |
| <a name="output_tt_alb_policy_arn"></a> [tt\_alb\_policy\_arn](#output\_tt\_alb\_policy\_arn) | Target tracking RPS (ALB request count) policy ARN (if created) |
| <a name="output_tt_cpu_policy_arn"></a> [tt\_cpu\_policy\_arn](#output\_tt\_cpu\_policy\_arn) | Target tracking CPU policy ARN (if created) |
<!-- END_TF_DOCS -->
</details>
