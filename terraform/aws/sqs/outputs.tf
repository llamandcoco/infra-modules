# -----------------------------------------------------------------------------
# Queue Identification Outputs
# -----------------------------------------------------------------------------

output "queue_id" {
  description = "The URL of the SQS queue. Use this as the queue identifier for sending and receiving messages."
  value       = aws_sqs_queue.this.id
}

output "queue_arn" {
  description = "The ARN of the SQS queue. Use this for IAM policies, event source mappings, and cross-service integrations."
  value       = aws_sqs_queue.this.arn
}

output "queue_url" {
  description = "The URL of the SQS queue. Use this for SDK operations (SendMessage, ReceiveMessage, etc.)."
  value       = aws_sqs_queue.this.url
}

output "queue_name" {
  description = "The name of the SQS queue (including .fifo suffix for FIFO queues)."
  value       = aws_sqs_queue.this.name
}

# -----------------------------------------------------------------------------
# Queue Configuration Outputs
# -----------------------------------------------------------------------------

output "queue_fifo" {
  description = "Whether the queue is a FIFO queue (true) or standard queue (false)."
  value       = aws_sqs_queue.this.fifo_queue
}

output "content_based_deduplication" {
  description = "Whether content-based deduplication is enabled for the FIFO queue."
  value       = aws_sqs_queue.this.content_based_deduplication
}

output "visibility_timeout_seconds" {
  description = "The visibility timeout configured for the queue in seconds."
  value       = aws_sqs_queue.this.visibility_timeout_seconds
}

output "message_retention_seconds" {
  description = "The message retention period configured for the queue in seconds."
  value       = aws_sqs_queue.this.message_retention_seconds
}

output "max_message_size" {
  description = "The maximum message size configured for the queue in bytes."
  value       = aws_sqs_queue.this.max_message_size
}

output "delay_seconds" {
  description = "The delivery delay configured for the queue in seconds."
  value       = aws_sqs_queue.this.delay_seconds
}

output "receive_wait_time_seconds" {
  description = "The long polling wait time configured for the queue in seconds."
  value       = aws_sqs_queue.this.receive_wait_time_seconds
}

# -----------------------------------------------------------------------------
# Dead Letter Queue Outputs
# -----------------------------------------------------------------------------

output "dlq_enabled" {
  description = "Whether a Dead Letter Queue is enabled for this queue."
  value       = var.create_dlq
}

output "dlq_id" {
  description = "The URL of the Dead Letter Queue. Returns null if DLQ is not enabled."
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].id : null
}

output "dlq_arn" {
  description = "The ARN of the Dead Letter Queue. Use this for monitoring and redriving messages. Returns null if DLQ is not enabled."
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].arn : null
}

output "dlq_url" {
  description = "The URL of the Dead Letter Queue. Use this for SDK operations. Returns null if DLQ is not enabled."
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].url : null
}

output "dlq_name" {
  description = "The name of the Dead Letter Queue. Returns null if DLQ is not enabled."
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].name : null
}

output "max_receive_count" {
  description = "The maximum receive count before messages are moved to DLQ. Returns null if DLQ is not enabled."
  value       = var.create_dlq ? var.max_receive_count : null
}

# -----------------------------------------------------------------------------
# Security Outputs
# -----------------------------------------------------------------------------

output "kms_master_key_id" {
  description = "The ID or ARN of the KMS key used for encryption. Returns null if using SQS-managed encryption."
  value       = var.kms_master_key_id
}

output "sqs_managed_sse_enabled" {
  description = "Whether SQS-managed server-side encryption (SSE-SQS) is enabled. Returns true if no customer-managed KMS key is used."
  value       = var.kms_master_key_id == null
}

output "kms_data_key_reuse_period_seconds" {
  description = "The KMS data key reuse period in seconds. Returns null if not using customer-managed KMS encryption."
  value       = var.kms_master_key_id != null ? var.kms_data_key_reuse_period_seconds : null
}

# -----------------------------------------------------------------------------
# Policy Outputs
# -----------------------------------------------------------------------------

output "queue_policy_id" {
  description = "The ID of the queue policy resource. Returns null if no policy is attached."
  value       = var.queue_policy != null ? aws_sqs_queue_policy.this[0].id : null
}

output "dlq_policy_id" {
  description = "The ID of the DLQ policy resource. Returns null if no DLQ policy is attached."
  value       = var.create_dlq && var.dlq_policy != null ? aws_sqs_queue_policy.dlq[0].id : null
}

# -----------------------------------------------------------------------------
# FIFO Queue Specific Outputs
# -----------------------------------------------------------------------------

output "deduplication_scope" {
  description = "The deduplication scope for FIFO queue. Returns null for standard queues or when not configured."
  value       = var.fifo_queue && var.fifo_throughput_limit != null ? var.deduplication_scope : null
}

output "fifo_throughput_limit" {
  description = "The FIFO throughput limit setting. Returns null for standard queues or when not configured."
  value       = var.fifo_queue && var.fifo_throughput_limit != null ? var.fifo_throughput_limit : null
}

# -----------------------------------------------------------------------------
# Resource Reference Outputs
# -----------------------------------------------------------------------------

output "tags" {
  description = "All tags applied to the queue, including default and custom tags."
  value       = aws_sqs_queue.this.tags_all
}
