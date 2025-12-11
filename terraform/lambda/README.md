# AWS Lambda Terraform Module

Production-ready Terraform module for deploying AWS Lambda functions with comprehensive IAM, logging, and multi-runtime support.

## Features

- ✅ **Multi-Runtime Support**: Python, Node.js (TypeScript), and Go
- ✅ **Flexible Deployment**: S3 or local zip file deployment
- ✅ **Security Best Practices**: Least privilege IAM roles and policies
- ✅ **CloudWatch Integration**: Automatic log group creation with retention policies
- ✅ **Environment Variables**: Encrypted at rest with AWS managed keys
- ✅ **Custom Permissions**: Easy attachment of additional IAM policies
- ✅ **Concurrency Control**: Configurable reserved concurrent executions
- ✅ **Comprehensive Outputs**: All necessary ARNs and identifiers for integration

## Supported Runtimes

| Runtime | Version | Use Case |
|---------|---------|----------|
| `python3.11` | Python 3.11 | Data processing, APIs, automation |
| `python3.12` | Python 3.12 | Latest Python features, ML workloads |
| `nodejs18.x` | Node.js 18.x | APIs, serverless applications |
| `nodejs20.x` | Node.js 20.x | Latest Node.js features, TypeScript |
| `provided.al2023` | Amazon Linux 2023 | Go, Rust, custom runtimes |
| `provided.al2` | Amazon Linux 2 | Go (legacy), custom runtimes |

## Handler Naming Convention

Each runtime has specific handler naming requirements:

- **Python**: `module.function_name` (e.g., `lambda_function.handler`, `app.main`)
- **Node.js/TypeScript**: `file.function_name` (e.g., `index.handler`, `dist/index.handler`)
- **Go**: `bootstrap` (the compiled binary name)

## Usage

### Basic Python Lambda (Local Deployment)

```hcl
module "lambda" {
  source = "github.com/your-org/infra-modules//terraform/lambda"

  function_name = "my-python-function"
  runtime       = "python3.12"
  handler       = "lambda_function.handler"

  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  tags = {
    Environment = "dev"
  }
}
```

### Python Lambda with S3 Deployment

```hcl
module "lambda" {
  source = "github.com/your-org/infra-modules//terraform/lambda"

  function_name = "my-python-api"
  runtime       = "python3.12"
  handler       = "app.lambda_handler"

  # S3 deployment method
  s3_bucket         = "my-lambda-artifacts"
  s3_key            = "functions/my-api/v1.0.0/lambda.zip"
  s3_object_version = "abc123"

  # Configuration
  timeout     = 60
  memory_size = 512

  environment_variables = {
    ENVIRONMENT = "production"
    LOG_LEVEL   = "INFO"
    TABLE_NAME  = "my-dynamodb-table"
  }

  # Additional permissions
  additional_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
  ]

  tags = {
    Environment = "production"
    Application = "api"
  }
}
```

### TypeScript Lambda (Node.js 20.x)

```hcl
module "lambda_typescript" {
  source = "github.com/your-org/infra-modules//terraform/lambda"

  function_name = "typescript-api"
  runtime       = "nodejs20.x"
  handler       = "dist/index.handler"  # Compiled TypeScript in dist/

  s3_bucket = "my-lambda-artifacts"
  s3_key    = "functions/typescript-api/v2.0.0/lambda.zip"

  timeout     = 30
  memory_size = 512

  environment_variables = {
    NODE_ENV    = "production"
    API_VERSION = "v2"
  }

  additional_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
  ]
}
```

### Go Lambda (High Performance)

```hcl
module "lambda_go" {
  source = "github.com/your-org/infra-modules//terraform/lambda"

  function_name = "go-processor"
  runtime       = "provided.al2023"
  handler       = "bootstrap"  # Go binary name

  s3_bucket = "my-lambda-artifacts"
  s3_key    = "functions/go-processor/v1.0.0/lambda.zip"

  timeout     = 120
  memory_size = 1024

  environment_variables = {
    WORKER_COUNT = "10"
    BATCH_SIZE   = "100"
  }

  # High concurrency for stream processing
  reserved_concurrent_executions = 100

  additional_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonKinesisReadOnlyAccess"
  ]
}
```

