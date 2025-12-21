# AWS Bedrock

A production-ready Terraform module for configuring AWS Bedrock foundation models with IAM roles and model invocation logging.

## Features

- **Service Role Creation** - IAM roles for Lambda, ECS, EC2, and other services to invoke Bedrock models
- **Model Invocation Logging** - CloudWatch and S3 logging for auditing and debugging
- **Flexible Model Access** - Granular control over which foundation models can be accessed
- **Comprehensive Outputs** - Model ARNs, role ARNs, and logging configuration details

## Quick Start

```hcl
module "bedrock" {
  source = "github.com/llamandcoco/infra-modules//terraform/bedrock?ref=<commit-sha>"

  # Create role for Lambda to invoke Bedrock
  create_service_role = true
  service_role_name   = "my-bedrock-lambda-role"
  service_principals  = ["lambda.amazonaws.com"]

  # Allow access to Claude models
  allowed_model_arns = [
    "arn:aws:bedrock:*::foundation-model/anthropic.claude-3-5-sonnet-20241022-v2:0"
  ]

  # Enable logging for production
  enable_model_invocation_logging = true
  log_retention_days              = 30
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|----------|
| Basic - Service role only | [`tests/basic/main.tf`](tests/basic/main.tf) |
| Advanced - With logging and multiple services | [`tests/advanced/main.tf`](tests/advanced/main.tf) |

**Usage:**
```bash
# View example
cat tests/basic/main.tf

# Copy and adapt
cp -r tests/basic/ my-project/
```

## Use Cases

### Lambda Function Invoking Bedrock
```hcl
module "bedrock" {
  source = "github.com/llamandcoco/infra-modules//terraform/bedrock?ref=<commit-sha>"

  create_service_role = true
  service_role_name   = "my-lambda-bedrock-role"
  service_principals  = ["lambda.amazonaws.com"]
  allowed_model_arns  = ["arn:aws:bedrock:*::foundation-model/*"]
}

# Use in Lambda module
module "my_agent_lambda" {
  source = "github.com/llamandcoco/infra-modules//terraform/lambda?ref=<commit-sha>"

  function_name = "my-ai-agent"
  runtime       = "python3.12"
  handler       = "app.handler"
  filename      = "lambda.zip"

  additional_policy_arns = [
    # This role has permissions to invoke Bedrock
    module.bedrock.service_role_arn
  ]
}
```

### Production with Logging
```hcl
module "bedrock" {
  source = "github.com/llamandcoco/infra-modules//terraform/bedrock?ref=<commit-sha>"

  # Service role
  create_service_role = true
  service_role_name   = "production-bedrock-role"
  service_principals  = ["lambda.amazonaws.com", "ecs-tasks.amazonaws.com"]

  # Logging
  enable_model_invocation_logging = true
  log_group_name                  = "/aws/bedrock/production"
  log_retention_days              = 90
  log_text_data                   = true
  log_image_data                  = true
}
```

## Common Model ARNs

The module outputs common model ARNs for convenience:

```hcl
output "claude_3_5_sonnet_arn" {
  value = module.bedrock.claude_3_5_sonnet_arn
  # arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-5-sonnet-20241022-v2:0
}

output "claude_3_opus_arn" {
  value = module.bedrock.claude_3_opus_arn
  # arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-opus-20240229-v1:0
}

output "llama_3_1_70b_arn" {
  value = module.bedrock.llama_3_1_70b_arn
  # arn:aws:bedrock:us-east-1::foundation-model/meta.llama3-1-70b-instruct-v1:0
}
```

## Testing

```bash
# Basic test
cd tests/basic && terraform init && terraform plan

