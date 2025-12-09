terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# -----------------------------------------------------------------------------
# REST API
# Creates the API Gateway REST API resource
# -----------------------------------------------------------------------------
resource "aws_api_gateway_rest_api" "this" {
  name        = var.api_name
  description = var.api_description

  endpoint_configuration {
    types = var.endpoint_types
  }

  binary_media_types = var.binary_media_types

  tags = merge(
    var.tags,
    {
      Name = var.api_name
    }
  )
}

# -----------------------------------------------------------------------------
# REST API Policy
# Attaches a resource policy to control access to the API
# tfsec:ignore:aws-api-gateway-no-public-access - Public access is controlled via resource policy variable
# -----------------------------------------------------------------------------
resource "aws_api_gateway_rest_api_policy" "this" {
  count = var.resource_policy != null ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.this.id
  policy      = var.resource_policy
}

# -----------------------------------------------------------------------------
# API Gateway Resources
# Creates path resources in the API (e.g., /users, /products)
# -----------------------------------------------------------------------------
resource "aws_api_gateway_resource" "this" {
  for_each = var.resources

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = each.value.parent_id != null ? each.value.parent_id : aws_api_gateway_rest_api.this.root_resource_id
  path_part   = each.value.path_part
}

# -----------------------------------------------------------------------------
# API Gateway Methods
# Creates HTTP methods (GET, POST, etc.) for API resources
# -----------------------------------------------------------------------------
resource "aws_api_gateway_method" "this" {
  for_each = var.methods

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = each.value.resource_key != null ? aws_api_gateway_resource.this[each.value.resource_key].id : aws_api_gateway_rest_api.this.root_resource_id
  http_method   = each.value.http_method
  authorization = each.value.authorization

  authorizer_id        = each.value.authorizer_id
  authorization_scopes = each.value.authorization_scopes
  api_key_required     = each.value.api_key_required
  request_parameters   = each.value.request_parameters
  request_validator_id = each.value.request_validator_id
  request_models       = each.value.request_models
  operation_name       = each.value.operation_name
}

# -----------------------------------------------------------------------------
# API Gateway Integrations
# Configures backend integrations (Lambda, HTTP, Mock, etc.)
# -----------------------------------------------------------------------------
resource "aws_api_gateway_integration" "this" {
  for_each = var.methods

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = each.value.resource_key != null ? aws_api_gateway_resource.this[each.value.resource_key].id : aws_api_gateway_rest_api.this.root_resource_id
  http_method = aws_api_gateway_method.this[each.key].http_method

  type                    = each.value.integration_type
  integration_http_method = each.value.integration_http_method
  uri                     = each.value.integration_uri
  credentials             = each.value.integration_credentials
  connection_type         = each.value.connection_type
  connection_id           = each.value.connection_id
  request_templates       = each.value.request_templates
  request_parameters      = each.value.integration_request_parameters
  passthrough_behavior    = each.value.passthrough_behavior
  cache_key_parameters    = each.value.cache_key_parameters
  cache_namespace         = each.value.cache_namespace
  content_handling        = each.value.content_handling
  timeout_milliseconds    = each.value.timeout_milliseconds
}

