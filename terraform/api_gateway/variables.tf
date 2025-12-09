# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "api_name" {
  description = "Name of the API Gateway REST API. This will be displayed in the AWS console and used in resource naming."
  type        = string

  validation {
    condition     = length(var.api_name) > 0 && length(var.api_name) <= 1024
    error_message = "API name must be between 1 and 1024 characters."
  }
}

variable "stage_name" {
  description = "Name of the API Gateway stage (e.g., 'dev', 'staging', 'prod'). This is used in the invocation URL."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.stage_name))
    error_message = "Stage name must contain only alphanumeric characters, hyphens, and underscores."
  }
}

# -----------------------------------------------------------------------------
# API Configuration Variables
# -----------------------------------------------------------------------------

variable "api_description" {
  description = "Description of the API Gateway REST API. Helps document the purpose and functionality of the API."
  type        = string
  default     = null
}

variable "endpoint_types" {
  description = "List of endpoint types. Valid values: EDGE (default), REGIONAL, or PRIVATE. EDGE uses CloudFront for global distribution."
  type        = list(string)
  default     = ["EDGE"]

  validation {
    condition     = alltrue([for t in var.endpoint_types : contains(["EDGE", "REGIONAL", "PRIVATE"], t)])
    error_message = "Endpoint types must be one of: EDGE, REGIONAL, or PRIVATE."
  }
}

