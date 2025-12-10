terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Mock AWS provider for testing without credentials
provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  access_key = "test"
  secret_key = "test"
}

# -----------------------------------------------------------------------------
# Test 1: Basic API with GET /health endpoint (root resource)
# Demonstrates minimal configuration with Lambda proxy integration
# -----------------------------------------------------------------------------

module "basic_api" {
  source = "../../"

  api_name        = "test-basic-api"
  stage_name      = "dev"
  api_description = "Basic API for health checks"

  # Simple GET method on root resource
  methods = {
    get_health = {
      resource_key            = null # Root resource
      http_method             = "GET"
      authorization           = "NONE"
      integration_type        = "MOCK"
      integration_http_method = null

      # Mock integration returns a simple response
      request_templates = {
        "application/json" = "{\"statusCode\": 200}"
      }
    }
  }

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "basic-api-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 2: API with Lambda proxy integration and path resources
# Demonstrates resource hierarchy and Lambda integration pattern
# -----------------------------------------------------------------------------

module "lambda_api" {
  source = "../../"

  api_name        = "test-lambda-api"
  stage_name      = "prod"
  api_description = "API with Lambda integration and multiple resources"

  # Create resource hierarchy: /users and /users/{id}
  resources = {
    users = {
      path_part = "users"
      parent_id = null # Uses root resource
    }
  }

  # Methods with Lambda proxy integration
  methods = {
    list_users = {
      resource_key            = "users"
      http_method             = "GET"
      authorization           = "NONE"
      integration_type        = "AWS_PROXY"
      integration_http_method = "POST"
      integration_uri         = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:123456789012:function:list-users/invocations"
    }
    create_user = {
      resource_key            = "users"
      http_method             = "POST"
      authorization           = "NONE"
      integration_type        = "AWS_PROXY"
      integration_http_method = "POST"
      integration_uri         = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:123456789012:function:create-user/invocations"
    }
  }

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "lambda-integration-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 3: API with CORS, logging, and stage variables
# Demonstrates CORS configuration and monitoring setup
# -----------------------------------------------------------------------------

module "cors_api" {
  source = "../../"

  api_name        = "test-cors-api"
  stage_name      = "staging"
  api_description = "API with CORS support and logging enabled"
  endpoint_types  = ["REGIONAL"]

  resources = {
    api_resource = {
      path_part = "api"
      parent_id = null
    }
  }

  methods = {
    get_api = {
      resource_key     = "api_resource"
      http_method      = "GET"
      authorization    = "NONE"
      integration_type = "MOCK"
      request_templates = {
        "application/json" = "{\"statusCode\": 200}"
      }
    }
  }

  # Enable CORS
  enable_cors = true
  cors_configuration = {
    api_cors = {
      resource_key  = "api_resource"
      allow_origin  = "*"
      allow_methods = "GET,POST,PUT,DELETE,OPTIONS"
      allow_headers = "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token"
    }
  }

  # Enable logging and monitoring
  logging_level        = "INFO"
  access_log_format    = "$context.requestId $context.error.message $context.error.messageString"
  log_retention_days   = 7
  metrics_enabled      = true
  xray_tracing_enabled = true

  # Stage variables for environment-specific configuration
  stage_variables = {
    environment  = "staging"
    lambda_alias = "staging"
  }

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "cors-and-logging-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 4: API with API keys, usage plans, and throttling
# Demonstrates authentication and rate limiting configuration
# -----------------------------------------------------------------------------

module "secured_api" {
  source = "../../"

  api_name        = "test-secured-api"
  stage_name      = "prod"
  api_description = "API with API keys and usage plans"

  methods = {
    get_protected = {
      resource_key     = null # Root resource
      http_method      = "GET"
      authorization    = "NONE"
      api_key_required = true
      integration_type = "MOCK"
      request_templates = {
        "application/json" = "{\"statusCode\": 200}"
      }
    }
  }

  # Create API keys
  api_keys = {
    partner_key = {
      name        = "partner-api-key"
      description = "API key for partner integration"
      enabled     = true
    }
    internal_key = {
      name        = "internal-api-key"
      description = "API key for internal use"
      enabled     = true
    }
  }

