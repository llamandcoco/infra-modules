# ECS Task Role Module

This module creates an IAM role for **ECS tasks** to access AWS services.

## What is a Task Role?

The **task role** is used by your **container code** to make AWS API calls. For example:
- Your app reads/writes to S3
- Your app queries DynamoDB
- Your app sends messages to SQS
- Your app invokes Lambda functions

**Important:** This is NOT the execution role (which is used by the ECS agent to pull images and send logs).

## When to Use This Module

Use this module when your containerized application needs to:
- Access AWS resources (S3, DynamoDB, SQS, etc.)
- Make AWS SDK/CLI calls from within the container
- Use AWS service integrations

Don't use this module if you only need to run containers - use `ecs-execution-role` instead.

## Usage

### Basic Example

```hcl
module "task_role" {
  source = "../../terraform/ecs-task-role"

  name = "my-app-task-role"

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}
```

### Example with S3 Access

```hcl
module "task_role" {
  source = "../../terraform/ecs-task-role"

  name = "my-app-task-role"

  enable_s3_access = true
  s3_bucket_arns = [
    "arn:aws:s3:::my-uploads-bucket",
    "arn:aws:s3:::my-data-bucket"
  ]

  tags = {
    Environment = "production"
  }
}
```

### Example with DynamoDB Access

```hcl
module "task_role" {
  source = "../../terraform/ecs-task-role"

  name = "my-app-task-role"

  enable_dynamodb_access = true
  dynamodb_table_arns = [
    "arn:aws:dynamodb:us-east-1:123456789012:table/Users",
    "arn:aws:dynamodb:us-east-1:123456789012:table/Orders"
  ]

  tags = {
    Environment = "production"
  }
}
```

### Example with Multiple Services

```hcl
module "task_role" {
  source = "../../terraform/ecs-task-role"

  name = "my-app-task-role"

  enable_s3_access = true
  s3_bucket_arns   = ["arn:aws:s3:::my-bucket"]

  enable_dynamodb_access = true
  dynamodb_table_arns    = ["arn:aws:dynamodb:us-east-1:123456789012:table/MyTable"]

  enable_sqs_access = true
  sqs_queue_arns    = ["arn:aws:sqs:us-east-1:123456789012:my-queue"]

  enable_secrets_manager = true
  secret_arns = [
    "arn:aws:secretsmanager:us-east-1:123456789012:secret:db-password-abc123"
  ]

  tags = {
    Environment = "production"
  }
}
```

### Example with Custom Policies

