# -----------------------------------------------------------------------------
# Service Role Outputs
# -----------------------------------------------------------------------------

output "service_role_arn" {
  description = "The ARN of the Bedrock service IAM role. Use this to grant services permission to invoke Bedrock models."
  value       = local.create_service_role ? aws_iam_role.service[0].arn : null
}

output "service_role_name" {
  description = "The name of the Bedrock service IAM role. Use this for attaching additional policies."
  value       = local.create_service_role ? aws_iam_role.service[0].name : null
}

output "service_role_id" {
  description = "The unique ID of the Bedrock service IAM role."
  value       = local.create_service_role ? aws_iam_role.service[0].id : null
}

# -----------------------------------------------------------------------------
# Logging Outputs
# -----------------------------------------------------------------------------

output "log_group_name" {
  description = "The name of the CloudWatch log group for Bedrock model invocations. Use this to query logs or set up metric filters."
  value       = var.enable_model_invocation_logging ? aws_cloudwatch_log_group.bedrock[0].name : null
}

output "log_group_arn" {
  description = "The ARN of the CloudWatch log group for Bedrock model invocations."
  value       = var.enable_model_invocation_logging ? aws_cloudwatch_log_group.bedrock[0].arn : null
}

output "logging_role_arn" {
  description = "The ARN of the IAM role used by Bedrock to write logs to CloudWatch."
  value       = var.enable_model_invocation_logging ? aws_iam_role.bedrock_logging[0].arn : null
}

output "logging_role_name" {
  description = "The name of the IAM role used by Bedrock to write logs to CloudWatch."
  value       = var.enable_model_invocation_logging ? aws_iam_role.bedrock_logging[0].name : null
}

# -----------------------------------------------------------------------------
# Configuration Outputs
# -----------------------------------------------------------------------------

output "region" {
  description = "The AWS region where Bedrock resources are created."
  value       = local.region
}

output "account_id" {
  description = "The AWS account ID where Bedrock resources are created."
  value       = local.account_id
}

output "model_invocation_logging_enabled" {
  description = "Whether model invocation logging is enabled."
  value       = var.enable_model_invocation_logging
}

# -----------------------------------------------------------------------------
# Common Model ARN Patterns
# -----------------------------------------------------------------------------

output "claude_3_5_sonnet_arn" {
  description = "ARN for Claude 3.5 Sonnet v2 model. Use this for invoking the model."
  value       = "arn:aws:bedrock:${local.region}::foundation-model/anthropic.claude-3-5-sonnet-20241022-v2:0"
}

output "claude_3_opus_arn" {
  description = "ARN for Claude 3 Opus model. Use this for invoking the model."
  value       = "arn:aws:bedrock:${local.region}::foundation-model/anthropic.claude-3-opus-20240229-v1:0"
}

output "claude_3_sonnet_arn" {
  description = "ARN for Claude 3 Sonnet model. Use this for invoking the model."
  value       = "arn:aws:bedrock:${local.region}::foundation-model/anthropic.claude-3-sonnet-20240229-v1:0"
}

output "claude_3_haiku_arn" {
  description = "ARN for Claude 3 Haiku model. Use this for invoking the model."
  value       = "arn:aws:bedrock:${local.region}::foundation-model/anthropic.claude-3-haiku-20240307-v1:0"
}

output "llama_3_1_70b_arn" {
  description = "ARN for Llama 3.1 70B Instruct model. Use this for invoking the model."
  value       = "arn:aws:bedrock:${local.region}::foundation-model/meta.llama3-1-70b-instruct-v1:0"
}

output "llama_3_1_8b_arn" {
  description = "ARN for Llama 3.1 8B Instruct model. Use this for invoking the model."
  value       = "arn:aws:bedrock:${local.region}::foundation-model/meta.llama3-1-8b-instruct-v1:0"
}
