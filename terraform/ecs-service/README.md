# ECS Service Module

This module creates an ECS Fargate service with task definition, logging, and optional auto-scaling.
Inline examples live in `tests/` to avoid duplication.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|----------|
| Basic | [`tests/basic/main.tf`](tests/basic/main.tf) |
| With Autoscaling | [`tests/with_autoscaling/main.tf`](tests/with_autoscaling/main.tf) |

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
| [aws_appautoscaling_policy.alb_request_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_resource_label"></a> [alb\_resource\_label](#input\_alb\_resource\_label) | ALB resource label for request count scaling. Format: app/<alb-name>/<id>/targetgroup/<tg-name>/<id> | `string` | `null` | no |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Assign a public IP address to ECS tasks. Required for tasks in public subnets without NAT | `bool` | `false` | no |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | ID of the ECS cluster where the service will be deployed | `string` | n/a | yes |
| <a name="input_container_health_check"></a> [container\_health\_check](#input\_container\_health\_check) | Container-level health check configuration | <pre>object({<br/>    command      = list(string)<br/>    interval     = number<br/>    timeout      = number<br/>    retries      = number<br/>    start_period = number<br/>  })</pre> | `null` | no |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | Docker image to run in the container (e.g., nginx:latest or ECR URI) | `string` | n/a | yes |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | Name of the container (defaults to service\_name if not provided) | `string` | `null` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Port number the container listens on | `number` | n/a | yes |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Fargate task CPU units (256, 512, 1024, 2048, 4096). See AWS docs for valid CPU/memory combinations | `string` | `"256"` | no |
| <a name="input_deployment_maximum_percent"></a> [deployment\_maximum\_percent](#input\_deployment\_maximum\_percent) | Maximum percentage of tasks to run during deployment (100-200) | `number` | `200` | no |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | Minimum percentage of healthy tasks during deployment (0-100) | `number` | `100` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Desired number of tasks to run | `number` | `1` | no |
| <a name="input_enable_alb_scaling"></a> [enable\_alb\_scaling](#input\_enable\_alb\_scaling) | Enable ALB request count-based auto-scaling | `bool` | `false` | no |
| <a name="input_enable_cpu_scaling"></a> [enable\_cpu\_scaling](#input\_enable\_cpu\_scaling) | Enable CPU-based auto-scaling | `bool` | `true` | no |
| <a name="input_enable_ecs_exec"></a> [enable\_ecs\_exec](#input\_enable\_ecs\_exec) | Enable ECS Exec for debugging (requires IAM permissions) | `bool` | `false` | no |
| <a name="input_enable_memory_scaling"></a> [enable\_memory\_scaling](#input\_enable\_memory\_scaling) | Enable memory-based auto-scaling | `bool` | `false` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Environment variables to pass to the container | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_execution_role_arn"></a> [execution\_role\_arn](#input\_execution\_role\_arn) | ARN of the IAM role for ECS task execution (required for pulling images from ECR, writing logs) | `string` | n/a | yes |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | Seconds to wait before starting health checks after task starts | `number` | `60` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | CloudWatch Logs retention period in days | `number` | `7` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | Maximum number of tasks for auto-scaling | `number` | `10` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Fargate task memory in MB. Must be valid for the selected CPU. See AWS docs for valid combinations | `string` | `"512"` | no |
| <a name="input_min_capacity"></a> [min\_capacity](#input\_min\_capacity) | Minimum number of tasks for auto-scaling | `number` | `1` | no |
| <a name="input_scale_in_cooldown"></a> [scale\_in\_cooldown](#input\_scale\_in\_cooldown) | Cooldown period (in seconds) after a scale-in activity | `number` | `300` | no |
| <a name="input_scale_out_cooldown"></a> [scale\_out\_cooldown](#input\_scale\_out\_cooldown) | Cooldown period (in seconds) after a scale-out activity | `number` | `60` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs to attach to ECS tasks | `list(string)` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the ECS service | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for ECS tasks (typically private subnets) | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_target_cpu_utilization"></a> [target\_cpu\_utilization](#input\_target\_cpu\_utilization) | Target CPU utilization percentage for auto-scaling | `number` | `60` | no |
| <a name="input_target_group_arn"></a> [target\_group\_arn](#input\_target\_group\_arn) | ARN of the ALB target group to attach to the ECS service | `string` | n/a | yes |
| <a name="input_target_memory_utilization"></a> [target\_memory\_utilization](#input\_target\_memory\_utilization) | Target memory utilization percentage for auto-scaling | `number` | `80` | no |
| <a name="input_target_request_count_per_target"></a> [target\_request\_count\_per\_target](#input\_target\_request\_count\_per\_target) | Target number of ALB requests per task for auto-scaling | `number` | `100` | no |
| <a name="input_task_role_arn"></a> [task\_role\_arn](#input\_task\_role\_arn) | ARN of the IAM role for ECS tasks (optional, for AWS API access from within containers) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_scaling_policy_arn"></a> [alb\_scaling\_policy\_arn](#output\_alb\_scaling\_policy\_arn) | ARN of the ALB request count-based auto-scaling policy (if enabled) |
| <a name="output_autoscaling_max_capacity"></a> [autoscaling\_max\_capacity](#output\_autoscaling\_max\_capacity) | Maximum capacity for auto-scaling |
| <a name="output_autoscaling_min_capacity"></a> [autoscaling\_min\_capacity](#output\_autoscaling\_min\_capacity) | Minimum capacity for auto-scaling |
| <a name="output_autoscaling_target_resource_id"></a> [autoscaling\_target\_resource\_id](#output\_autoscaling\_target\_resource\_id) | Resource ID of the auto-scaling target |
| <a name="output_container_image"></a> [container\_image](#output\_container\_image) | Docker image used for the container |
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | Name of the container |
| <a name="output_container_port"></a> [container\_port](#output\_container\_port) | Port number the container listens on |
| <a name="output_cpu_scaling_policy_arn"></a> [cpu\_scaling\_policy\_arn](#output\_cpu\_scaling\_policy\_arn) | ARN of the CPU-based auto-scaling policy (if enabled) |
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | ARN of the CloudWatch log group |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | Name of the CloudWatch log group for ECS tasks |
| <a name="output_memory_scaling_policy_arn"></a> [memory\_scaling\_policy\_arn](#output\_memory\_scaling\_policy\_arn) | ARN of the memory-based auto-scaling policy (if enabled) |
| <a name="output_service_arn"></a> [service\_arn](#output\_service\_arn) | ARN of the ECS service |
| <a name="output_service_desired_count"></a> [service\_desired\_count](#output\_service\_desired\_count) | Desired count of tasks in the ECS service |
| <a name="output_service_id"></a> [service\_id](#output\_service\_id) | ID of the ECS service |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | Name of the ECS service |
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | ARN of the task definition (with revision number) |
| <a name="output_task_definition_family"></a> [task\_definition\_family](#output\_task\_definition\_family) | Family name of the task definition |
| <a name="output_task_definition_revision"></a> [task\_definition\_revision](#output\_task\_definition\_revision) | Revision number of the task definition |
<!-- END_TF_DOCS -->
</details>
