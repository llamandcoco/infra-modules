# ALB Target Group Module

Creates an ALB target group and (optionally) a listener rule that forwards traffic to it.
This is useful when the ALB is managed elsewhere (shared-infra) but target groups are owned by
service stacks (EC2 ASG, ECS Fargate, etc.).

## Features

- Create an ALB target group with health check configuration
- Attach tags to the target group
- Optional listener rule with path/host/header/method/query/source-ip conditions
- Outputs for ARN, ARN suffix, and listener rule IDs

## Quick Start

```hcl
module "alb_target_group" {
  source = "github.com/llamandcoco/infra-modules//terraform/alb-target-group?ref=<commit-sha>"

  # Add required variables here
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic | [`tests/basic/main.tf`](tests/basic/main.tf) |
| With Listener Rule | [`tests/with_listener_rule/main.tf`](tests/with_listener_rule/main.tf) |

**Usage:**
```bash
# View example
cat tests/basic/

# Copy and adapt
cp -r tests/basic/ my-project/
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the target group. Must be 1-32 characters, alphanumeric or hyphens. | string | n/a | yes |
| vpc_id | VPC ID where the target group will be created. | string | n/a | yes |
| port | Port for the target group. | number | n/a | yes |
| protocol | Protocol for the target group (HTTP or HTTPS). | string | n/a | yes |
| target_type | Target type (instance, ip, lambda, alb). | string | n/a | yes |
| deregistration_delay | Deregistration delay in seconds. | number | 300 | no |
| slow_start | Slow start duration in seconds (0 disables). | number | 0 | no |
| health_check | Health check configuration. | object | {} | no |
| tags | Tags to apply to all resources. | map(string) | {} | no |
| target_group_tags | Additional tags to apply to the target group only. | map(string) | {} | no |
| listener_arn | Listener ARN to attach a rule (optional). | string | null | no |
| listener_priority | Listener rule priority. Required if listener_arn is set. | number | null | no |
| listener_conditions | Listener rule conditions. Required if listener_arn is set. | list(object) | [] | no |

## Outputs

| Name | Description |
|------|-------------|
| target_group_arn | ARN of the target group. |
| target_group_arn_suffix | ARN suffix of the target group. |
| target_group_id | ID of the target group. |
| target_group_name | Name of the target group. |
| listener_rule_arn | ARN of the listener rule (if created). |
| listener_rule_id | ID of the listener rule (if created). |

## Notes
- Listener rules are created only when `listener_arn` is provided.
- Use unique `listener_priority` values per listener.

## Testing

```bash
cd tests/basic && terraform init -backend=false && terraform validate
cd tests/with_listener_rule && terraform init -backend=false && terraform validate
```

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.28.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb_listener_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deregistration_delay"></a> [deregistration\_delay](#input\_deregistration\_delay) | Deregistration delay in seconds. | `number` | `300` | no |
| <a name="input_health_check"></a> [health\_check](#input\_health\_check) | Health check configuration for the target group. | <pre>object({<br/>    enabled             = optional(bool)<br/>    healthy_threshold   = optional(number)<br/>    unhealthy_threshold = optional(number)<br/>    timeout             = optional(number)<br/>    interval            = optional(number)<br/>    path                = optional(string)<br/>    port                = optional(string)<br/>    protocol            = optional(string)<br/>    matcher             = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_listener_arn"></a> [listener\_arn](#input\_listener\_arn) | Listener ARN to attach a listener rule. If null, no rule is created. | `string` | `null` | no |
| <a name="input_listener_conditions"></a> [listener\_conditions](#input\_listener\_conditions) | Listener rule conditions. Required when listener\_arn is set. | <pre>list(object({<br/>    path_pattern = optional(object({<br/>      values = list(string)<br/>    }))<br/><br/>    host_header = optional(object({<br/>      values = list(string)<br/>    }))<br/><br/>    http_header = optional(object({<br/>      http_header_name = string<br/>      values           = list(string)<br/>    }))<br/><br/>    http_request_method = optional(object({<br/>      values = list(string)<br/>    }))<br/><br/>    query_string = optional(object({<br/>      key   = optional(string)<br/>      value = string<br/>    }))<br/><br/>    source_ip = optional(object({<br/>      values = list(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_listener_priority"></a> [listener\_priority](#input\_listener\_priority) | Listener rule priority. Required when listener\_arn is set. | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the target group. Must be 1-32 characters, alphanumeric or hyphens. | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | Port for the target group. | `number` | n/a | yes |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | Protocol for the target group (HTTP or HTTPS). | `string` | n/a | yes |
| <a name="input_slow_start"></a> [slow\_start](#input\_slow\_start) | Slow start duration in seconds (0 disables). | `number` | `0` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_target_group_tags"></a> [target\_group\_tags](#input\_target\_group\_tags) | Additional tags to apply to the target group only. | `map(string)` | `{}` | no |
| <a name="input_target_type"></a> [target\_type](#input\_target\_type) | Target type for the target group (instance, ip, lambda, alb). | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the target group will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_listener_rule_arn"></a> [listener\_rule\_arn](#output\_listener\_rule\_arn) | ARN of the listener rule (if created). |
| <a name="output_listener_rule_id"></a> [listener\_rule\_id](#output\_listener\_rule\_id) | ID of the listener rule (if created). |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | ARN of the target group. |
| <a name="output_target_group_arn_suffix"></a> [target\_group\_arn\_suffix](#output\_target\_group\_arn\_suffix) | ARN suffix of the target group. |
| <a name="output_target_group_id"></a> [target\_group\_id](#output\_target\_group\_id) | ID of the target group. |
| <a name="output_target_group_name"></a> [target\_group\_name](#output\_target\_group\_name) | Name of the target group. |
<!-- END_TF_DOCS -->

</details>
