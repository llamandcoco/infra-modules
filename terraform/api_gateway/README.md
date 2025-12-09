# API Gateway Module

Production-ready Terraform module for creating and managing AWS API Gateway REST APIs with comprehensive features including Lambda integration, CORS support, API keys, usage plans, logging, and more.

## Features

- **REST API**: Full REST API configuration with multiple endpoint types (EDGE, REGIONAL, PRIVATE)
- **Resource Management**: Dynamic resource creation with hierarchical path support
- **Multiple Integration Types**: Lambda proxy, HTTP, Mock, and AWS service integrations
- **Security**: Resource policies, API keys, usage plans, Lambda/Cognito authorizers
- **CORS Support**: Built-in CORS configuration for browser-based applications
- **Request Validation**: Request validators and JSON Schema models for input validation
- **Logging & Monitoring**: CloudWatch logs, X-Ray tracing, and CloudWatch metrics
- **Caching**: Optional API Gateway caching with encryption support
- **Throttling**: Configurable rate limiting at method and usage plan levels
- **Flexible Responses**: Custom method and integration response configurations

## Usage

### Basic Example - Health Check Endpoint

```hcl
module "api_gateway" {
  source = "github.com/llamandcoco/infra-modules//terraform/api_gateway?ref=v1.0.0"

  api_name   = "my-api"
  stage_name = "prod"

  methods = {
    get_health = {
      resource_key            = null  # Root resource
      http_method             = "GET"
      authorization           = "NONE"
      integration_type        = "MOCK"
      request_templates = {
        "application/json" = "{\"statusCode\": 200}"
      }
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### Lambda Proxy Integration

```hcl
module "api_gateway" {
  source = "github.com/llamandcoco/infra-modules//terraform/api_gateway?ref=v1.0.0"

  api_name        = "users-api"
  stage_name      = "prod"
  api_description = "Users API with Lambda integration"

  resources = {
    users = {
      path_part = "users"
      parent_id = null
    }
  }

  methods = {
    list_users = {
      resource_key            = "users"
      http_method             = "GET"
      authorization           = "NONE"
      integration_type        = "AWS_PROXY"
      integration_http_method = "POST"
      integration_uri         = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.list_users.arn}/invocations"
    }
    create_user = {
      resource_key            = "users"
      http_method             = "POST"
      authorization           = "NONE"
      api_key_required        = true
      integration_type        = "AWS_PROXY"
      integration_http_method = "POST"
      integration_uri         = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.create_user.arn}/invocations"
    }
  }

  tags = {
    Environment = "production"
  }
}

