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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