# -----------------------------------------------------------------------------
# API Gateway Method Responses
# Defines the HTTP response types for methods
# -----------------------------------------------------------------------------
resource "aws_api_gateway_method_response" "this" {
  for_each = {
    for mr in local.method_responses : "${mr.method_key}_${mr.status_code}" => mr
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = var.methods[each.value.method_key].resource_key != null ? aws_api_gateway_resource.this[var.methods[each.value.method_key].resource_key].id : aws_api_gateway_rest_api.this.root_resource_id
  http_method = aws_api_gateway_method.this[each.value.method_key].http_method
  status_code = each.value.status_code

  response_parameters = each.value.response_parameters
  response_models     = each.value.response_models
}

# -----------------------------------------------------------------------------
# API Gateway Integration Responses
# Maps backend responses to method responses
# -----------------------------------------------------------------------------
resource "aws_api_gateway_integration_response" "this" {
  for_each = {
    for ir in local.integration_responses : "${ir.method_key}_${ir.status_code}" => ir
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = var.methods[each.value.method_key].resource_key != null ? aws_api_gateway_resource.this[var.methods[each.value.method_key].resource_key].id : aws_api_gateway_rest_api.this.root_resource_id
  http_method = aws_api_gateway_method.this[each.value.method_key].http_method
  status_code = aws_api_gateway_method_response.this["${each.value.method_key}_${each.value.status_code}"].status_code

  selection_pattern   = each.value.selection_pattern
  response_parameters = each.value.response_parameters
  response_templates  = each.value.response_templates
  content_handling    = each.value.content_handling

  depends_on = [
    aws_api_gateway_integration.this
  ]
}

# -----------------------------------------------------------------------------
# CORS Configuration (OPTIONS method)
# Enables CORS for specified resources
# -----------------------------------------------------------------------------
resource "aws_api_gateway_method" "cors" {
  for_each = var.enable_cors ? var.cors_configuration : {}

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = each.value.resource_key != null ? aws_api_gateway_resource.this[each.value.resource_key].id : aws_api_gateway_rest_api.this.root_resource_id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors" {
  for_each = var.enable_cors ? var.cors_configuration : {}

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = each.value.resource_key != null ? aws_api_gateway_resource.this[each.value.resource_key].id : aws_api_gateway_rest_api.this.root_resource_id
  http_method = aws_api_gateway_method.cors[each.key].http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "cors" {
  for_each = var.enable_cors ? var.cors_configuration : {}

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = each.value.resource_key != null ? aws_api_gateway_resource.this[each.value.resource_key].id : aws_api_gateway_rest_api.this.root_resource_id
  http_method = aws_api_gateway_method.cors[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "cors" {
  for_each = var.enable_cors ? var.cors_configuration : {}

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = each.value.resource_key != null ? aws_api_gateway_resource.this[each.value.resource_key].id : aws_api_gateway_rest_api.this.root_resource_id
  http_method = aws_api_gateway_method.cors[each.key].http_method
  status_code = aws_api_gateway_method_response.cors[each.key].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'${each.value.allow_headers}'"
    "method.response.header.Access-Control-Allow-Methods" = "'${each.value.allow_methods}'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${each.value.allow_origin}'"
  }

  depends_on = [
    aws_api_gateway_integration.cors
  ]
}

# -----------------------------------------------------------------------------
# Request Validators
# Validates request parameters and body before processing
# -----------------------------------------------------------------------------
resource "aws_api_gateway_request_validator" "this" {
  for_each = var.request_validators

  rest_api_id                 = aws_api_gateway_rest_api.this.id
  name                        = each.value.name
  validate_request_body       = each.value.validate_request_body
  validate_request_parameters = each.value.validate_request_parameters
}

# -----------------------------------------------------------------------------
# API Gateway Models
# Defines request/response data structures
# -----------------------------------------------------------------------------
resource "aws_api_gateway_model" "this" {
  for_each = var.models

  rest_api_id  = aws_api_gateway_rest_api.this.id
  name         = each.value.name
  description  = each.value.description
  content_type = each.value.content_type
  schema       = each.value.schema
}

# -----------------------------------------------------------------------------
# CloudWatch Log Group
# Stores API Gateway execution and access logs
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "this" {
  count = var.logging_level != "OFF" ? 1 : 0

  name              = "/aws/apigateway/${var.api_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.log_kms_key_id

  tags = merge(
    var.tags,
    {
      Name = "/aws/apigateway/${var.api_name}"
    }
  )
}

# -----------------------------------------------------------------------------
# API Gateway Authorizers
# Configures Lambda or Cognito authorizers
# -----------------------------------------------------------------------------
resource "aws_api_gateway_authorizer" "this" {
  for_each = var.authorizers

  rest_api_id = aws_api_gateway_rest_api.this.id
  name        = each.value.name
  type        = each.value.type

  authorizer_uri                   = each.value.authorizer_uri
  authorizer_credentials           = each.value.authorizer_credentials
  authorizer_result_ttl_in_seconds = each.value.authorizer_result_ttl_in_seconds
  identity_source                  = each.value.identity_source
  identity_validation_expression   = each.value.identity_validation_expression

  provider_arns = each.value.provider_arns
}

# -----------------------------------------------------------------------------
# API Gateway Deployment
# Creates a snapshot of the API configuration for deployment
# -----------------------------------------------------------------------------
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  description = var.deployment_description

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.this.body,
      length(aws_api_gateway_resource.this) > 0 ? aws_api_gateway_resource.this : {},
      length(aws_api_gateway_method.this) > 0 ? aws_api_gateway_method.this : {},
      length(aws_api_gateway_integration.this) > 0 ? aws_api_gateway_integration.this : {},
      length(local.method_responses) > 0 ? aws_api_gateway_method_response.this : {},
      length(local.integration_responses) > 0 ? aws_api_gateway_integration_response.this : {},
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.this,
    aws_api_gateway_integration.this,
    aws_api_gateway_method_response.this,
    aws_api_gateway_integration_response.this,
  ]
}

# -----------------------------------------------------------------------------
# API Gateway Stage
# Deploys the API to a specific stage (e.g., dev, staging, prod)
# tfsec:ignore:aws-api-gateway-enable-access-logging - Access logging is optional and configurable
# tfsec:ignore:aws-api-gateway-enable-tracing - X-Ray tracing is optional and configurable
# tfsec:ignore:aws-api-gateway-enable-cache-encryption - Cache encryption is optional and configurable
# -----------------------------------------------------------------------------
resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = var.stage_name
  description   = var.stage_description

  xray_tracing_enabled  = var.xray_tracing_enabled
  cache_cluster_enabled = var.cache_cluster_enabled
  cache_cluster_size    = var.cache_cluster_size

  variables = var.stage_variables

  dynamic "access_log_settings" {
    for_each = var.logging_level != "OFF" && var.access_log_format != null ? [1] : []

    content {
      destination_arn = aws_cloudwatch_log_group.this[0].arn
      format          = var.access_log_format
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.api_name}-${var.stage_name}"
    }
  )

  depends_on = [
    aws_cloudwatch_log_group.this
  ]
}

