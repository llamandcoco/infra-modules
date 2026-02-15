# -----------------------------------------------------------------------------
# Topic Identification Outputs
# -----------------------------------------------------------------------------

output "topic_id" {
  description = "The ID of the SNS topic. Same as the ARN."
  value       = aws_sns_topic.this.id
}

output "topic_arn" {
  description = "The ARN of the SNS topic. Use this for IAM policies, event source mappings, and cross-service integrations."
  value       = aws_sns_topic.this.arn
}

output "topic_name" {
  description = "The name of the SNS topic (including .fifo suffix for FIFO topics)."
  value       = aws_sns_topic.this.name
}

output "topic_owner" {
  description = "The AWS account ID of the topic owner."
  value       = aws_sns_topic.this.owner
}

# -----------------------------------------------------------------------------
# Topic Configuration Outputs
# -----------------------------------------------------------------------------

output "topic_display_name" {
  description = "The display name of the SNS topic."
  value       = aws_sns_topic.this.display_name
}

output "topic_fifo" {
  description = "Whether the topic is a FIFO topic (true) or standard topic (false)."
  value       = aws_sns_topic.this.fifo_topic
}

output "content_based_deduplication" {
  description = "Whether content-based deduplication is enabled for the FIFO topic."
  value       = aws_sns_topic.this.content_based_deduplication
}

# -----------------------------------------------------------------------------
# Security Outputs
# -----------------------------------------------------------------------------

output "kms_master_key_id" {
  description = "The ID or ARN of the KMS key used for encryption. Returns null if encryption is not enabled."
  value       = aws_sns_topic.this.kms_master_key_id
}

output "signature_version" {
  description = "The signature version used for message signing."
  value       = aws_sns_topic.this.signature_version
}

# -----------------------------------------------------------------------------
# Delivery Configuration Outputs
# -----------------------------------------------------------------------------

output "tracing_config" {
  description = "The tracing configuration for AWS X-Ray. Returns null if tracing is not enabled."
  value       = aws_sns_topic.this.tracing_config
}

# -----------------------------------------------------------------------------
# Policy Outputs
# -----------------------------------------------------------------------------

output "topic_policy_id" {
  description = "The ID of the topic policy resource. Returns null if no policy is attached."
  value       = var.topic_policy != null ? aws_sns_topic_policy.this[0].id : null
}

# -----------------------------------------------------------------------------
# Subscription Outputs
# -----------------------------------------------------------------------------

output "subscription_arns" {
  description = "Map of subscription ARNs indexed by their position in the subscriptions list."
  value       = { for idx, sub in aws_sns_topic_subscription.this : idx => sub.arn }
}

output "subscription_ids" {
  description = "Map of subscription IDs indexed by their position in the subscriptions list."
  value       = { for idx, sub in aws_sns_topic_subscription.this : idx => sub.id }
}

output "subscription_count" {
  description = "The number of subscriptions created for this topic."
  value       = length(aws_sns_topic_subscription.this)
}

# -----------------------------------------------------------------------------
# Data Protection Outputs
# -----------------------------------------------------------------------------

output "data_protection_policy_enabled" {
  description = "Whether data protection policy is enabled for this topic."
  value       = var.data_protection_policy != null
}

# -----------------------------------------------------------------------------
# Delivery Status Logging Outputs
# -----------------------------------------------------------------------------

output "http_success_feedback_role_arn" {
  description = "The IAM role ARN for HTTP success feedback. Returns null if not configured."
  value       = var.http_success_feedback_role_arn
}

output "http_failure_feedback_role_arn" {
  description = "The IAM role ARN for HTTP failure feedback. Returns null if not configured."
  value       = var.http_failure_feedback_role_arn
}

output "lambda_success_feedback_role_arn" {
  description = "The IAM role ARN for Lambda success feedback. Returns null if not configured."
  value       = var.lambda_success_feedback_role_arn
}

output "lambda_failure_feedback_role_arn" {
  description = "The IAM role ARN for Lambda failure feedback. Returns null if not configured."
  value       = var.lambda_failure_feedback_role_arn
}

output "sqs_success_feedback_role_arn" {
  description = "The IAM role ARN for SQS success feedback. Returns null if not configured."
  value       = var.sqs_success_feedback_role_arn
}

output "sqs_failure_feedback_role_arn" {
  description = "The IAM role ARN for SQS failure feedback. Returns null if not configured."
  value       = var.sqs_failure_feedback_role_arn
}

output "firehose_success_feedback_role_arn" {
  description = "The IAM role ARN for Firehose success feedback. Returns null if not configured."
  value       = var.firehose_success_feedback_role_arn
}

output "firehose_failure_feedback_role_arn" {
  description = "The IAM role ARN for Firehose failure feedback. Returns null if not configured."
  value       = var.firehose_failure_feedback_role_arn
}

output "application_success_feedback_role_arn" {
  description = "The IAM role ARN for Application success feedback. Returns null if not configured."
  value       = var.application_success_feedback_role_arn
}

output "application_failure_feedback_role_arn" {
  description = "The IAM role ARN for Application failure feedback. Returns null if not configured."
  value       = var.application_failure_feedback_role_arn
}

# -----------------------------------------------------------------------------
# Resource Reference Outputs
# -----------------------------------------------------------------------------

output "tags" {
  description = "All tags applied to the topic, including default and custom tags."
  value       = aws_sns_topic.this.tags_all
}
