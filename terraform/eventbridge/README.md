# EventBridge Module

``` cd tests/basic terraform init -backend=false terraform plan ```

## Features

- Event Bus Management Support for both default and custom event buses
- Multiple Rule Types Scheduled rules (cron/rate expressions) and event pattern matching
- Rich Target Support Lambda, SQS, SNS, Step Functions, Kinesis, ECS, CloudWatch Logs, Batch
- Input Transformation JSONPath-based input transformation and template support
- Reliability Dead letter queue and retry policy configuration
- Cross-Account Built-in support for cross-account event delivery
- Auto IAM Automatic IAM role creation with least-privilege permissions based on target types
- Multi-Target Support for up to 5 targets per rule (AWS limit)

## Quick Start

```hcl
module "eventbridge" {
  source = "github.com/llamandcoco/infra-modules//terraform/eventbridge?ref=<commit-sha>"

  # Add required variables here
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|----------|
| Basic | [`tests/basic/`](tests/basic/) |
| Cross Account | [`tests/cross_account/`](tests/cross_account/) |
| Pattern | [`tests/pattern/`](tests/pattern/) |
| Scheduled | [`tests/scheduled/`](tests/scheduled/) |

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
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.26.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_bus.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_bus) | resource |
| [aws_cloudwatch_event_bus_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_bus_policy) | resource |
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_role.eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [null_resource.validate_rule_type](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_policy_arns"></a> [additional\_policy\_arns](#input\_additional\_policy\_arns) | List of additional IAM policy ARNs to attach to the role. Use for custom permissions beyond auto-generated target permissions. | `list(string)` | `[]` | no |
| <a name="input_allow_account_ids"></a> [allow\_account\_ids](#input\_allow\_account\_ids) | List of AWS account IDs allowed to send events to this event bus.<br/>Only applicable when create\_event\_bus is true (custom event bus).<br/>Leave empty to disable cross-account access. | `list(string)` | `[]` | no |
| <a name="input_caller_identity_override"></a> [caller\_identity\_override](#input\_caller\_identity\_override) | Optional override for caller identity (account\_id/arn/user\_id) to avoid STS calls during tests. | <pre>object({<br/>    account_id = string<br/>    arn        = string<br/>    user_id    = string<br/>  })</pre> | `null` | no |
| <a name="input_create_event_bus"></a> [create\_event\_bus](#input\_create\_event\_bus) | Whether to create a custom event bus. Set to false to use the default event bus.<br/>- true: Creates a new custom event bus with the name specified in event\_bus\_name<br/>- false: Uses the AWS default event bus (event\_bus\_name will be ignored if not 'default') | `bool` | `false` | no |
| <a name="input_create_role"></a> [create\_role](#input\_create\_role) | Whether to create an IAM role for EventBridge to invoke targets.<br/>- true: Automatically creates IAM role with least-privilege permissions based on target types<br/>- false: Use existing IAM role (must specify role\_arn in targets) | `bool` | `true` | no |
| <a name="input_event_bus_name"></a> [event\_bus\_name](#input\_event\_bus\_name) | Name of the EventBridge event bus. Use 'default' for the AWS default event bus, or provide a custom name to create a new event bus. | `string` | `"default"` | no |
| <a name="input_event_bus_policy_statement"></a> [event\_bus\_policy\_statement](#input\_event\_bus\_policy\_statement) | Custom event bus policy statement in JSON format. Use for advanced cross-account scenarios.<br/>If specified, this will be used instead of auto-generated policy from allow\_account\_ids.<br/>Only applicable when create\_event\_bus is true (custom event bus). | `string` | `null` | no |
| <a name="input_event_pattern"></a> [event\_pattern](#input\_event\_pattern) | Event pattern in JSON format. Matches events from AWS services or custom applications.<br/>Example:<br/>{<br/>  "source": ["aws.ec2"],<br/>  "detail-type": ["EC2 Instance State-change Notification"],<br/>  "detail": {<br/>    "state": ["running"]<br/>  }<br/>}<br/>Note: Either schedule\_expression or event\_pattern must be specified, but not both. | `string` | `null` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Whether the rule is enabled. Set to false to temporarily disable the rule without deleting it. | `bool` | `true` | no |
| <a name="input_role_description"></a> [role\_description](#input\_role\_description) | Description of the IAM role. Helps document the purpose of the role. | `string` | `null` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name of the IAM role to create. If not specified, a name will be generated based on the rule name. | `string` | `null` | no |
| <a name="input_role_path"></a> [role\_path](#input\_role\_path) | Path for the IAM role. Useful for organizing roles in your AWS account. | `string` | `"/"` | no |
| <a name="input_role_permissions_boundary"></a> [role\_permissions\_boundary](#input\_role\_permissions\_boundary) | ARN of the policy to use as the permissions boundary for the IAM role. | `string` | `null` | no |
| <a name="input_rule_description"></a> [rule\_description](#input\_rule\_description) | Description of the EventBridge rule. Helps document the purpose of the rule. | `string` | `null` | no |
| <a name="input_rule_name"></a> [rule\_name](#input\_rule\_name) | Name of the EventBridge rule. Must be unique within the event bus. | `string` | n/a | yes |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | Schedule expression for the rule. Use either rate() or cron() expressions.<br/>Examples:<br/>- Rate: "rate(5 minutes)", "rate(1 hour)", "rate(1 day)"<br/>- Cron: "cron(0 12 * * ? *)" (daily at noon UTC), "cron(0 9 ? * MON-FRI *)" (weekdays at 9 AM)<br/>Note: Either schedule\_expression or event\_pattern must be specified, but not both. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. Use this to add consistent tagging across your infrastructure. | `map(string)` | `{}` | no |
| <a name="input_targets"></a> [targets](#input\_targets) | List of targets for the EventBridge rule. Each target represents a service to invoke when the rule matches.<br/>AWS allows up to 5 targets per rule.<br/><br/>Required fields:<br/>- target\_id: Unique identifier for the target (used for tracking)<br/>- arn: ARN of the target resource (Lambda, SQS, SNS, Step Functions, Kinesis, ECS, CloudWatch Logs)<br/><br/>Optional fields for input transformation:<br/>- input: Static JSON input to pass to the target (conflicts with input\_path and input\_transformer)<br/>- input\_path: JSONPath expression to select part of the event (conflicts with input and input\_transformer)<br/>- input\_transformer: Complex input transformation configuration (conflicts with input and input\_path)<br/><br/>Optional fields for reliability:<br/>- dead\_letter\_config: Configuration for dead letter queue when target invocation fails<br/>  - arn: ARN of the SQS queue or SNS topic to use as DLQ<br/>- retry\_policy: Retry configuration for failed invocations<br/>  - maximum\_retry\_attempts: Number of retry attempts (0-185, default: 185)<br/>  - maximum\_event\_age\_in\_seconds: Maximum age of event in seconds (60-86400, default: 86400)<br/><br/>Optional fields for IAM:<br/>- role\_arn: Custom IAM role ARN for invoking the target (auto-created if null and create\_role is true)<br/><br/>Target-specific configurations:<br/>- sqs\_parameters: SQS-specific settings<br/>  - message\_group\_id: Message group ID for FIFO queues<br/>- ecs\_parameters: ECS-specific settings<br/>  - task\_definition\_arn: Task definition ARN<br/>  - task\_count: Number of tasks to launch (default: 1)<br/>  - launch\_type: Launch type (EC2 or FARGATE)<br/>  - network\_configuration: Network configuration for awsvpc mode<br/>  - platform\_version: Fargate platform version (default: LATEST)<br/>  - group: Task group name<br/>  - capacity\_provider\_strategy: Capacity provider strategy<br/>  - enable\_ecs\_managed\_tags: Enable ECS managed tags (default: false)<br/>  - enable\_execute\_command: Enable ECS Exec (default: false)<br/>  - placement\_constraints: Placement constraints<br/>  - placement\_strategy: Placement strategy<br/>  - propagate\_tags: Propagate tags from task definition (TASK\_DEFINITION or none)<br/>  - tags: Tags for the task<br/>- batch\_parameters: Batch-specific settings<br/>  - job\_definition: Job definition ARN<br/>  - job\_name: Job name<br/>  - array\_properties: Array job properties<br/>  - retry\_strategy: Retry strategy<br/>- kinesis\_parameters: Kinesis-specific settings<br/>  - partition\_key\_path: JSONPath to partition key<br/>- run\_command\_parameters: SSM Run Command settings<br/>  - run\_command\_targets: Run command targets<br/>- http\_parameters: API Destinations settings (future enhancement)<br/>  - path\_parameter\_values: Path parameter values<br/>  - header\_parameters: Header parameters<br/>  - query\_string\_parameters: Query string parameters | <pre>list(object({<br/>    target_id = string<br/>    arn       = string<br/>    role_arn  = optional(string)<br/><br/>    # Input transformation<br/>    input      = optional(string)<br/>    input_path = optional(string)<br/>    input_transformer = optional(object({<br/>      input_paths_map = map(string)<br/>      input_template  = string<br/>    }))<br/><br/>    # Reliability<br/>    dead_letter_config = optional(object({<br/>      arn = string<br/>    }))<br/>    retry_policy = optional(object({<br/>      maximum_retry_attempts       = optional(number)<br/>      maximum_event_age_in_seconds = optional(number)<br/>    }))<br/><br/>    # Target-specific configurations<br/>    sqs_parameters = optional(object({<br/>      message_group_id = optional(string)<br/>    }))<br/>    ecs_parameters = optional(object({<br/>      task_definition_arn = string<br/>      task_count          = optional(number, 1)<br/>      launch_type         = optional(string)<br/>      network_configuration = optional(object({<br/>        subnets          = list(string)<br/>        security_groups  = optional(list(string))<br/>        assign_public_ip = optional(bool)<br/>      }))<br/>      platform_version = optional(string)<br/>      group            = optional(string)<br/>      capacity_provider_strategy = optional(list(object({<br/>        capacity_provider = string<br/>        weight            = optional(number)<br/>        base              = optional(number)<br/>      })))<br/>      enable_ecs_managed_tags = optional(bool)<br/>      enable_execute_command  = optional(bool)<br/>      placement_constraints = optional(list(object({<br/>        type       = string<br/>        expression = optional(string)<br/>      })))<br/>      placement_strategy = optional(list(object({<br/>        type  = string<br/>        field = optional(string)<br/>      })))<br/>      propagate_tags = optional(string)<br/>      tags           = optional(map(string))<br/>    }))<br/>    batch_parameters = optional(object({<br/>      job_definition = string<br/>      job_name       = string<br/>      array_properties = optional(object({<br/>        size = number<br/>      }))<br/>      retry_strategy = optional(object({<br/>        attempts = number<br/>      }))<br/>    }))<br/>    kinesis_parameters = optional(object({<br/>      partition_key_path = string<br/>    }))<br/>    run_command_parameters = optional(object({<br/>      run_command_targets = list(object({<br/>        key    = string<br/>        values = list(string)<br/>      }))<br/>    }))<br/>    http_parameters = optional(object({<br/>      path_parameter_values   = optional(map(string))<br/>      header_parameters       = optional(map(string))<br/>      query_string_parameters = optional(map(string))<br/>    }))<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_event_bus_arn"></a> [event\_bus\_arn](#output\_event\_bus\_arn) | ARN of the EventBridge event bus. Use this to reference the event bus in other resources or for cross-account configuration. |
| <a name="output_event_bus_name"></a> [event\_bus\_name](#output\_event\_bus\_name) | Name of the EventBridge event bus. Use this to send events to the bus. |
| <a name="output_event_bus_policy_id"></a> [event\_bus\_policy\_id](#output\_event\_bus\_policy\_id) | ID of the event bus policy (for cross-account access). Returns null if no policy is created. |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN of the IAM role created for EventBridge to invoke targets. Returns null if create\_role is false. |
| <a name="output_role_id"></a> [role\_id](#output\_role\_id) | ID of the IAM role created for EventBridge. Returns null if create\_role is false. |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name of the IAM role created for EventBridge. Returns null if create\_role is false. |
| <a name="output_role_unique_id"></a> [role\_unique\_id](#output\_role\_unique\_id) | Unique ID of the IAM role. Returns null if create\_role is false. |
| <a name="output_rule_arn"></a> [rule\_arn](#output\_rule\_arn) | ARN of the EventBridge rule. Use this for IAM policies or monitoring. |
| <a name="output_rule_description"></a> [rule\_description](#output\_rule\_description) | Description of the EventBridge rule. |
| <a name="output_rule_event_pattern"></a> [rule\_event\_pattern](#output\_rule\_event\_pattern) | Event pattern of the rule (if it's an event pattern rule). |
| <a name="output_rule_id"></a> [rule\_id](#output\_rule\_id) | ID of the EventBridge rule. Unique identifier for the rule. |
| <a name="output_rule_is_enabled"></a> [rule\_is\_enabled](#output\_rule\_is\_enabled) | Whether the EventBridge rule is enabled. |
| <a name="output_rule_name"></a> [rule\_name](#output\_rule\_name) | Name of the EventBridge rule. |
| <a name="output_rule_schedule_expression"></a> [rule\_schedule\_expression](#output\_rule\_schedule\_expression) | Schedule expression of the rule (if it's a scheduled rule). |
| <a name="output_target_arns"></a> [target\_arns](#output\_target\_arns) | List of target ARNs configured for the EventBridge rule. |
| <a name="output_target_ids"></a> [target\_ids](#output\_target\_ids) | List of target IDs configured for the EventBridge rule. |
<!-- END_TF_DOCS -->
</details>
