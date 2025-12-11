# -----------------------------------------------------------------------------
# Lambda Function Outputs
# -----------------------------------------------------------------------------

output "function_arn" {
  description = "The ARN of the Lambda function. Use this for IAM policies, event source mappings, and cross-account access."
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "The name of the Lambda function. Use this for AWS CLI commands and SDK calls."
  value       = aws_lambda_function.this.function_name
}

output "function_qualified_arn" {
  description = "The ARN of the Lambda function with version qualifier. Use this to reference a specific version of the function."
  value       = aws_lambda_function.this.qualified_arn
}

output "invoke_arn" {
  description = "The ARN to use when invoking the function from API Gateway, EventBridge, or other AWS services."
  value       = aws_lambda_function.this.invoke_arn
}

output "version" {
  description = "The version of the Lambda function. Increments with each publish operation."
  value       = aws_lambda_function.this.version
}

output "last_modified" {
  description = "The date the Lambda function was last modified."
  value       = aws_lambda_function.this.last_modified
}

# -----------------------------------------------------------------------------
# IAM Role Outputs
# -----------------------------------------------------------------------------

output "role_arn" {
  description = "The ARN of the Lambda execution IAM role. Use this for trust relationships and policy attachments."
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "The name of the Lambda execution IAM role. Use this for attaching additional policies."
  value       = aws_iam_role.this.name
}

output "role_id" {
  description = "The unique ID of the IAM role. Use this for programmatic role identification."
  value       = aws_iam_role.this.id
}

# -----------------------------------------------------------------------------
# CloudWatch Logs Outputs
# -----------------------------------------------------------------------------

output "log_group_name" {
  description = "The name of the CloudWatch log group for Lambda function logs. Use this to set up log subscriptions or metric filters."
  value       = aws_cloudwatch_log_group.this.name
}

output "log_group_arn" {
  description = "The ARN of the CloudWatch log group. Use this for IAM policies or cross-account log access."
  value       = aws_cloudwatch_log_group.this.arn
}

# -----------------------------------------------------------------------------
# Configuration Outputs
# -----------------------------------------------------------------------------

output "runtime" {
  description = "The runtime environment of the Lambda function (e.g., python3.12, nodejs20.x)."
  value       = aws_lambda_function.this.runtime
}

output "handler" {
  description = "The function entrypoint handler."
  value       = aws_lambda_function.this.handler
}

output "memory_size" {
  description = "The amount of memory allocated to the Lambda function in MB."
  value       = aws_lambda_function.this.memory_size
}

output "timeout" {
  description = "The maximum execution time of the Lambda function in seconds."
  value       = aws_lambda_function.this.timeout
}