### Lambda with Custom IAM Policies

```hcl
resource "aws_iam_policy" "custom" {
  name = "my-lambda-custom-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::my-bucket/*"
      }
    ]
  })
}

module "lambda" {
  source = "github.com/your-org/infra-modules//terraform/lambda"

  function_name = "custom-permissions-lambda"
  runtime       = "python3.12"
  handler       = "lambda_function.handler"
  filename      = "lambda.zip"

  additional_policy_arns = [
    aws_iam_policy.custom.arn
  ]
}
```

## Deployment Guide

### Python

#### Package Python Lambda with Dependencies

```bash
# Create package directory
mkdir package
cd package

# Install dependencies
pip install -r ../requirements.txt -t .

# Create zip with dependencies
zip -r ../lambda.zip .

# Add your code
cd ..
zip -g lambda.zip lambda_function.py

# Or add entire module
zip -r lambda.zip app/
```

#### Example requirements.txt

```text
boto3==1.34.0
requests==2.31.0
pydantic==2.5.0
```

### TypeScript (Node.js)

#### Setup TypeScript Project

```bash
# Initialize project
npm init -y
npm install --save-dev typescript @types/node @types/aws-lambda
npm install @aws-sdk/client-dynamodb

# Create tsconfig.json
cat > tsconfig.json <<EOF
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true
  },
  "include": ["src/**/*"]
}
EOF
```

#### Package TypeScript Lambda

```bash
# Compile TypeScript
npm run build  # or: npx tsc

# Package compiled code and dependencies
cd dist
zip -r ../lambda.zip .
cd ..

# Add node_modules
zip -r lambda.zip node_modules/

# Upload to S3
aws s3 cp lambda.zip s3://my-bucket/functions/my-app/v1.0.0/lambda.zip
```

#### Example package.json Scripts

```json
{
  "scripts": {
    "build": "tsc",
    "package": "npm run build && cd dist && zip -r ../lambda.zip . && cd .. && zip -r lambda.zip node_modules",
    "deploy": "npm run package && aws s3 cp lambda.zip s3://my-bucket/functions/my-app/lambda.zip"
  }
}
```

### Go

#### Build Go Lambda

```bash
# Build for Linux AMD64 (x86_64)
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o bootstrap main.go

# Or build for ARM64 (Graviton2)
GOOS=linux GOARCH=arm64 go build -o bootstrap main.go

# Package the binary
zip lambda.zip bootstrap

# Upload to S3
aws s3 cp lambda.zip s3://my-bucket/functions/go-app/v1.0.0/lambda.zip
```

#### Example Go Code

```go
package main

import (
    "context"
    "github.com/aws/aws-lambda-go/lambda"
)

type Event struct {
    Name string `json:"name"`
}

type Response struct {
    Message string `json:"message"`
}

func HandleRequest(ctx context.Context, event Event) (Response, error) {
    return Response{
        Message: "Hello " + event.Name,
    }, nil
}

func main() {
    lambda.Start(HandleRequest)
}
```

## Local Testing

### Using LocalStack

```bash
# Start LocalStack
docker run -d \
  --name localstack \
  -p 4566:4566 \
  localstack/localstack

# Deploy with local endpoint
terraform apply \
  -var="s3_bucket=test-bucket" \
  -var="s3_key=lambda.zip"
```

### Using AWS SAM CLI

```bash
# Create SAM template from Terraform outputs
# sam local invoke command

# Invoke function locally
sam local invoke MyFunction -e event.json

# Start local API
sam local start-api
```

### Using Lambda Test Events

Create `event.json`:

```json
{
  "body": "{\"name\":\"test\"}",
  "headers": {
    "Content-Type": "application/json"
  },
  "httpMethod": "POST",
  "path": "/api/test"
}
```

Test locally:

```bash
# Python
python -c "import lambda_function; print(lambda_function.handler(event, None))"

# Node.js
node -e "const handler = require('./index').handler; handler(event, {}, console.log)"
```

## Environment Variables

Environment variables are automatically encrypted at rest using AWS managed keys.

### Best Practices