```hcl
module "task_role" {
  source = "../../terraform/ecs-task-role"

  name = "my-app-task-role"

  # Attach AWS managed policies
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
  ]

  # Add custom inline policies
  inline_policies = {
    custom_lambda = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "lambda:InvokeFunction"
          ]
          Resource = "arn:aws:lambda:us-east-1:123456789012:function:my-function"
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
| With Policies | [`tests/with_policies/main.tf`](tests/with_policies/main.tf) |

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

# Create the task role (for container code)
module "task_role" {
  source = "../../terraform/ecs-task-role"

  name = "my-app-task-role"

  enable_s3_access       = true
  s3_bucket_arns         = ["arn:aws:s3:::my-bucket"]

  enable_dynamodb_access = true
  dynamodb_table_arns    = ["arn:aws:dynamodb:us-east-1:123456789012:table/MyTable"]
}

# Create the ECS service
module "ecs" {
  source = "../../terraform/ecs"

  cluster_name   = "my-cluster"
  container_name = "my-app"
  container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest"
  container_port = 8080

  execution_role_arn = module.execution_role.role_arn  # For ECS agent
  task_role_arn      = module.task_role.role_arn       # For container code

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
| name | Name of the ECS task role | `string` | n/a | yes |
| managed_policy_arns | List of AWS managed policy ARNs to attach | `list(string)` | `[]` | no |
| inline_policies | Map of inline policy names to JSON policy documents | `map(string)` | `{}` | no |
| enable_s3_access | Enable S3 access permissions | `bool` | `false` | no |
| s3_bucket_arns | List of S3 bucket ARNs to grant access to | `list(string)` | `[]` | no |
| s3_actions | List of S3 actions to allow | `list(string)` | See variables.tf | no |
| enable_dynamodb_access | Enable DynamoDB access permissions | `bool` | `false` | no |
| dynamodb_table_arns | List of DynamoDB table ARNs to grant access to | `list(string)` | `[]` | no |
| dynamodb_actions | List of DynamoDB actions to allow | `list(string)` | See variables.tf | no |
| enable_sqs_access | Enable SQS access permissions | `bool` | `false` | no |
| sqs_queue_arns | List of SQS queue ARNs to grant access to | `list(string)` | `[]` | no |
| sqs_actions | List of SQS actions to allow | `list(string)` | See variables.tf | no |
| enable_secrets_manager | Enable Secrets Manager access permissions | `bool` | `false` | no |
| secret_arns | List of Secrets Manager secret ARNs to grant access to | `list(string)` | `[]` | no |
| tags | Tags to apply to the IAM role | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| role_arn | ARN of the ECS task role |
| role_name | Name of the ECS task role |
| role_id | ID of the ECS task role |

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
| [aws_iam_role_policy.dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.inline_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.secrets_manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.managed_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.secrets_manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dynamodb_actions"></a> [dynamodb\_actions](#input\_dynamodb\_actions) | List of DynamoDB actions to allow | `list(string)` | <pre>[<br/>  "dynamodb:GetItem",<br/>  "dynamodb:PutItem",<br/>  "dynamodb:UpdateItem",<br/>  "dynamodb:DeleteItem",<br/>  "dynamodb:Query",<br/>  "dynamodb:Scan"<br/>]</pre> | no |
| <a name="input_dynamodb_table_arns"></a> [dynamodb\_table\_arns](#input\_dynamodb\_table\_arns) | List of DynamoDB table ARNs to grant access to | `list(string)` | `[]` | no |
| <a name="input_enable_dynamodb_access"></a> [enable\_dynamodb\_access](#input\_enable\_dynamodb\_access) | Enable DynamoDB access permissions | `bool` | `false` | no |
| <a name="input_enable_s3_access"></a> [enable\_s3\_access](#input\_enable\_s3\_access) | Enable S3 access permissions | `bool` | `false` | no |
| <a name="input_enable_secrets_manager"></a> [enable\_secrets\_manager](#input\_enable\_secrets\_manager) | Enable Secrets Manager access permissions | `bool` | `false` | no |
| <a name="input_enable_sqs_access"></a> [enable\_sqs\_access](#input\_enable\_sqs\_access) | Enable SQS access permissions | `bool` | `false` | no |
| <a name="input_inline_policies"></a> [inline\_policies](#input\_inline\_policies) | Map of inline policy names to JSON policy documents | `map(string)` | `{}` | no |
| <a name="input_managed_policy_arns"></a> [managed\_policy\_arns](#input\_managed\_policy\_arns) | List of AWS managed policy ARNs to attach to the role | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the ECS task role | `string` | n/a | yes |
| <a name="input_s3_actions"></a> [s3\_actions](#input\_s3\_actions) | List of S3 actions to allow | `list(string)` | <pre>[<br/>  "s3:GetObject",<br/>  "s3:PutObject",<br/>  "s3:DeleteObject",<br/>  "s3:ListBucket"<br/>]</pre> | no |
| <a name="input_s3_bucket_arns"></a> [s3\_bucket\_arns](#input\_s3\_bucket\_arns) | List of S3 bucket ARNs to grant access to | `list(string)` | `[]` | no |
| <a name="input_secret_arns"></a> [secret\_arns](#input\_secret\_arns) | List of Secrets Manager secret ARNs to grant access to | `list(string)` | `[]` | no |
| <a name="input_sqs_actions"></a> [sqs\_actions](#input\_sqs\_actions) | List of SQS actions to allow | `list(string)` | <pre>[<br/>  "sqs:SendMessage",<br/>  "sqs:ReceiveMessage",<br/>  "sqs:DeleteMessage",<br/>  "sqs:GetQueueAttributes"<br/>]</pre> | no |
| <a name="input_sqs_queue_arns"></a> [sqs\_queue\_arns](#input\_sqs\_queue\_arns) | List of SQS queue ARNs to grant access to | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the IAM role | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN of the ECS task role |
| <a name="output_role_id"></a> [role\_id](#output\_role\_id) | ID of the ECS task role |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name of the ECS task role |
<!-- END_TF_DOCS -->
</details>