  # Create usage plans with rate limiting
  usage_plans = {
    basic_plan = {
      name        = "Basic Plan"
      description = "Basic usage plan with rate limiting"
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
    premium_plan = {
      name        = "Premium Plan"
      description = "Premium usage plan with higher limits"
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
    partner_basic = {
      api_key_name    = "partner_key"
      usage_plan_name = "basic_plan"
    }
    internal_premium = {
      api_key_name    = "internal_key"
      usage_plan_name = "premium_plan"
    }
  }

  # Method-level throttling
  throttling_burst_limit = 50
  throttling_rate_limit  = 25

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "api-key-and-throttling-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 5: API with request validation and models
# Demonstrates request validation and model definition
# -----------------------------------------------------------------------------

module "validated_api" {
  source = "../../"

  api_name        = "test-validated-api"
  stage_name      = "dev"
  api_description = "API with request validation and models"

  resources = {
    users = {
      path_part = "users"
      parent_id = null
    }
  }

  # Define request/response models
  models = {
    user_model = {
      name         = "UserModel"
      description  = "User object schema"
      content_type = "application/json"
      schema = jsonencode({
        type     = "object"
        required = ["name", "email"]
        properties = {
          name = {
            type      = "string"
            minLength = 1
          }
          email = {
            type    = "string"
            pattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
          }
          age = {
            type    = "integer"
            minimum = 0
          }
        }
      })
    }
  }

  # Create request validators
  request_validators = {
    body_validator = {
      name                        = "Validate body"
      validate_request_body       = true
      validate_request_parameters = false
    }
    params_validator = {
      name                        = "Validate parameters"
      validate_request_body       = false
      validate_request_parameters = true
    }
    full_validator = {
      name                        = "Validate body and parameters"
      validate_request_body       = true
      validate_request_parameters = true
    }
  }

  methods = {
    create_user = {
      resource_key     = "users"
      http_method      = "POST"
      authorization    = "NONE"
      integration_type = "MOCK"
      request_templates = {
        "application/json" = "{\"statusCode\": 201}"
      }
    }
  }

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "request-validation-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 6: API with caching enabled
# Demonstrates cache configuration
# -----------------------------------------------------------------------------

module "cached_api" {
  source = "../../"

  api_name        = "test-cached-api"
  stage_name      = "prod"
  api_description = "API with caching enabled"

  methods = {
    get_data = {
      resource_key     = null
      http_method      = "GET"
      authorization    = "NONE"
      integration_type = "MOCK"
      request_templates = {
        "application/json" = "{\"statusCode\": 200}"
      }
    }
  }

  # Enable caching
  cache_cluster_enabled = true
  cache_cluster_size    = "0.5"
  caching_enabled       = true
  cache_ttl_in_seconds  = 300
  cache_data_encrypted  = true

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "caching-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 7: API with custom method responses
# Demonstrates method and integration response configuration
# -----------------------------------------------------------------------------

module "custom_responses_api" {
  source = "../../"

  api_name        = "test-custom-responses-api"
  stage_name      = "dev"
  api_description = "API with custom method responses"

  methods = {
    get_with_custom_responses = {
      resource_key     = null
      http_method      = "GET"
      authorization    = "NONE"
      integration_type = "MOCK"
      request_templates = {
        "application/json" = "{\"statusCode\": 200}"
      }

      # Define multiple response codes
      method_responses = [
        {
          status_code = "200"
          response_parameters = {
            "method.response.header.Content-Type" = true
          }
          response_models = {
            "application/json" = "Empty"
          }
        },
        {
          status_code         = "400"
          response_parameters = {}
          response_models = {
            "application/json" = "Error"
          }
        },
        {
          status_code         = "500"
          response_parameters = {}
          response_models = {
            "application/json" = "Error"
          }
        }
      ]

      # Map integration responses to method responses
      integration_responses = [
        {
          status_code = "200"
          response_parameters = {
            "method.response.header.Content-Type" = "'application/json'"
          }
        },
        {
          status_code       = "400"
          selection_pattern = "4\\d{2}"
        },
        {
          status_code       = "500"
          selection_pattern = "5\\d{2}"
        }
      ]
    }
  }

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "custom-responses-testing"
  }
}

# -----------------------------------------------------------------------------
# Test Outputs
# -----------------------------------------------------------------------------

output "basic_api_invoke_url" {
  description = "Invoke URL for basic API"
  value       = module.basic_api.invoke_url
}

output "lambda_api_invoke_url" {
  description = "Invoke URL for Lambda API"
  value       = module.lambda_api.invoke_url
}

output "lambda_api_resource_paths" {
  description = "Resource paths for Lambda API"
  value       = module.lambda_api.resource_paths
}

output "cors_api_log_group" {
  description = "CloudWatch log group for CORS API"
  value       = module.cors_api.log_group_name
}

output "secured_api_usage_plan_ids" {
  description = "Usage plan IDs for secured API"
  value       = module.secured_api.usage_plan_ids
}

output "validated_api_model_names" {
  description = "Model names for validated API"
  value       = module.validated_api.model_names
}

output "validated_api_validator_ids" {
  description = "Request validator IDs"
  value       = module.validated_api.request_validator_ids
}

output "cached_api_cache_enabled" {
  description = "Cache status for cached API"
  value       = module.cached_api.cache_cluster_enabled
}

output "custom_responses_api_id" {
  description = "API ID for custom responses API"
  value       = module.custom_responses_api.api_id
}
