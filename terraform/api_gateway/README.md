# API Gateway Module

## Features

- REST API Full REST API configuration with multiple endpoint types (EDGE, REGIONAL, PRIVATE)
- Resource Management Dynamic resource creation with hierarchical path support
- Multiple Integration Types Lambda proxy, HTTP, Mock, and AWS service integrations
- Security Resource policies, API keys, usage plans, Lambda/Cognito authorizers
- CORS Support Built-in CORS configuration for browser-based applications
- Request Validation Request validators and JSON Schema models for input validation
- Logging & Monitoring CloudWatch logs, X-Ray tracing, and CloudWatch metrics
- Caching Optional API Gateway caching with encryption support

## Quick Start

```hcl
module "api_gateway" {
  source = "github.com/llamandcoco/infra-modules//terraform/api_gateway?ref=<commit-sha>"

  # Add required variables here
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|----------|
| Basic | [`tests/basic/main.tf`](tests/basic/main.tf) |

**Usage:**
```bash
# View example
cat tests/basic/

# Copy and adapt
cp -r tests/basic/ my-project/
```

## Testing

## Features

- REST API Full REST API configuration with multiple endpoint types (EDGE, REGIONAL, PRIVATE)
- Resource Management Dynamic resource creation with hierarchical path support
- Multiple Integration Types Lambda proxy, HTTP, Mock, and AWS service integrations
- Security Resource policies, API keys, usage plans, Lambda/Cognito authorizers
- CORS Support Built-in CORS configuration for browser-based applications
- Request Validation Request validators and JSON Schema models for input validation
- Logging & Monitoring CloudWatch logs, X-Ray tracing, and CloudWatch metrics
- Caching Optional API Gateway caching with encryption support

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
| [aws_api_gateway_api_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_api_key) | resource |
| [aws_api_gateway_authorizer.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_authorizer) | resource |
| [aws_api_gateway_deployment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_integration.cors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration_response.cors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_integration_response.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_method.cors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method_response.cors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_method_response.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_method_settings.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_settings) | resource |
| [aws_api_gateway_model.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_model) | resource |
| [aws_api_gateway_request_validator.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_request_validator) | resource |
| [aws_api_gateway_resource.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_rest_api.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_rest_api_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api_policy) | resource |
| [aws_api_gateway_stage.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_api_gateway_usage_plan.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_usage_plan) | resource |
| [aws_api_gateway_usage_plan_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_usage_plan_key) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_log_format"></a> [access\_log\_format](#input\_access\_log\_format) | Format for access logs. Use AWS variables like $context.requestId, $context.error.message. Set to null to disable access logging even when logging\_level is not OFF. | `string` | `"$context.requestId $context.error.message $context.error.messageString"` | no |
| <a name="input_api_description"></a> [api\_description](#input\_api\_description) | Description of the API Gateway REST API. Helps document the purpose and functionality of the API. | `string` | `null` | no |
| <a name="input_api_keys"></a> [api\_keys](#input\_api\_keys) | Map of API keys for authentication. Use with usage plans to control access and enforce rate limits.<br/><br/>Example:<br/>{<br/>  partner\_key = {<br/>    name        = "partner-api-key"<br/>    description = "API key for partner integration"<br/>    enabled     = true<br/>    value       = null  # Auto-generated if null<br/>  }<br/>} | <pre>map(object({<br/>    name        = string<br/>    description = optional(string)<br/>    enabled     = optional(bool, true)<br/>    value       = optional(string) # Auto-generated if null<br/>  }))</pre> | `{}` | no |
| <a name="input_api_name"></a> [api\_name](#input\_api\_name) | Name of the API Gateway REST API. This will be displayed in the AWS console and used in resource naming. | `string` | n/a | yes |
| <a name="input_authorizers"></a> [authorizers](#input\_authorizers) | Map of API Gateway authorizers for authentication and authorization.<br/>Supports Lambda authorizers (TOKEN or REQUEST) and Cognito User Pool authorizers.<br/><br/>Example for Lambda authorizer:<br/>{<br/>  lambda\_auth = {<br/>    name           = "LambdaAuthorizer"<br/>    type           = "TOKEN"<br/>    authorizer\_uri = "arn:aws:apigateway:region:lambda:path/2015-03-31/functions/arn:aws:lambda:region:account:function:authorizer/invocations"<br/>    identity\_source = "method.request.header.Authorization"<br/>  }<br/>}<br/><br/>Example for Cognito authorizer:<br/>{<br/>  cognito\_auth = {<br/>    name          = "CognitoAuthorizer"<br/>    type          = "COGNITO\_USER\_POOLS"<br/>    provider\_arns = ["arn:aws:cognito-idp:region:account:userpool/pool-id"]<br/>    identity\_source = "method.request.header.Authorization"<br/>  }<br/>} | <pre>map(object({<br/>    name                             = string<br/>    type                             = string # TOKEN, REQUEST, COGNITO_USER_POOLS<br/>    authorizer_uri                   = optional(string)<br/>    authorizer_credentials           = optional(string)<br/>    authorizer_result_ttl_in_seconds = optional(number, 300)<br/>    identity_source                  = optional(string)<br/>    identity_validation_expression   = optional(string)<br/>    provider_arns                    = optional(list(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_binary_media_types"></a> [binary\_media\_types](#input\_binary\_media\_types) | List of binary media types supported by the REST API (e.g., ['image/png', 'application/octet-stream']). Required for handling binary content. | `list(string)` | `[]` | no |
| <a name="input_cache_cluster_enabled"></a> [cache\_cluster\_enabled](#input\_cache\_cluster\_enabled) | Enable API Gateway caching to improve performance and reduce backend load. Caching incurs additional costs. | `bool` | `false` | no |
| <a name="input_cache_cluster_size"></a> [cache\_cluster\_size](#input\_cache\_cluster\_size) | Size of the cache cluster. Valid values: 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118, 237. Size is in GB. | `string` | `"0.5"` | no |
| <a name="input_cache_data_encrypted"></a> [cache\_data\_encrypted](#input\_cache\_data\_encrypted) | Encrypt cache data. Recommended for sensitive data. Only applies if caching is enabled. | `bool` | `false` | no |
| <a name="input_cache_ttl_in_seconds"></a> [cache\_ttl\_in\_seconds](#input\_cache\_ttl\_in\_seconds) | Time to live (TTL) for cached responses in seconds. Must be between 0 and 3600. | `number` | `300` | no |
| <a name="input_caching_enabled"></a> [caching\_enabled](#input\_caching\_enabled) | Enable caching for API methods. Only applies if cache\_cluster\_enabled is true. | `bool` | `false` | no |
| <a name="input_cors_configuration"></a> [cors\_configuration](#input\_cors\_configuration) | CORS configuration for specific resources. Only used if enable\_cors is true.<br/>Each entry creates an OPTIONS method with appropriate CORS headers.<br/><br/>Example:<br/>{<br/>  users\_cors = {<br/>    resource\_key   = "users"<br/>    allow\_origin   = "*"<br/>    allow\_methods  = "GET,POST,OPTIONS"<br/>    allow\_headers  = "Content-Type,X-Amz-Date,Authorization,X-Api-Key"<br/>  }<br/>} | <pre>map(object({<br/>    resource_key  = optional(string) # null for root resource<br/>    allow_origin  = string<br/>    allow_methods = string<br/>    allow_headers = string<br/>  }))</pre> | `{}` | no |
| <a name="input_data_trace_enabled"></a> [data\_trace\_enabled](#input\_data\_trace\_enabled) | Enable logging of full request/response data. WARNING: May expose sensitive data in logs. Only enable for debugging. | `bool` | `false` | no |
| <a name="input_deployment_description"></a> [deployment\_description](#input\_deployment\_description) | Description for the API Gateway deployment. Use this to track what changes are included in each deployment. | `string` | `"Managed by Terraform"` | no |
| <a name="input_enable_cors"></a> [enable\_cors](#input\_enable\_cors) | Enable CORS (Cross-Origin Resource Sharing) support by creating OPTIONS methods. Required for browser-based applications. | `bool` | `false` | no |
| <a name="input_endpoint_types"></a> [endpoint\_types](#input\_endpoint\_types) | List of endpoint types. Valid values: EDGE (default), REGIONAL, or PRIVATE. EDGE uses CloudFront for global distribution. | `list(string)` | <pre>[<br/>  "EDGE"<br/>]</pre> | no |
| <a name="input_log_kms_key_id"></a> [log\_kms\_key\_id](#input\_log\_kms\_key\_id) | ARN of the KMS key to use for CloudWatch log encryption. If not specified, logs are encrypted with AWS managed keys. | `string` | `null` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Number of days to retain CloudWatch logs. Common values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653. | `number` | `7` | no |
| <a name="input_logging_level"></a> [logging\_level](#input\_logging\_level) | CloudWatch logging level for API Gateway execution logs. OFF disables logging. INFO logs all requests. ERROR logs only errors. | `string` | `"OFF"` | no |
| <a name="input_method_settings_path"></a> [method\_settings\_path](#input\_method\_settings\_path) | Path for method settings (e.g., '*/*' for all methods, 'users/GET' for specific method). Use '*/*' to apply settings to all methods. | `string` | `"*/*"` | no |
| <a name="input_methods"></a> [methods](#input\_methods) | Map of API Gateway methods and their integrations. Defines HTTP methods (GET, POST, etc.) and backend integrations.<br/><br/>Example for Lambda proxy integration:<br/>{<br/>  get\_health = {<br/>    resource\_key       = null  # null for root resource<br/>    http\_method        = "GET"<br/>    authorization      = "NONE"<br/>    integration\_type   = "AWS\_PROXY"<br/>    integration\_http\_method = "POST"<br/>    integration\_uri    = "arn:aws:apigateway:region:lambda:path/2015-03-31/functions/arn:aws:lambda:region:account:function:name/invocations"<br/>  }<br/>}<br/><br/>Integration types:<br/>- AWS\_PROXY: Lambda proxy integration (recommended for Lambda)<br/>- AWS: AWS service integration with mapping templates<br/>- HTTP: HTTP proxy integration<br/>- HTTP\_PROXY: HTTP proxy integration<br/>- MOCK: Returns a response without calling backend | <pre>map(object({<br/>    resource_key         = optional(string) # Key from var.resources, null for root<br/>    http_method          = string<br/>    authorization        = string # NONE, AWS_IAM, CUSTOM, COGNITO_USER_POOLS<br/>    authorizer_id        = optional(string)<br/>    authorization_scopes = optional(list(string))<br/>    api_key_required     = optional(bool, false)<br/>    request_parameters   = optional(map(bool), {})<br/>    request_validator_id = optional(string)<br/>    request_models       = optional(map(string), {})<br/>    operation_name       = optional(string)<br/><br/>    # Integration configuration<br/>    integration_type               = string           # AWS_PROXY, AWS, HTTP, HTTP_PROXY, MOCK<br/>    integration_http_method        = optional(string) # POST for Lambda, same as http_method for HTTP<br/>    integration_uri                = optional(string)<br/>    integration_credentials        = optional(string)<br/>    connection_type                = optional(string, "INTERNET") # INTERNET or VPC_LINK<br/>    connection_id                  = optional(string)<br/>    request_templates              = optional(map(string), {})<br/>    integration_request_parameters = optional(map(string), {})<br/>    passthrough_behavior           = optional(string) # WHEN_NO_MATCH, WHEN_NO_TEMPLATES, NEVER<br/>    cache_key_parameters           = optional(list(string), [])<br/>    cache_namespace                = optional(string)<br/>    content_handling               = optional(string) # CONVERT_TO_BINARY or CONVERT_TO_TEXT<br/>    timeout_milliseconds           = optional(number, 29000)<br/><br/>    # Method responses<br/>    method_responses = optional(list(object({<br/>      status_code         = string<br/>      response_parameters = optional(map(bool), {})<br/>      response_models     = optional(map(string), {})<br/>      })), [{<br/>      status_code         = "200"<br/>      response_parameters = {}<br/>      response_models     = {}<br/>    }])<br/><br/>    # Integration responses<br/>    integration_responses = optional(list(object({<br/>      status_code         = string<br/>      selection_pattern   = optional(string)<br/>      response_parameters = optional(map(string), {})<br/>      response_templates  = optional(map(string), {})<br/>      content_handling    = optional(string)<br/>      })), [{<br/>      status_code = "200"<br/>    }])<br/>  }))</pre> | `{}` | no |
| <a name="input_metrics_enabled"></a> [metrics\_enabled](#input\_metrics\_enabled) | Enable CloudWatch metrics for the API. Provides detailed metrics on request count, latency, errors, etc. | `bool` | `false` | no |
| <a name="input_models"></a> [models](#input\_models) | Map of request/response models defining data structures. Used for request validation and documentation.<br/>Schema should be in JSON Schema format.<br/><br/>Example:<br/>{<br/>  user\_model = {<br/>    name         = "User"<br/>    description  = "User object model"<br/>    content\_type = "application/json"<br/>    schema       = jsonencode({<br/>      type = "object"<br/>      required = ["name", "email"]<br/>      properties = {<br/>        name  = { type = "string" }<br/>        email = { type = "string" }<br/>      }<br/>    })<br/>  }<br/>} | <pre>map(object({<br/>    name         = string<br/>    description  = optional(string)<br/>    content_type = string<br/>    schema       = string<br/>  }))</pre> | `{}` | no |
| <a name="input_request_validators"></a> [request\_validators](#input\_request\_validators) | Map of request validators to validate request parameters and body before processing.<br/>Improves security and reduces invalid requests reaching your backend.<br/><br/>Example:<br/>{<br/>  body\_validator = {<br/>    name                        = "Validate body"<br/>    validate\_request\_body       = true<br/>    validate\_request\_parameters = false<br/>  }<br/>} | <pre>map(object({<br/>    name                        = string<br/>    validate_request_body       = bool<br/>    validate_request_parameters = bool<br/>  }))</pre> | `{}` | no |
| <a name="input_require_authorization_for_cache_control"></a> [require\_authorization\_for\_cache\_control](#input\_require\_authorization\_for\_cache\_control) | Require authorization to control cache (e.g., Cache-Control header). Improves security by preventing unauthorized cache manipulation. | `bool` | `true` | no |
| <a name="input_resource_policy"></a> [resource\_policy](#input\_resource\_policy) | JSON-formatted resource policy to attach to the API. Use this to control access via IP allowlist, VPC endpoints, or AWS account restrictions. Set to null to allow public access. | `string` | `null` | no |
| <a name="input_resources"></a> [resources](#input\_resources) | Map of API Gateway resources (path parts). Each resource represents a path segment in your API.<br/>Example:<br/>{<br/>  users = {<br/>    path\_part = "users"<br/>    parent\_id = null  # Uses root resource<br/>  }<br/>  user\_id = {<br/>    path\_part = "{id}"<br/>    parent\_id = aws\_api\_gateway\_resource.this["users"].id<br/>  }<br/>} | <pre>map(object({<br/>    path_part = string<br/>    parent_id = optional(string) # If null, uses root resource<br/>  }))</pre> | `{}` | no |
| <a name="input_stage_description"></a> [stage\_description](#input\_stage\_description) | Description of the API Gateway stage. Documents the purpose and environment of this stage. | `string` | `null` | no |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | Name of the API Gateway stage (e.g., 'dev', 'staging', 'prod'). This is used in the invocation URL. | `string` | n/a | yes |
| <a name="input_stage_variables"></a> [stage\_variables](#input\_stage\_variables) | Map of stage variables. Use these to parameterize your API configuration per stage (e.g., Lambda aliases, backend URLs). | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. Use this for cost allocation, resource organization, and governance. | `map(string)` | `{}` | no |
| <a name="input_throttling_burst_limit"></a> [throttling\_burst\_limit](#input\_throttling\_burst\_limit) | API Gateway burst limit (maximum concurrent requests). Set to -1 to use account-level settings. | `number` | `-1` | no |
| <a name="input_throttling_rate_limit"></a> [throttling\_rate\_limit](#input\_throttling\_rate\_limit) | API Gateway rate limit (requests per second). Set to -1 to use account-level settings. | `number` | `-1` | no |
| <a name="input_unauthorized_cache_control_header_strategy"></a> [unauthorized\_cache\_control\_header\_strategy](#input\_unauthorized\_cache\_control\_header\_strategy) | Strategy for handling unauthorized cache control headers. FAIL\_WITH\_403 returns 403, SUCCEED\_WITH\_RESPONSE\_HEADER honors the header, SUCCEED\_WITHOUT\_RESPONSE\_HEADER ignores it. | `string` | `"SUCCEED_WITH_RESPONSE_HEADER"` | no |
| <a name="input_usage_plan_keys"></a> [usage\_plan\_keys](#input\_usage\_plan\_keys) | Map associating API keys with usage plans. Links keys to plans to enforce throttling and quotas.<br/><br/>Example:<br/>{<br/>  partner\_basic = {<br/>    api\_key\_name    = "partner\_key"<br/>    usage\_plan\_name = "basic\_plan"<br/>  }<br/>} | <pre>map(object({<br/>    api_key_name    = string<br/>    usage_plan_name = string<br/>  }))</pre> | `{}` | no |
| <a name="input_usage_plans"></a> [usage\_plans](#input\_usage\_plans) | Map of usage plans to configure throttling and quota limits for API consumers.<br/>Controls how many requests clients can make and at what rate.<br/><br/>Example:<br/>{<br/>  basic\_plan = {<br/>    name        = "Basic Plan"<br/>    description = "Basic usage plan with rate limiting"<br/>    api\_stages = [{<br/>      path        = "*/*"<br/>      burst\_limit = 10<br/>      rate\_limit  = 5<br/>    }]<br/>    quota\_limit    = 1000<br/>    quota\_period   = "DAY"<br/>    throttle\_burst\_limit = 20<br/>    throttle\_rate\_limit  = 10<br/>  }<br/>} | <pre>map(object({<br/>    name        = string<br/>    description = optional(string)<br/>    api_stages = list(object({<br/>      path        = string<br/>      burst_limit = optional(number)<br/>      rate_limit  = optional(number)<br/>    }))<br/>    quota_limit          = optional(number)<br/>    quota_offset         = optional(number, 0)<br/>    quota_period         = optional(string) # DAY, WEEK, MONTH<br/>    throttle_burst_limit = optional(number)<br/>    throttle_rate_limit  = optional(number)<br/>  }))</pre> | `{}` | no |
| <a name="input_xray_tracing_enabled"></a> [xray\_tracing\_enabled](#input\_xray\_tracing\_enabled) | Enable AWS X-Ray tracing for detailed request tracking and analysis. Useful for debugging and performance optimization. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_arn"></a> [api\_arn](#output\_api\_arn) | The ARN of the REST API. Use this for IAM policies and cross-account access configurations. |
| <a name="output_api_id"></a> [api\_id](#output\_api\_id) | The ID of the REST API. Use this for API Gateway resource references and integrations. |
| <a name="output_api_key_ids"></a> [api\_key\_ids](#output\_api\_key\_ids) | Map of API key names to their IDs. Use these for usage plan associations. |
| <a name="output_api_key_values"></a> [api\_key\_values](#output\_api\_key\_values) | Map of API key names to their values. SENSITIVE: Handle with care. Use these for client distribution. |
| <a name="output_api_name"></a> [api\_name](#output\_api\_name) | The name of the REST API. |
| <a name="output_authorizer_ids"></a> [authorizer\_ids](#output\_authorizer\_ids) | Map of authorizer names to their IDs. Use these when configuring methods that require authorization. |
| <a name="output_cache_cluster_enabled"></a> [cache\_cluster\_enabled](#output\_cache\_cluster\_enabled) | Whether caching is enabled for the API stage. Important for understanding performance characteristics. |
| <a name="output_deployment_id"></a> [deployment\_id](#output\_deployment\_id) | The ID of the API Gateway deployment. Changes when the API configuration is updated. |
| <a name="output_endpoint_types"></a> [endpoint\_types](#output\_endpoint\_types) | The endpoint configuration types for the API (EDGE, REGIONAL, or PRIVATE). |
| <a name="output_execution_arn"></a> [execution\_arn](#output\_execution\_arn) | The execution ARN to be used in Lambda permissions. Format: arn:aws:execute-api:region:account-id:api-id |
| <a name="output_invoke_url"></a> [invoke\_url](#output\_invoke\_url) | The base URL to invoke the API. Format: https://{api-id}.execute-api.{region}.amazonaws.com/{stage-name} |
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | The ARN of the CloudWatch log group. Use this for IAM policies or cross-account log access. |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | The name of the CloudWatch log group for API Gateway logs. Use this to set up log subscriptions or metric filters. |
| <a name="output_metrics_enabled"></a> [metrics\_enabled](#output\_metrics\_enabled) | Whether CloudWatch metrics are enabled. Indicates if detailed metrics are available for monitoring. |
| <a name="output_model_names"></a> [model\_names](#output\_model\_names) | Map of model keys to their names. Lists all request/response models defined for the API. |
| <a name="output_request_validator_ids"></a> [request\_validator\_ids](#output\_request\_validator\_ids) | Map of validator names to their IDs. Use these when configuring method request validation. |
| <a name="output_resource_ids"></a> [resource\_ids](#output\_resource\_ids) | Map of resource keys to their IDs. Use these when creating methods or child resources programmatically. |
| <a name="output_resource_paths"></a> [resource\_paths](#output\_resource\_paths) | Map of resource keys to their full paths. Shows the complete path hierarchy for each resource. |
| <a name="output_root_resource_id"></a> [root\_resource\_id](#output\_root\_resource\_id) | The resource ID of the REST API's root path (/). Use this as parent\_id when creating additional resources. |
| <a name="output_stage_arn"></a> [stage\_arn](#output\_stage\_arn) | The ARN of the API Gateway stage. Use this for CloudWatch alarms and monitoring. |
| <a name="output_stage_name"></a> [stage\_name](#output\_stage\_name) | The name of the deployed stage (e.g., 'dev', 'staging', 'prod'). |
| <a name="output_tags"></a> [tags](#output\_tags) | All tags applied to the API and related resources, including defaults and custom tags. |
| <a name="output_usage_plan_ids"></a> [usage\_plan\_ids](#output\_usage\_plan\_ids) | Map of usage plan names to their IDs. Use these for associating API keys or monitoring usage. |
| <a name="output_xray_tracing_enabled"></a> [xray\_tracing\_enabled](#output\_xray\_tracing\_enabled) | Whether X-Ray tracing is enabled. Indicates if detailed request tracing is available. |
<!-- END_TF_DOCS -->
</details>