1. **Use descriptive names**: `DATABASE_URL`, `API_KEY`, `LOG_LEVEL`
2. **Avoid sensitive data**: Use AWS Secrets Manager or Parameter Store for secrets
3. **Document all variables**: Maintain a README with variable descriptions
4. **Use uppercase**: Follow AWS Lambda convention (`MY_VAR`, not `my_var`)

### Example

```hcl
environment_variables = {
  ENVIRONMENT      = "production"
  LOG_LEVEL        = "INFO"
  API_ENDPOINT     = "https://api.example.com"
  CACHE_TTL        = "300"
  ENABLE_FEATURE_X = "true"
}
```

## Security Considerations

### IAM Least Privilege

The module creates a minimal IAM role by default:

- **Lambda assume role policy**: Allows Lambda service to assume the role
- **CloudWatch Logs**: Only if `create_cloudwatch_log_policy = true`
- **Custom permissions**: Only what you specify in `additional_policy_arns`

### Environment Variable Encryption

- Encrypted at rest with AWS managed keys (default)
- For custom KMS keys, this will be added in Phase 2

### Logging

- Logs are retained according to `log_retention_days` variable
- Default: 7 days (configurable)
- Logs may contain sensitive data - review before enabling debug logging

## Integration Examples

### API Gateway Integration

```hcl
module "lambda" {
  source = "github.com/your-org/infra-modules//terraform/lambda"

  function_name = "api-handler"
  runtime       = "python3.12"
  handler       = "app.handler"
  filename      = "lambda.zip"
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# Use module.lambda.invoke_arn in API Gateway integration
```

### EventBridge (CloudWatch Events) Integration

```hcl
module "lambda" {
  source = "github.com/your-org/infra-modules//terraform/lambda"

  function_name = "scheduled-task"
  runtime       = "python3.12"
  handler       = "handler.main"
  filename      = "lambda.zip"
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "lambda-schedule"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "lambda"
  arn       = module.lambda.function_arn
}

resource "aws_lambda_permission" "eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}
```

### SQS Integration

```hcl
module "lambda" {
  source = "github.com/your-org/infra-modules//terraform/lambda"

  function_name = "sqs-processor"
  runtime       = "python3.12"
  handler       = "processor.handler"
  filename      = "lambda.zip"

  additional_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
  ]
}

resource "aws_lambda_event_source_mapping" "sqs" {
  event_source_arn = aws_sqs_queue.queue.arn
  function_name    = module.lambda.function_name
  batch_size       = 10
}
```

## Outputs Reference

| Output | Description |
|--------|-------------|
| `function_arn` | ARN of the Lambda function |
| `function_name` | Name of the Lambda function |
| `function_qualified_arn` | ARN with version qualifier |
| `invoke_arn` | ARN for API Gateway/EventBridge integration |
| `version` | Current version of the function |
| `role_arn` | ARN of the IAM execution role |
| `role_name` | Name of the IAM execution role |
| `log_group_name` | CloudWatch log group name |
| `log_group_arn` | CloudWatch log group ARN |

## Validation Rules

The module includes built-in validation:

- **Function name**: 1-64 characters, alphanumeric, hyphens, underscores
- **Runtime**: Must be one of supported runtimes
- **Timeout**: 1-900 seconds
- **Memory**: 128-10240 MB
- **Log retention**: Must be valid AWS retention value
- **Deployment method**: Exactly one method (S3 or local) must be specified

## Phase 2 Features (Future)

The following features will be added in future phases:

- VPC configuration
- Lambda layers support
- Dead Letter Queue (DLQ)
- X-Ray tracing
- EFS mount points
- Container image support
- Custom KMS encryption for environment variables
- File system configuration

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Examples

See the [tests](./tests/) directory for complete examples:

- [Basic Test](./tests/basic/main.tf) - Minimal configuration with inline Python
- [Python Test](./tests/python/main.tf) - Python 3.12 with S3 deployment
- [TypeScript Test](./tests/typescript/main.tf) - Node.js 20.x with compiled TypeScript
- [Go Test](./tests/go/main.tf) - Go with provided.al2023 runtime

## Contributing

When contributing to this module:

1. Follow the existing code style
2. Add tests for new features
3. Update documentation
4. Run `terraform fmt` before committing
5. Ensure all validations pass

## License

See [LICENSE](../../LICENSE) file.

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