# Advanced test
cd tests/advanced && terraform init && terraform plan
```

## Notes

- **Bedrock Availability**: AWS Bedrock is not available in all regions. Check [AWS documentation](https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html) for regional availability.
- **Model Access**: Some foundation models require requesting access through the AWS Console before use.
- **Logging Costs**: Model invocation logging to CloudWatch and S3 incurs additional costs. Configure retention periods appropriately.
- **IAM Permissions**: The service role only grants `bedrock:InvokeModel` permissions. Add additional policies for other AWS services as needed.

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
| [aws_bedrock_model_invocation_logging_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrock_model_invocation_logging_configuration) | resource |
| [aws_cloudwatch_log_group.bedrock](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.bedrock_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.bedrock_invoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.bedrock_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.service_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_service_policy_arns"></a> [additional\_service\_policy\_arns](#input\_additional\_service\_policy\_arns) | List of additional IAM policy ARNs to attach to the Bedrock service role. Use for granting access to S3, DynamoDB, or other AWS services. | `list(string)` | `[]` | no |
| <a name="input_allowed_model_arns"></a> [allowed\_model\_arns](#input\_allowed\_model\_arns) | List of Bedrock model ARNs that the service role can invoke. Use wildcards for flexibility (e.g., 'arn:aws:bedrock:*:*:foundation-model/*' for all models). Common model IDs: anthropic.claude-3-5-sonnet-20241022-v2:0, anthropic.claude-3-opus-20240229, meta.llama3-1-70b-instruct-v1:0. | `list(string)` | <pre>[<br/>  "arn:aws:bedrock:*::foundation-model/*"<br/>]</pre> | no |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | AWS Account ID. If not provided, will be detected automatically using AWS API. Set this to a dummy value (e.g., '123456789012') for CI/CD testing without credentials. | `string` | `null` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region. If not provided, will be detected automatically using AWS API. Set this to a dummy value (e.g., 'us-east-1') for CI/CD testing without credentials. | `string` | `null` | no |
| <a name="input_create_service_role"></a> [create\_service\_role](#input\_create\_service\_role) | Whether to create an IAM role for AWS services (Lambda, ECS, EC2, etc.) to invoke Bedrock models. Set to true if you need services to call Bedrock. | `bool` | `false` | no |
| <a name="input_enable_model_invocation_logging"></a> [enable\_model\_invocation\_logging](#input\_enable\_model\_invocation\_logging) | Enable logging of Bedrock model invocations to CloudWatch and/or S3. Useful for auditing, debugging, and monitoring model usage. | `bool` | `false` | no |
| <a name="input_log_embedding_data"></a> [log\_embedding\_data](#input\_log\_embedding\_data) | Whether to log embedding data from model invocations. Enable for debugging embedding models. | `bool` | `false` | no |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | Name of the CloudWatch log group for Bedrock model invocation logs. If not specified, defaults to '/aws/bedrock/modelinvocations'. | `string` | `null` | no |
| <a name="input_log_image_data"></a> [log\_image\_data](#input\_log\_image\_data) | Whether to log image input/output data from model invocations. Enable for debugging image-based models. | `bool` | `false` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Number of days to retain CloudWatch logs for Bedrock model invocations. Common values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653. | `number` | `30` | no |
| <a name="input_log_text_data"></a> [log\_text\_data](#input\_log\_text\_data) | Whether to log text input/output data from model invocations. Enable for debugging prompts and responses. | `bool` | `true` | no |
| <a name="input_logging_role_name"></a> [logging\_role\_name](#input\_logging\_role\_name) | Name of the IAM role for Bedrock to write logs to CloudWatch. If not specified, defaults to 'bedrock-model-invocation-logging-role'. | `string` | `null` | no |
| <a name="input_s3_logging_bucket"></a> [s3\_logging\_bucket](#input\_s3\_logging\_bucket) | Optional S3 bucket name for storing Bedrock model invocation logs. Use for long-term log archival or compliance requirements. | `string` | `null` | no |
| <a name="input_s3_logging_key_prefix"></a> [s3\_logging\_key\_prefix](#input\_s3\_logging\_key\_prefix) | Optional S3 key prefix for Bedrock model invocation logs. Used when s3\_logging\_bucket is specified. | `string` | `"bedrock-logs/"` | no |
| <a name="input_service_principals"></a> [service\_principals](#input\_service\_principals) | List of AWS service principals that can assume the Bedrock service role. Common values: ['lambda.amazonaws.com', 'ecs-tasks.amazonaws.com', 'ec2.amazonaws.com']. | `list(string)` | <pre>[<br/>  "lambda.amazonaws.com"<br/>]</pre> | no |
| <a name="input_service_role_name"></a> [service\_role\_name](#input\_service\_role\_name) | Name of the IAM role for services to invoke Bedrock models. Required if create\_service\_role is true. | `string` | `"bedrock-service-role"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. Use this for cost allocation, resource organization, and governance. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The AWS account ID where Bedrock resources are created. |
| <a name="output_claude_3_5_sonnet_arn"></a> [claude\_3\_5\_sonnet\_arn](#output\_claude\_3\_5\_sonnet\_arn) | ARN for Claude 3.5 Sonnet v2 model. Use this for invoking the model. |
| <a name="output_claude_3_haiku_arn"></a> [claude\_3\_haiku\_arn](#output\_claude\_3\_haiku\_arn) | ARN for Claude 3 Haiku model. Use this for invoking the model. |
| <a name="output_claude_3_opus_arn"></a> [claude\_3\_opus\_arn](#output\_claude\_3\_opus\_arn) | ARN for Claude 3 Opus model. Use this for invoking the model. |
| <a name="output_claude_3_sonnet_arn"></a> [claude\_3\_sonnet\_arn](#output\_claude\_3\_sonnet\_arn) | ARN for Claude 3 Sonnet model. Use this for invoking the model. |
| <a name="output_llama_3_1_70b_arn"></a> [llama\_3\_1\_70b\_arn](#output\_llama\_3\_1\_70b\_arn) | ARN for Llama 3.1 70B Instruct model. Use this for invoking the model. |
| <a name="output_llama_3_1_8b_arn"></a> [llama\_3\_1\_8b\_arn](#output\_llama\_3\_1\_8b\_arn) | ARN for Llama 3.1 8B Instruct model. Use this for invoking the model. |
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | The ARN of the CloudWatch log group for Bedrock model invocations. |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | The name of the CloudWatch log group for Bedrock model invocations. Use this to query logs or set up metric filters. |
| <a name="output_logging_role_arn"></a> [logging\_role\_arn](#output\_logging\_role\_arn) | The ARN of the IAM role used by Bedrock to write logs to CloudWatch. |
| <a name="output_logging_role_name"></a> [logging\_role\_name](#output\_logging\_role\_name) | The name of the IAM role used by Bedrock to write logs to CloudWatch. |
| <a name="output_model_invocation_logging_enabled"></a> [model\_invocation\_logging\_enabled](#output\_model\_invocation\_logging\_enabled) | Whether model invocation logging is enabled. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region where Bedrock resources are created. |
| <a name="output_service_role_arn"></a> [service\_role\_arn](#output\_service\_role\_arn) | The ARN of the Bedrock service IAM role. Use this to grant services permission to invoke Bedrock models. |
| <a name="output_service_role_id"></a> [service\_role\_id](#output\_service\_role\_id) | The unique ID of the Bedrock service IAM role. |
| <a name="output_service_role_name"></a> [service\_role\_name](#output\_service\_role\_name) | The name of the Bedrock service IAM role. Use this for attaching additional policies. |
<!-- END_TF_DOCS -->

</summary>