variable "binary_media_types" {
  description = "List of binary media types supported by the REST API (e.g., ['image/png', 'application/octet-stream']). Required for handling binary content."
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Security Variables
# -----------------------------------------------------------------------------

variable "resource_policy" {
  description = "JSON-formatted resource policy to attach to the API. Use this to control access via IP allowlist, VPC endpoints, or AWS account restrictions. Set to null to allow public access."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Resources and Routes Variables
# -----------------------------------------------------------------------------

variable "resources" {
  description = <<-EOT
    Map of API Gateway resources (path parts). Each resource represents a path segment in your API.
    Example:
    {
      users = {
        path_part = "users"
        parent_id = null  # Uses root resource
      }
      user_id = {
        path_part = "{id}"
        parent_id = aws_api_gateway_resource.this["users"].id
      }
    }
  EOT
  type = map(object({
    path_part = string
    parent_id = optional(string) # If null, uses root resource
  }))
  default = {}
}

variable "methods" {
  description = <<-EOT
    Map of API Gateway methods and their integrations. Defines HTTP methods (GET, POST, etc.) and backend integrations.
    
    Example for Lambda proxy integration:
    {
      get_health = {
        resource_key       = null  # null for root resource
        http_method        = "GET"
        authorization      = "NONE"
        integration_type   = "AWS_PROXY"
        integration_http_method = "POST"
        integration_uri    = "arn:aws:apigateway:region:lambda:path/2015-03-31/functions/arn:aws:lambda:region:account:function:name/invocations"
      }
    }

    Integration types:
    - AWS_PROXY: Lambda proxy integration (recommended for Lambda)
    - AWS: AWS service integration with mapping templates
    - HTTP: HTTP proxy integration
    - HTTP_PROXY: HTTP proxy integration
    - MOCK: Returns a response without calling backend
  EOT
  type = map(object({
    resource_key         = optional(string) # Key from var.resources, null for root
    http_method          = string
    authorization        = string # NONE, AWS_IAM, CUSTOM, COGNITO_USER_POOLS
    authorizer_id        = optional(string)
    authorization_scopes = optional(list(string))
    api_key_required     = optional(bool, false)
    request_parameters   = optional(map(bool), {})
    request_validator_id = optional(string)
    request_models       = optional(map(string), {})
    operation_name       = optional(string)

    # Integration configuration
    integration_type               = string           # AWS_PROXY, AWS, HTTP, HTTP_PROXY, MOCK
    integration_http_method        = optional(string) # POST for Lambda, same as http_method for HTTP
    integration_uri                = optional(string)
    integration_credentials        = optional(string)
    connection_type                = optional(string, "INTERNET") # INTERNET or VPC_LINK
    connection_id                  = optional(string)
    request_templates              = optional(map(string), {})
    integration_request_parameters = optional(map(string), {})
    passthrough_behavior           = optional(string) # WHEN_NO_MATCH, WHEN_NO_TEMPLATES, NEVER
    cache_key_parameters           = optional(list(string), [])
    cache_namespace                = optional(string)
    content_handling               = optional(string) # CONVERT_TO_BINARY or CONVERT_TO_TEXT
    timeout_milliseconds           = optional(number, 29000)

    # Method responses
    method_responses = optional(list(object({
      status_code         = string
      response_parameters = optional(map(bool), {})
      response_models     = optional(map(string), {})
      })), [{
      status_code         = "200"
      response_parameters = {}
      response_models     = {}
    }])

    # Integration responses
    integration_responses = optional(list(object({
      status_code         = string
      selection_pattern   = optional(string)
      response_parameters = optional(map(string), {})
      response_templates  = optional(map(string), {})
      content_handling    = optional(string)
      })), [{
      status_code = "200"
    }])
  }))
  default = {}
}

# -----------------------------------------------------------------------------
# CORS Configuration
# -----------------------------------------------------------------------------

variable "enable_cors" {
  description = "Enable CORS (Cross-Origin Resource Sharing) support by creating OPTIONS methods. Required for browser-based applications."
  type        = bool
  default     = false
}

variable "cors_configuration" {
  description = <<-EOT
    CORS configuration for specific resources. Only used if enable_cors is true.
    Each entry creates an OPTIONS method with appropriate CORS headers.
    
    Example:
    {
      users_cors = {
        resource_key   = "users"
        allow_origin   = "*"
        allow_methods  = "GET,POST,OPTIONS"
        allow_headers  = "Content-Type,X-Amz-Date,Authorization,X-Api-Key"
      }
    }
  EOT
  type = map(object({
    resource_key  = optional(string) # null for root resource
    allow_origin  = string
    allow_methods = string
    allow_headers = string
  }))
  default = {}
}

# -----------------------------------------------------------------------------
# Request Validators
# -----------------------------------------------------------------------------

variable "request_validators" {
  description = <<-EOT
    Map of request validators to validate request parameters and body before processing.
    Improves security and reduces invalid requests reaching your backend.
    
    Example:
    {
      body_validator = {
        name                        = "Validate body"
        validate_request_body       = true
        validate_request_parameters = false
      }
    }
  EOT
  type = map(object({
    name                        = string
    validate_request_body       = bool
    validate_request_parameters = bool
  }))
  default = {}
}

# -----------------------------------------------------------------------------
# Models
# -----------------------------------------------------------------------------

variable "models" {
  description = <<-EOT
    Map of request/response models defining data structures. Used for request validation and documentation.
    Schema should be in JSON Schema format.
    
    Example:
    {
      user_model = {
        name         = "User"
        description  = "User object model"
        content_type = "application/json"
        schema       = jsonencode({
          type = "object"
          required = ["name", "email"]
          properties = {
            name  = { type = "string" }
            email = { type = "string" }
          }
        })
      }
    }
  EOT
  type = map(object({
    name         = string
    description  = optional(string)
    content_type = string
    schema       = string
  }))
  default = {}
}

# -----------------------------------------------------------------------------
# Authorizers
# -----------------------------------------------------------------------------

variable "authorizers" {
  description = <<-EOT
    Map of API Gateway authorizers for authentication and authorization.
    Supports Lambda authorizers (TOKEN or REQUEST) and Cognito User Pool authorizers.
    
    Example for Lambda authorizer:
    {
      lambda_auth = {
        name           = "LambdaAuthorizer"
        type           = "TOKEN"
        authorizer_uri = "arn:aws:apigateway:region:lambda:path/2015-03-31/functions/arn:aws:lambda:region:account:function:authorizer/invocations"
        identity_source = "method.request.header.Authorization"
      }
    }

    Example for Cognito authorizer:
    {
      cognito_auth = {
        name          = "CognitoAuthorizer"
        type          = "COGNITO_USER_POOLS"
        provider_arns = ["arn:aws:cognito-idp:region:account:userpool/pool-id"]
        identity_source = "method.request.header.Authorization"
      }
    }
  EOT
  type = map(object({
    name                             = string
    type                             = string # TOKEN, REQUEST, COGNITO_USER_POOLS
    authorizer_uri                   = optional(string)
    authorizer_credentials           = optional(string)
    authorizer_result_ttl_in_seconds = optional(number, 300)
    identity_source                  = optional(string)
    identity_validation_expression   = optional(string)
    provider_arns                    = optional(list(string))
  }))
  default = {}

  validation {
    condition     = alltrue([for auth in var.authorizers : contains(["TOKEN", "REQUEST", "COGNITO_USER_POOLS"], auth.type)])
    error_message = "Authorizer type must be one of: TOKEN, REQUEST, COGNITO_USER_POOLS."
  }
}

# -----------------------------------------------------------------------------
# Deployment Variables
# -----------------------------------------------------------------------------

variable "deployment_description" {
  description = "Description for the API Gateway deployment. Use this to track what changes are included in each deployment."
  type        = string
  default     = "Managed by Terraform"
}

variable "stage_description" {
  description = "Description of the API Gateway stage. Documents the purpose and environment of this stage."
  type        = string
  default     = null
}

variable "stage_variables" {
  description = "Map of stage variables. Use these to parameterize your API configuration per stage (e.g., Lambda aliases, backend URLs)."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Logging and Monitoring Variables
# -----------------------------------------------------------------------------

variable "logging_level" {
  description = "CloudWatch logging level for API Gateway execution logs. OFF disables logging. INFO logs all requests. ERROR logs only errors."
  type        = string
  default     = "OFF"

  validation {
    condition     = contains(["OFF", "ERROR", "INFO"], var.logging_level)
    error_message = "Logging level must be one of: OFF, ERROR, INFO."
  }
}

variable "access_log_format" {
  description = "Format for access logs. Use AWS variables like $context.requestId, $context.error.message. Set to null to disable access logging even when logging_level is not OFF."
  type        = string
  default     = "$context.requestId $context.error.message $context.error.messageString"
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs. Common values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653."
  type        = number
  default     = 7

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days must be one of: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653."
  }
}

variable "log_kms_key_id" {
  description = "ARN of the KMS key to use for CloudWatch log encryption. If not specified, logs are encrypted with AWS managed keys."
  type        = string
  default     = null
}

variable "metrics_enabled" {
  description = "Enable CloudWatch metrics for the API. Provides detailed metrics on request count, latency, errors, etc."
  type        = bool
  default     = false
}

variable "data_trace_enabled" {
  description = "Enable logging of full request/response data. WARNING: May expose sensitive data in logs. Only enable for debugging."
  type        = bool
  default     = false
}

variable "xray_tracing_enabled" {
  description = "Enable AWS X-Ray tracing for detailed request tracking and analysis. Useful for debugging and performance optimization."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Method Settings Variables
# -----------------------------------------------------------------------------

variable "method_settings_path" {
  description = "Path for method settings (e.g., '*/*' for all methods, 'users/GET' for specific method). Use '*/*' to apply settings to all methods."
  type        = string
  default     = "*/*"
}

variable "throttling_burst_limit" {
  description = "API Gateway burst limit (maximum concurrent requests). Set to -1 to use account-level settings."
  type        = number
  default     = -1
}

variable "throttling_rate_limit" {
  description = "API Gateway rate limit (requests per second). Set to -1 to use account-level settings."
  type        = number
  default     = -1
}

# -----------------------------------------------------------------------------
# Caching Variables
# -----------------------------------------------------------------------------

variable "cache_cluster_enabled" {
  description = "Enable API Gateway caching to improve performance and reduce backend load. Caching incurs additional costs."
  type        = bool
  default     = false
}

variable "cache_cluster_size" {
  description = "Size of the cache cluster. Valid values: 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118, 237. Size is in GB."
  type        = string
  default     = "0.5"

  validation {
    condition     = contains(["0.5", "1.6", "6.1", "13.5", "28.4", "58.2", "118", "237"], var.cache_cluster_size)
    error_message = "Cache cluster size must be one of: 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118, 237."
  }
}

variable "caching_enabled" {
  description = "Enable caching for API methods. Only applies if cache_cluster_enabled is true."
  type        = bool
  default     = false
}

variable "cache_ttl_in_seconds" {
  description = "Time to live (TTL) for cached responses in seconds. Must be between 0 and 3600."
  type        = number
  default     = 300

  validation {
    condition     = var.cache_ttl_in_seconds >= 0 && var.cache_ttl_in_seconds <= 3600
    error_message = "Cache TTL must be between 0 and 3600 seconds."
  }
}

variable "cache_data_encrypted" {
  description = "Encrypt cache data. Recommended for sensitive data. Only applies if caching is enabled."
  type        = bool
  default     = false
}

variable "require_authorization_for_cache_control" {
  description = "Require authorization to control cache (e.g., Cache-Control header). Improves security by preventing unauthorized cache manipulation."
  type        = bool
  default     = true
}

variable "unauthorized_cache_control_header_strategy" {
  description = "Strategy for handling unauthorized cache control headers. FAIL_WITH_403 returns 403, SUCCEED_WITH_RESPONSE_HEADER honors the header, SUCCEED_WITHOUT_RESPONSE_HEADER ignores it."
  type        = string
  default     = "SUCCEED_WITH_RESPONSE_HEADER"

  validation {
    condition     = contains(["FAIL_WITH_403", "SUCCEED_WITH_RESPONSE_HEADER", "SUCCEED_WITHOUT_RESPONSE_HEADER"], var.unauthorized_cache_control_header_strategy)
    error_message = "Strategy must be one of: FAIL_WITH_403, SUCCEED_WITH_RESPONSE_HEADER, SUCCEED_WITHOUT_RESPONSE_HEADER."
  }
}

# -----------------------------------------------------------------------------
# API Keys and Usage Plans Variables
# -----------------------------------------------------------------------------

variable "api_keys" {
  description = <<-EOT
    Map of API keys for authentication. Use with usage plans to control access and enforce rate limits.
    
    Example:
    {
      partner_key = {
        name        = "partner-api-key"
        description = "API key for partner integration"
        enabled     = true
        value       = null  # Auto-generated if null
      }
    }
  EOT
  type = map(object({
    name        = string
    description = optional(string)
    enabled     = optional(bool, true)
    value       = optional(string) # Auto-generated if null
  }))
  default = {}
}

variable "usage_plans" {
  description = <<-EOT
    Map of usage plans to configure throttling and quota limits for API consumers.
    Controls how many requests clients can make and at what rate.
    
    Example:
    {
      basic_plan = {
        name        = "Basic Plan"
        description = "Basic usage plan with rate limiting"
        api_stages = [{
          path        = "*/*"
          burst_limit = 10
          rate_limit  = 5
        }]
        quota_limit    = 1000
        quota_period   = "DAY"
        throttle_burst_limit = 20
        throttle_rate_limit  = 10
      }
    }
  EOT
  type = map(object({
    name        = string
    description = optional(string)
    api_stages = list(object({
      path        = string
      burst_limit = optional(number)
      rate_limit  = optional(number)
    }))
    quota_limit          = optional(number)
    quota_offset         = optional(number, 0)
    quota_period         = optional(string) # DAY, WEEK, MONTH
    throttle_burst_limit = optional(number)
    throttle_rate_limit  = optional(number)
  }))
  default = {}

  validation {
    condition = alltrue([
      for plan in var.usage_plans :
      plan.quota_period == null || contains(["DAY", "WEEK", "MONTH"], plan.quota_period)
    ])
    error_message = "Quota period must be one of: DAY, WEEK, MONTH."
  }
}

variable "usage_plan_keys" {
  description = <<-EOT
    Map associating API keys with usage plans. Links keys to plans to enforce throttling and quotas.
    
    Example:
    {
      partner_basic = {
        api_key_name    = "partner_key"
        usage_plan_name = "basic_plan"
      }
    }
  EOT
  type = map(object({
    api_key_name    = string
    usage_plan_name = string
  }))
  default = {}
}

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to all resources. Use this for cost allocation, resource organization, and governance."
  type        = map(string)
  default     = {}
}
