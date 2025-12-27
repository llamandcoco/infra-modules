# -----------------------------------------------------------------------------
# API Gateway Identification Outputs
# -----------------------------------------------------------------------------

output "api_id" {
  description = "The ID of the REST API. Use this for API Gateway resource references and integrations."
  value       = aws_api_gateway_rest_api.this.id
}

output "api_arn" {
  description = "The ARN of the REST API. Use this for IAM policies and cross-account access configurations."
  value       = aws_api_gateway_rest_api.this.arn
}

output "api_name" {
  description = "The name of the REST API."
  value       = aws_api_gateway_rest_api.this.name
}

output "root_resource_id" {
  description = "The resource ID of the REST API's root path (/). Use this as parent_id when creating additional resources."
  value       = aws_api_gateway_rest_api.this.root_resource_id
}

output "execution_arn" {
  description = "The execution ARN to be used in Lambda permissions. Format: arn:aws:execute-api:region:account-id:api-id"
  value       = aws_api_gateway_rest_api.this.execution_arn
}

# -----------------------------------------------------------------------------
# Deployment and Stage Outputs
# -----------------------------------------------------------------------------

output "deployment_id" {
  description = "The ID of the API Gateway deployment. Changes when the API configuration is updated."
  value       = aws_api_gateway_deployment.this.id
}

output "stage_name" {
  description = "The name of the deployed stage (e.g., 'dev', 'staging', 'prod')."
  value       = aws_api_gateway_stage.this.stage_name
}

output "stage_arn" {
  description = "The ARN of the API Gateway stage. Use this for CloudWatch alarms and monitoring."
  value       = aws_api_gateway_stage.this.arn
}

output "invoke_url" {
  description = "The base URL to invoke the API. Format: https://{api-id}.execute-api.{region}.amazonaws.com/{stage-name}"
  value       = aws_api_gateway_stage.this.invoke_url
}

# -----------------------------------------------------------------------------
# Resource Outputs
# -----------------------------------------------------------------------------

output "resource_ids" {
  description = "Map of resource keys to their IDs. Use these when creating methods or child resources programmatically."
  value = {
    for k, v in aws_api_gateway_resource.this : k => v.id
  }
}

output "resource_paths" {
  description = "Map of resource keys to their full paths. Shows the complete path hierarchy for each resource."
  value = {
    for k, v in aws_api_gateway_resource.this : k => v.path
  }
}

# -----------------------------------------------------------------------------
# Logging Outputs
# -----------------------------------------------------------------------------

output "log_group_name" {
  description = "The name of the CloudWatch log group for API Gateway logs. Use this to set up log subscriptions or metric filters."
  value       = var.logging_level != "OFF" ? aws_cloudwatch_log_group.this[0].name : null
}

output "log_group_arn" {
  description = "The ARN of the CloudWatch log group. Use this for IAM policies or cross-account log access."
  value       = var.logging_level != "OFF" ? aws_cloudwatch_log_group.this[0].arn : null
}

# -----------------------------------------------------------------------------
# Authorizer Outputs
# -----------------------------------------------------------------------------

output "authorizer_ids" {
  description = "Map of authorizer names to their IDs. Use these when configuring methods that require authorization."
  value = {
    for k, v in aws_api_gateway_authorizer.this : k => v.id
  }
}

# -----------------------------------------------------------------------------
# API Key and Usage Plan Outputs
# -----------------------------------------------------------------------------

output "api_key_ids" {
  description = "Map of API key names to their IDs. Use these for usage plan associations."
  value = {
    for k, v in aws_api_gateway_api_key.this : k => v.id
  }
}

output "api_key_values" {
  description = "Map of API key names to their values. SENSITIVE: Handle with care. Use these for client distribution."
  value = {
    for k, v in aws_api_gateway_api_key.this : k => v.value
  }
  sensitive = true
}

output "usage_plan_ids" {
  description = "Map of usage plan names to their IDs. Use these for associating API keys or monitoring usage."
  value = {
    for k, v in aws_api_gateway_usage_plan.this : k => v.id
  }
}

# -----------------------------------------------------------------------------
# Model and Validator Outputs
# -----------------------------------------------------------------------------

output "model_names" {
  description = "Map of model keys to their names. Lists all request/response models defined for the API."
  value = {
    for k, v in aws_api_gateway_model.this : k => v.name
  }
}

output "request_validator_ids" {
  description = "Map of validator names to their IDs. Use these when configuring method request validation."
  value = {
    for k, v in aws_api_gateway_request_validator.this : k => v.id
  }
}

# -----------------------------------------------------------------------------
# Configuration Outputs
# -----------------------------------------------------------------------------

output "endpoint_types" {
  description = "The endpoint configuration types for the API (EDGE, REGIONAL, or PRIVATE)."
  value       = var.endpoint_types
}

output "cache_cluster_enabled" {
  description = "Whether caching is enabled for the API stage. Important for understanding performance characteristics."
  value       = var.cache_cluster_enabled
}

output "xray_tracing_enabled" {
  description = "Whether X-Ray tracing is enabled. Indicates if detailed request tracing is available."
  value       = var.xray_tracing_enabled
}

output "metrics_enabled" {
  description = "Whether CloudWatch metrics are enabled. Indicates if detailed metrics are available for monitoring."
  value       = var.metrics_enabled
}

# -----------------------------------------------------------------------------
# Tags Output
# -----------------------------------------------------------------------------

output "tags" {
  description = "All tags applied to the API and related resources, including defaults and custom tags."
  value       = aws_api_gateway_rest_api.this.tags_all
}