# -----------------------------------------------------------------------------
# API Gateway Method Settings
# Configures logging, metrics, and throttling for methods
# tfsec:ignore:aws-api-gateway-enable-cache - Caching is optional and configurable via variables
# -----------------------------------------------------------------------------
resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = var.method_settings_path

  settings {
    metrics_enabled                            = var.metrics_enabled
    logging_level                              = var.logging_level
    data_trace_enabled                         = var.data_trace_enabled
    throttling_burst_limit                     = var.throttling_burst_limit
    throttling_rate_limit                      = var.throttling_rate_limit
    caching_enabled                            = var.caching_enabled
    cache_ttl_in_seconds                       = var.cache_ttl_in_seconds
    cache_data_encrypted                       = var.cache_data_encrypted
    require_authorization_for_cache_control    = var.require_authorization_for_cache_control
    unauthorized_cache_control_header_strategy = var.unauthorized_cache_control_header_strategy
  }
}

# -----------------------------------------------------------------------------
# API Keys
# Creates API keys for authentication
# -----------------------------------------------------------------------------
resource "aws_api_gateway_api_key" "this" {
  for_each = var.api_keys

  name        = each.value.name
  description = each.value.description
  enabled     = each.value.enabled
  value       = each.value.value

  tags = merge(
    var.tags,
    {
      Name = each.value.name
    }
  )
}

# -----------------------------------------------------------------------------
# Usage Plans
# Configures throttling and quota limits for API consumers
# -----------------------------------------------------------------------------
resource "aws_api_gateway_usage_plan" "this" {
  for_each = var.usage_plans

  name        = each.value.name
  description = each.value.description

  dynamic "api_stages" {
    for_each = each.value.api_stages

    content {
      api_id = aws_api_gateway_rest_api.this.id
      stage  = aws_api_gateway_stage.this.stage_name
      throttle {
        path        = api_stages.value.path
        burst_limit = api_stages.value.burst_limit
        rate_limit  = api_stages.value.rate_limit
      }
    }
  }

  dynamic "quota_settings" {
    for_each = each.value.quota_limit != null ? [1] : []

    content {
      limit  = each.value.quota_limit
      offset = each.value.quota_offset
      period = each.value.quota_period
    }
  }

  dynamic "throttle_settings" {
    for_each = each.value.throttle_burst_limit != null ? [1] : []

    content {
      burst_limit = each.value.throttle_burst_limit
      rate_limit  = each.value.throttle_rate_limit
    }
  }

  tags = merge(
    var.tags,
    {
      Name = each.value.name
    }
  )
}

# -----------------------------------------------------------------------------
# Usage Plan Keys
# Associates API keys with usage plans
# -----------------------------------------------------------------------------
resource "aws_api_gateway_usage_plan_key" "this" {
  for_each = var.usage_plan_keys

  key_id        = aws_api_gateway_api_key.this[each.value.api_key_name].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.this[each.value.usage_plan_name].id
}

# -----------------------------------------------------------------------------
# Local Variables
# -----------------------------------------------------------------------------
locals {
  # Flatten method responses for all methods
  method_responses = flatten([
    for method_key, method in var.methods : [
      for response in method.method_responses : {
        method_key          = method_key
        status_code         = response.status_code
        response_parameters = response.response_parameters
        response_models     = response.response_models
      }
    ]
  ])

  # Flatten integration responses for all methods
  integration_responses = flatten([
    for method_key, method in var.methods : [
      for response in method.integration_responses : {
        method_key          = method_key
        status_code         = response.status_code
        selection_pattern   = response.selection_pattern
        response_parameters = response.response_parameters
        response_templates  = response.response_templates
        content_handling    = response.content_handling
      }
    ]
  ])
}
