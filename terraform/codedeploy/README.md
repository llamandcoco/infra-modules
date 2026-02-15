# CodeDeploy Module

Terraform module for provisioning AWS CodeDeploy applications and deployment groups with support for EC2, Lambda, and ECS deployments.

## Features

- CodeDeploy application for Server (EC2/On-Premises), Lambda, or ECS
- Deployment group with customizable deployment strategies
- Optional IAM service role creation with AWS managed policies
- Blue/Green deployment support for EC2 and ECS
- Auto rollback on failure or CloudWatch alarm threshold breach
- Load balancer integration (ALB/ELB) for traffic shifting
- SNS notifications for deployment events
- CloudWatch alarm monitoring during deployments

## Quick Start

```hcl
module "codedeploy" {
  source = "github.com/llamandcoco/infra-modules//terraform/codedeploy?ref=<commit-sha>"

  application_name      = "my-app"
  deployment_group_name = "production"

  # Deploy to EC2 instances with specific tags
  ec2_tag_filters = [
    {
      key   = "Environment"
      type  = "KEY_AND_VALUE"
      value = "production"
    }
  ]
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic EC2 Deployment | [`tests/basic/main.tf`](tests/basic/main.tf) |
| EC2 Blue/Green with Auto Rollback | [`tests/ec2/main.tf`](tests/ec2/main.tf) |
| Lambda Canary Deployment | [`tests/lambda/main.tf`](tests/lambda/main.tf) |

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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_codedeploy_app.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_app) | resource |
| [aws_codedeploy_deployment_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_deployment_group) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.codedeploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_names"></a> [alarm\_names](#input\_alarm\_names) | List of CloudWatch alarm names to monitor during deployment. | `list(string)` | `[]` | no |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | The name of the CodeDeploy application. | `string` | n/a | yes |
| <a name="input_auto_rollback_enabled"></a> [auto\_rollback\_enabled](#input\_auto\_rollback\_enabled) | Enable automatic rollback on deployment failure or alarm threshold breach. | `bool` | `false` | no |
| <a name="input_auto_rollback_events"></a> [auto\_rollback\_events](#input\_auto\_rollback\_events) | List of events that can trigger automatic rollback. Valid values: DEPLOYMENT\_FAILURE, DEPLOYMENT\_STOP\_ON\_ALARM, DEPLOYMENT\_STOP\_ON\_REQUEST. | `list(string)` | <pre>[<br>  "DEPLOYMENT_FAILURE"<br>]</pre> | no |
| <a name="input_autoscaling_groups"></a> [autoscaling\_groups](#input\_autoscaling\_groups) | List of Auto Scaling Group names to deploy to. | `list(string)` | `[]` | no |
| <a name="input_blue_green_deployment_config"></a> [blue\_green\_deployment\_config](#input\_blue\_green\_deployment\_config) | Blue/Green deployment configuration for EC2/On-Premises or ECS deployments. | <pre>object({<br>    terminate_blue_instances_action  = string<br>    termination_wait_time_in_minutes = number<br>    deployment_ready_action          = string<br>    green_fleet_provisioning_action  = string<br>  })</pre> | `null` | no |
| <a name="input_compute_platform"></a> [compute\_platform](#input\_compute\_platform) | The compute platform on which CodeDeploy deploys the application.<br>Valid values: Server (EC2/On-Premises), Lambda, ECS. | `string` | `"Server"` | no |
| <a name="input_create_service_role"></a> [create\_service\_role](#input\_create\_service\_role) | Whether to create a new IAM service role for CodeDeploy. If false, service\_role\_arn must be provided. | `bool` | `true` | no |
| <a name="input_deployment_config_name"></a> [deployment\_config\_name](#input\_deployment\_config\_name) | The name of the deployment configuration.<br>For EC2/On-Premises: CodeDeployDefault.OneAtATime, CodeDeployDefault.HalfAtATime, CodeDeployDefault.AllAtOnce<br>For Lambda: CodeDeployDefault.LambdaCanary10Percent5Minutes, CodeDeployDefault.LambdaLinear10PercentEvery1Minute, CodeDeployDefault.LambdaAllAtOnce<br>For ECS: CodeDeployDefault.ECSAllAtOnce, CodeDeployDefault.ECSLinear10PercentEvery1Minutes, CodeDeployDefault.ECSCanary10Percent5Minutes | `string` | `"CodeDeployDefault.OneAtATime"` | no |
| <a name="input_deployment_group_name"></a> [deployment\_group\_name](#input\_deployment\_group\_name) | The name of the deployment group. | `string` | n/a | yes |
| <a name="input_deployment_type"></a> [deployment\_type](#input\_deployment\_type) | Deployment type for Lambda deployments. Valid values: BLUE\_GREEN, IN\_PLACE. | `string` | `"BLUE_GREEN"` | no |
| <a name="input_ec2_tag_filters"></a> [ec2\_tag\_filters](#input\_ec2\_tag\_filters) | List of EC2 tag filters to identify instances for deployment.<br>Each filter should have: key, type (KEY\_ONLY, VALUE\_ONLY, KEY\_AND\_VALUE), and value. | <pre>list(object({<br>    key   = string<br>    type  = string<br>    value = string<br>  }))</pre> | `[]` | no |
| <a name="input_ecs_service"></a> [ecs\_service](#input\_ecs\_service) | ECS service configuration for ECS deployments. | <pre>object({<br>    cluster_name = string<br>    service_name = string<br>  })</pre> | `null` | no |
| <a name="input_ignore_poll_alarm_failure"></a> [ignore\_poll\_alarm\_failure](#input\_ignore\_poll\_alarm\_failure) | Whether to ignore failures in polling CloudWatch alarms. | `bool` | `false` | no |
| <a name="input_load_balancer_info"></a> [load\_balancer\_info](#input\_load\_balancer\_info) | Load balancer configuration for deployment group. | <pre>object({<br>    target_group_names = list(string)<br>    elb_names          = list(string)<br>  })</pre> | `null` | no |
| <a name="input_service_role_arn"></a> [service\_role\_arn](#input\_service\_role\_arn) | ARN of an existing IAM role for CodeDeploy. Required when create\_service\_role is false. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_trigger_configurations"></a> [trigger\_configurations](#input\_trigger\_configurations) | List of trigger configurations for deployment notifications.<br>Each trigger should have: trigger\_name, trigger\_events (list), and trigger\_target\_arn (SNS topic ARN). | <pre>list(object({<br>    trigger_name       = string<br>    trigger_events     = list(string)<br>    trigger_target_arn = string<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_arn"></a> [application\_arn](#output\_application\_arn) | The ARN of the CodeDeploy application. |
| <a name="output_application_id"></a> [application\_id](#output\_application\_id) | The ID of the CodeDeploy application. |
| <a name="output_application_name"></a> [application\_name](#output\_application\_name) | The name of the CodeDeploy application. |
| <a name="output_compute_platform"></a> [compute\_platform](#output\_compute\_platform) | The compute platform of the CodeDeploy application. |
| <a name="output_deployment_group_arn"></a> [deployment\_group\_arn](#output\_deployment\_group\_arn) | The ARN of the deployment group. |
| <a name="output_deployment_group_id"></a> [deployment\_group\_id](#output\_deployment\_group\_id) | The ID of the deployment group. |
| <a name="output_deployment_group_name"></a> [deployment\_group\_name](#output\_deployment\_group\_name) | The name of the deployment group. |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | The ARN of the IAM role used by CodeDeploy. |
| <a name="output_role_id"></a> [role\_id](#output\_role\_id) | The ID of the IAM role used by CodeDeploy (if created). |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | The name of the IAM role used by CodeDeploy (if created). |
<!-- END_TF_DOCS -->
</details>
