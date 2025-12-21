# AWS Bedrock

Production-ready Terraform module for configuring AWS Bedrock foundation models with IAM roles and model invocation logging.

## Features

- Service Role Creation IAM roles for Lambda, ECS, EC2 to invoke Bedrock models
- Model Invocation Logging CloudWatch and S3 logging for auditing and debugging
- Flexible Model Access Granular control over which foundation models can be accessed
- Comprehensive Outputs Model ARNs, role ARNs, and logging configuration details
- Multi-Service Support Configure access for Lambda, ECS, EC2, and other AWS services
- Optional Logging Enable or disable logging based on environment needs
- Common Model ARNs Pre-configured ARNs for Claude, Llama, and other models
- IAM Best Practices Automatic role creation with least-privilege permissions

## Quick Start

```hcl
module "bedrock" {
  source = "github.com/llamandcoco/infra-modules//terraform/bedrock?ref=<commit-sha>"

  create_service_role = true
  service_role_name   = "my-bedrock-lambda-role"
  service_principals  = ["lambda.amazonaws.com"]
  allowed_model_arns  = ["arn:aws:bedrock:*::foundation-model/*"]
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|----------|
| Basic | [`tests/basic/main.tf`](tests/basic/main.tf) |
| Advanced | [`tests/advanced/main.tf`](tests/advanced/main.tf) |

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
<!-- END_TF_DOCS -->
</details>
