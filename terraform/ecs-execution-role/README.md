# ECS Execution Role Module

This module creates an IAM role for **ECS task execution** - used by the ECS agent to manage your containers.

## What is an Execution Role?

The **execution role** is used by the **ECS agent** (not your code) to:
- Pull container images from Amazon ECR
- Send container logs to CloudWatch Logs
- Access secrets from AWS Systems Manager Parameter Store
- Access secrets from AWS Secrets Manager

**Important:** This is NOT the task role (which is used by your container code to access AWS services like S3, DynamoDB, etc.).

## When to Use This Module

Use this module for **every ECS service** - it's required for basic ECS functionality.

You need this role even if your container doesn't make any AWS API calls.

## Usage

### Basic Example

```hcl
module "execution_role" {
  source = "../../terraform/ecs-execution-role"

  name = "my-app-execution-role"

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}
```

### Example with All Features Enabled

```hcl
module "execution_role" {
  source = "../../terraform/ecs-execution-role"

  name = "my-app-execution-role"

  enable_ecr      = true  # Pull images from ECR
  enable_cw_logs  = true  # Send logs to CloudWatch
  enable_ssm      = true  # Access SSM Parameter Store
  enable_cw_agent = true  # CloudWatch Agent metrics

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}
```

### Example with Custom Policies

```hcl
module "execution_role" {
  source = "../../terraform/ecs-execution-role"

  name = "my-app-execution-role"

  enable_ecr     = true
  enable_cw_logs = true

  # Add custom policies
  additional_policies = {
    custom_secrets = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue"
          ]
          Resource = "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-secret-*"
        }
      ]
    })
  }

  tags = {
    Environment = "production"
  }
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|----------|
| Basic | [`tests/basic/main.tf`](tests/basic/main.tf) |
| With Additional Policies | [`tests/with_additional_policies/main.tf`](tests/with_additional_policies/main.tf) |

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

## Complete ECS Stack Example

```hcl
# Create the execution role (for ECS agent)
module "execution_role" {
  source = "../../terraform/ecs-execution-role"

  name = "my-app-execution-role"

  enable_ecr     = true
  enable_cw_logs = true
  enable_ssm     = true
}

# Create the task role (for container code) - OPTIONAL
module "task_role" {
  source = "../../terraform/ecs-task-role"

  name = "my-app-task-role"

  enable_s3_access    = true
  s3_bucket_arns      = ["arn:aws:s3:::my-bucket"]
}

# Create the ECS service
module "ecs" {
  source = "../../terraform/ecs"

  cluster_name   = "my-cluster"
  container_name = "my-app"
  container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest"
  container_port = 8080

  execution_role_arn = module.execution_role.role_arn  # Required: For ECS agent
  task_role_arn      = module.task_role.role_arn       # Optional: For container code

  subnet_ids         = var.private_subnet_ids
  security_group_ids = [var.app_security_group_id]
  target_group_arn   = module.alb.target_group_arn
}
```

## Key Differences: Execution Role vs Task Role

| Aspect | Execution Role | Task Role |
|--------|----------------|-----------|
| **Module** | `ecs-execution-role` | `ecs-task-role` |
| **Used By** | ECS agent | Container code |
| **Purpose** | Pull images, send logs | Access AWS services |
| **Common Permissions** | ECR, CloudWatch Logs, SSM | S3, DynamoDB, SQS, Lambda |
| **Required?** | Yes (always) | No (only if app needs AWS access) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the ECS execution role | `string` | n/a | yes |
| enable_ecr | Enable ECR read permissions for pulling container images | `bool` | `true` | no |
| enable_ssm | Enable SSM read permissions for parameter store access | `bool` | `false` | no |
| enable_cw_logs | Enable CloudWatch Logs permissions for container logging | `bool` | `true` | no |
| enable_cw_agent | Enable CloudWatch Agent permissions for custom metrics | `bool` | `false` | no |
| additional_policies | Map of additional IAM policy names to JSON policy documents | `map(string)` | `{}` | no |
| tags | Tags to apply to the IAM role | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| role_arn | ARN of the ECS execution role |
| role_name | Name of the ECS execution role |
| role_id | ID of the ECS execution role |

## What Permissions Are Included?

### Base Permissions (Always Attached)
- `AmazonECSTaskExecutionRolePolicy` - Core ECS task execution permissions

### Optional Permissions

#### ECR (enabled by default)
- `AmazonEC2ContainerRegistryReadOnly` - Pull images from ECR

#### SSM (disabled by default)
- `AmazonSSMReadOnlyAccess` - Read parameters from Parameter Store

#### CloudWatch Logs (enabled by default)
Custom inline policy with:
- `logs:CreateLogGroup`
- `logs:CreateLogStream`
- `logs:PutLogEvents`
- `logs:DescribeLogStreams`

#### CloudWatch Agent (disabled by default)
Custom inline policy with:
- `cloudwatch:PutMetricData`
- `ec2:DescribeVolumes`
- `ec2:DescribeTags`
- Plus CloudWatch Logs permissions

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
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.cloudwatch_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudwatch_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_policies"></a> [additional\_policies](#input\_additional\_policies) | Map of additional IAM policy names to JSON policy documents | `map(string)` | `{}` | no |
| <a name="input_enable_cw_agent"></a> [enable\_cw\_agent](#input\_enable\_cw\_agent) | Enable CloudWatch Agent permissions for custom metrics | `bool` | `false` | no |
| <a name="input_enable_cw_logs"></a> [enable\_cw\_logs](#input\_enable\_cw\_logs) | Enable CloudWatch Logs permissions for container logging | `bool` | `true` | no |
| <a name="input_enable_ecr"></a> [enable\_ecr](#input\_enable\_ecr) | Enable ECR read permissions for pulling container images | `bool` | `true` | no |
| <a name="input_enable_ssm"></a> [enable\_ssm](#input\_enable\_ssm) | Enable SSM read permissions for parameter store access | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the ECS execution role | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the IAM role | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN of the ECS execution role |
| <a name="output_role_id"></a> [role\_id](#output\_role\_id) | ID of the ECS execution role |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name of the ECS execution role |
<!-- END_TF_DOCS -->
</details>
