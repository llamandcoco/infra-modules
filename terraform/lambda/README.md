# AWS Lambda Terraform Module

| Name | Description | |------|-------------| | <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | The ARN of the Lambda function. Use this for IAM policies, event source mappings, and cross-account access. | | <a name="output_function_name"></a> [function\_name](#output\_function\_name) | The name of the Lambda function. Use this for AWS CLI commands and SDK calls. | | <a name="output_function_qualified_arn"></a> [function\_qualified\_arn](#output\_function\_qualified\_arn) | The ARN of the Lambda function with version qualifier. Use this to reference a specific version of the function. | | <a name="output_handler"></a> [handler](#output\_handler) | The function entrypoint handler. | | <a name="output_invoke_arn"></a> [invoke\_arn](#output\_invoke\_arn) | The ARN to use when invoking the function from API Gateway, EventBridge, or other AWS services. | | <a name="output_last_modified"></a> [last\_modified](#output\_last\_modified) | The date the Lambda function was last modified. | | <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | The ARN of the CloudWatch log group. Use this for IAM policies or cross-account log access. | | <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | The name of the CloudWatch log group for Lambda function logs. Use this to set up log subscriptions or metric filters. | | <a name="output_memory_size"></a> [memory\_size](#output\_memory\_size) | The amount of memory allocated to the Lambda function in MB. | | <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | The ARN of the Lambda execution IAM role. Use this for trust relationships and policy attachments. | | <a name="output_role_id"></a> [role\_id](#output\_role\_id) | The unique ID of the IAM role. Use this for programmatic role identification. | | <a name="output_role_name"></a> [role\_name](#output\_role\_name) | The name of the Lambda execution IAM role. Use this for attaching additional policies. | | <a name="output_runtime"></a> [runtime](#output\_runtime) | The runtime environment of the Lambda function (e.g., python3.12, nodejs20.x). | | <a name="output_timeout"></a> [timeout](#output\_timeout) | The maximum execution time of the Lambda function in seconds. | | <a name="output_version"></a> [version](#output\_version) | The version of the Lambda function. Increments with each publish operation. | <!-- END_TF_DOCS -->

## Features

- ✅ Multi-Runtime Support Python, Node.js (TypeScript), and Go
- ✅ Flexible Deployment S3 or local zip file deployment
- ✅ Security Best Practices Least privilege IAM roles and policies
- ✅ CloudWatch Integration Automatic log group creation with retention policies
- ✅ Environment Variables Encrypted at rest with AWS managed keys
- ✅ Custom Permissions Easy attachment of additional IAM policies
- ✅ Concurrency Control Configurable reserved concurrent executions
- ✅ Comprehensive Outputs All necessary ARNs and identifiers for integration

## Quick Start

```hcl
module "lambda" {
  source = "github.com/llamandcoco/infra-modules//terraform/lambda?ref=<commit-sha>"

  # Add required variables here
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|----------|
| Basic | [`tests/basic/`](tests/basic/) |
| Go | [`tests/go/`](tests/go/) |
| Python | [`tests/python/`](tests/python/) |
| Typescript | [`tests/typescript/`](tests/typescript/) |

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
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_policy_arns"></a> [additional\_policy\_arns](#input\_additional\_policy\_arns) | List of IAM policy ARNs to attach to the Lambda execution role. Use for granting additional permissions (e.g., DynamoDB, S3, SQS access). | `list(string)` | `[]` | no |
| <a name="input_create_cloudwatch_log_policy"></a> [create\_cloudwatch\_log\_policy](#input\_create\_cloudwatch\_log\_policy) | Whether to create and attach an IAM policy for CloudWatch Logs. Recommended for production to enable logging. | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the Lambda function. Helps document the purpose and functionality. | `string` | `null` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Map of environment variables to pass to the Lambda function. These are encrypted at rest using AWS managed keys by default. | `map(string)` | `{}` | no |
| <a name="input_filename"></a> [filename](#input\_filename) | Path to the local Lambda deployment package zip file. Use for development and testing. Required if using local deployment method. | `string` | `null` | no |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Name of the Lambda function. This will be displayed in the AWS console and used in resource naming. | `string` | n/a | yes |
| <a name="input_handler"></a> [handler](#input\_handler) | Function entrypoint in your code. Format varies by runtime: Python: 'module.function\_name' (e.g., 'lambda\_function.handler'), Node.js: 'file.function\_name' (e.g., 'index.handler' or 'dist/index.handler'), Go: 'bootstrap' (the binary name). | `string` | n/a | yes |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Number of days to retain CloudWatch logs. Common values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653. | `number` | `7` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Amount of memory in MB available to the Lambda function at runtime. CPU allocation scales with memory. | `number` | `128` | no |
| <a name="input_reserved_concurrent_executions"></a> [reserved\_concurrent\_executions](#input\_reserved\_concurrent\_executions) | Number of concurrent executions reserved for this function. Set to -1 for unreserved (default). Use positive values to guarantee capacity. | `number` | `-1` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Runtime environment for the Lambda function. Supported runtimes: python3.11, python3.12, nodejs18.x, nodejs20.x, provided.al2023, provided.al2. | `string` | n/a | yes |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | S3 bucket containing the Lambda deployment package. Use for production deployments via CI/CD. Required if using S3 deployment method. | `string` | `null` | no |
| <a name="input_s3_key"></a> [s3\_key](#input\_s3\_key) | S3 object key of the Lambda deployment package. Required if using S3 deployment method. | `string` | `null` | no |
| <a name="input_s3_object_version"></a> [s3\_object\_version](#input\_s3\_object\_version) | Version of the S3 object. Optional. Use for S3 versioned buckets to ensure specific package version deployment. | `string` | `null` | no |
| <a name="input_source_code_hash"></a> [source\_code\_hash](#input\_source\_code\_hash) | Base64-encoded SHA256 hash of the deployment package. Used to trigger redeployment when code changes. Optional but recommended for local deployment. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. Use this for cost allocation, resource organization, and governance. | `map(string)` | `{}` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Maximum execution time in seconds. Lambda functions are terminated if they run longer than this value. | `number` | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | The ARN of the Lambda function. Use this for IAM policies, event source mappings, and cross-account access. |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | The name of the Lambda function. Use this for AWS CLI commands and SDK calls. |
| <a name="output_function_qualified_arn"></a> [function\_qualified\_arn](#output\_function\_qualified\_arn) | The ARN of the Lambda function with version qualifier. Use this to reference a specific version of the function. |
| <a name="output_handler"></a> [handler](#output\_handler) | The function entrypoint handler. |
| <a name="output_invoke_arn"></a> [invoke\_arn](#output\_invoke\_arn) | The ARN to use when invoking the function from API Gateway, EventBridge, or other AWS services. |
| <a name="output_last_modified"></a> [last\_modified](#output\_last\_modified) | The date the Lambda function was last modified. |
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | The ARN of the CloudWatch log group. Use this for IAM policies or cross-account log access. |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | The name of the CloudWatch log group for Lambda function logs. Use this to set up log subscriptions or metric filters. |
| <a name="output_memory_size"></a> [memory\_size](#output\_memory\_size) | The amount of memory allocated to the Lambda function in MB. |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | The ARN of the Lambda execution IAM role. Use this for trust relationships and policy attachments. |
| <a name="output_role_id"></a> [role\_id](#output\_role\_id) | The unique ID of the IAM role. Use this for programmatic role identification. |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | The name of the Lambda execution IAM role. Use this for attaching additional policies. |
| <a name="output_runtime"></a> [runtime](#output\_runtime) | The runtime environment of the Lambda function (e.g., python3.12, nodejs20.x). |
| <a name="output_timeout"></a> [timeout](#output\_timeout) | The maximum execution time of the Lambda function in seconds. |
| <a name="output_version"></a> [version](#output\_version) | The version of the Lambda function. Increments with each publish operation. |
<!-- END_TF_DOCS -->