# Grant API Gateway permission to invoke Lambda
resource "aws_lambda_permission" "api_gateway" {
  for_each = {
    list   = aws_lambda_function.list_users.function_name
    create = aws_lambda_function.create_user.function_name
  }

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = each.value
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.execution_arn}/*"
}
```

### API with CORS and Logging

```hcl
module "api_gateway" {
  source = "github.com/llamandcoco/infra-modules//terraform/api_gateway?ref=v1.0.0"

  api_name        = "web-api"
  stage_name      = "prod"
  api_description = "Web API with CORS support"
  endpoint_types  = ["REGIONAL"]

  resources = {
    api = {
      path_part = "api"
      parent_id = null
    }
  }

  methods = {
    get_data = {
      resource_key            = "api"
      http_method             = "GET"
      authorization           = "NONE"
      integration_type        = "AWS_PROXY"
      integration_http_method = "POST"
      integration_uri         = aws_lambda_function.get_data.invoke_arn
    }
  }

  # Enable CORS
  enable_cors = true
  cors_configuration = {
    api_cors = {
      resource_key  = "api"
      allow_origin  = "https://example.com"
      allow_methods = "GET,POST,PUT,DELETE,OPTIONS"
      allow_headers = "Content-Type,X-Amz-Date,Authorization,X-Api-Key"
    }
  }

  # Enable logging and monitoring
  logging_level        = "INFO"
  access_log_format    = "$context.requestId $context.error.message $context.error.messageString"
  log_retention_days   = 30
  metrics_enabled      = true
  xray_tracing_enabled = true

  # Stage variables
  stage_variables = {
    lambda_alias = "prod"
  }

  tags = {
    Environment = "production"
  }
}
```

### API with Keys, Usage Plans, and Throttling

```hcl
module "api_gateway" {
  source = "github.com/llamandcoco/infra-modules//terraform/api_gateway?ref=v1.0.0"

  api_name   = "partner-api"
  stage_name = "prod"

  methods = {
    get_data = {
      resource_key     = null
      http_method      = "GET"
      authorization    = "NONE"
      api_key_required = true
      integration_type = "AWS_PROXY"
      integration_http_method = "POST"
      integration_uri  = aws_lambda_function.api.invoke_arn
    }
  }

  # Create API keys
  api_keys = {
    partner_a = {
      name        = "partner-a-key"
      description = "API key for Partner A"
      enabled     = true
    }
    partner_b = {
      name        = "partner-b-key"
      description = "API key for Partner B"
      enabled     = true
    }
  }

  # Create usage plans
  usage_plans = {
    basic = {
      name        = "Basic Plan"
      description = "Basic tier with standard limits"
      api_stages = [{
        path        = "*/*"
        burst_limit = 10
        rate_limit  = 5
      }]
      quota_limit          = 1000
      quota_period         = "DAY"
      throttle_burst_limit = 20
      throttle_rate_limit  = 10
    }
    premium = {
      name        = "Premium Plan"
      description = "Premium tier with higher limits"
      api_stages = [{
        path        = "*/*"
        burst_limit = 100
        rate_limit  = 50
      }]
      quota_limit          = 10000
      quota_period         = "DAY"
      throttle_burst_limit = 200
      throttle_rate_limit  = 100
    }
  }

  # Associate keys with plans
  usage_plan_keys = {
    partner_a_basic = {
      api_key_name    = "partner_a"
      usage_plan_name = "basic"
    }
    partner_b_premium = {
      api_key_name    = "partner_b"
      usage_plan_name = "premium"
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### API with Request Validation

```hcl
module "api_gateway" {
  source = "github.com/llamandcoco/infra-modules//terraform/api_gateway?ref=v1.0.0"

  api_name   = "validated-api"
  stage_name = "prod"

  resources = {
    users = {
      path_part = "users"
      parent_id = null
    }
  }

  # Define models
  models = {
    user_model = {
      name         = "UserModel"
      description  = "User object schema"
      content_type = "application/json"
      schema = jsonencode({
        type = "object"
        required = ["name", "email"]
        properties = {
          name = {
            type = "string"
            minLength = 1
          }
          email = {
            type = "string"
            pattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
          }
        }
      })
    }
  }

  # Create validators
  request_validators = {
    body_validator = {
      name                        = "Validate body"
      validate_request_body       = true
      validate_request_parameters = false
    }
  }

  methods = {
    create_user = {
      resource_key         = "users"
      http_method          = "POST"
      authorization        = "NONE"
      integration_type     = "AWS_PROXY"
      integration_http_method = "POST"
      integration_uri      = aws_lambda_function.create_user.invoke_arn
      request_models = {
        "application/json" = "UserModel"
      }
    }
  }

  tags = {
    Environment = "production"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Inputs

See [variables.tf](./variables.tf) for a comprehensive list of all input variables with descriptions and default values.

### Key Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| api_name | Name of the API Gateway REST API | `string` | n/a | yes |
| stage_name | Name of the API Gateway stage | `string` | n/a | yes |
| methods | Map of API Gateway methods and integrations | `map(object)` | `{}` | no |
| resources | Map of API Gateway resources (path parts) | `map(object)` | `{}` | no |
| enable_cors | Enable CORS support | `bool` | `false` | no |
| logging_level | CloudWatch logging level (OFF, ERROR, INFO) | `string` | `"OFF"` | no |
| api_keys | Map of API keys | `map(object)` | `{}` | no |
| usage_plans | Map of usage plans | `map(object)` | `{}` | no |

## Outputs

See [outputs.tf](./outputs.tf) for a comprehensive list of all outputs with descriptions.

### Key Outputs

| Name | Description |
|------|-------------|
| api_id | The ID of the REST API |
| invoke_url | The base URL to invoke the API |
| api_arn | The ARN of the REST API |
| execution_arn | The execution ARN for Lambda permissions |
| resource_ids | Map of resource keys to their IDs |
| log_group_name | The name of the CloudWatch log group |

## Security Considerations

- **Resource Policies**: Use `resource_policy` to restrict access by IP, VPC endpoint, or AWS account
- **API Keys**: Enable `api_key_required` for methods that need authentication
- **Logging**: Be cautious with `data_trace_enabled` as it logs full request/response data
- **CORS**: Set specific origins instead of `"*"` in production
- **Encryption**: Enable `cache_data_encrypted` when caching sensitive data
- **Throttling**: Configure appropriate rate limits to prevent abuse

## Testing

```bash
# Navigate to test directory
cd tests/basic

# Initialize Terraform
terraform init -backend=false

# Run plan
terraform plan

# The test includes multiple scenarios:
# - Basic API with health check
# - Lambda proxy integration
# - CORS and logging
# - API keys and usage plans
# - Request validation
# - Caching
# - Custom responses
```

## License

See [LICENSE](../../LICENSE) file for details.

## Module Development

This module follows the repository's standard structure and best practices. It serves as a reference implementation for other AWS resource modules.

### Key Design Decisions

1. **Separation of Concerns**: Each API Gateway component (resources, methods, integrations) is managed separately
2. **Flexibility**: Supports multiple integration types and optional features
3. **Security by Default**: Logging disabled by default, resource policies optional
4. **Comprehensive Variables**: All variables have types, descriptions, and validations
5. **Well-Documented Outputs**: Every output includes a description of its use case

### Running Tests Locally

```bash
# Format code
terraform fmt terraform/api_gateway/

# Validate module
cd terraform/api_gateway
terraform init -backend=false
terraform validate

# Run linting
tflint --init
tflint --chdir=terraform/api_gateway

# Run security scan
tfsec terraform/api_gateway/

# Test the module
cd tests/basic
terraform init -backend=false
terraform plan
```

## Contributing

Contributions are welcome! Please ensure:
- All variables have type declarations and descriptions
- All outputs have descriptions
- Code is formatted with `terraform fmt`
- Tests pass locally
- Security scans (tfsec) pass
- Documentation is updated

<!-- BEGIN_TF_DOCS -->
<!-- This section will be auto-generated by terraform-docs -->
<!-- END_TF_DOCS -->
