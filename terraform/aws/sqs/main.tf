terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Dead Letter Queue (optional)
# Used to capture messages that fail processing in the main queue
resource "aws_sqs_queue" "dlq" {
  count = var.create_dlq ? 1 : 0

  name                       = var.dlq_name != null ? var.dlq_name : "${var.queue_name}-dlq"
  message_retention_seconds  = var.dlq_message_retention_seconds
  visibility_timeout_seconds = var.dlq_visibility_timeout_seconds
  delay_seconds              = var.dlq_delay_seconds

  # Encryption configuration
  sqs_managed_sse_enabled           = var.kms_master_key_id == null ? true : null
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_master_key_id != null ? var.kms_data_key_reuse_period_seconds : null

  tags = merge(
    var.tags,
    {
      Name = var.dlq_name != null ? var.dlq_name : "${var.queue_name}-dlq"
    }
  )
}

# Main SQS Queue
# Creates a standard or FIFO queue with configurable encryption, message retention, and DLQ
resource "aws_sqs_queue" "this" {
  # FIFO queues must end with .fifo suffix
  name = var.fifo_queue ? (
    can(regex("\\.fifo$", var.queue_name)) ? var.queue_name : "${var.queue_name}.fifo"
  ) : var.queue_name

  # FIFO-specific settings
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : null
  deduplication_scope         = var.fifo_queue && var.fifo_throughput_limit != null ? var.deduplication_scope : null
  fifo_throughput_limit       = var.fifo_queue && var.fifo_throughput_limit != null ? var.fifo_throughput_limit : null

  # Message configuration
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  max_message_size           = var.max_message_size
  delay_seconds              = var.delay_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds

  # Dead Letter Queue configuration
  redrive_policy = var.create_dlq ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.max_receive_count
  }) : null

  # Redrive allow policy (controls which queues can use this as a DLQ)
  redrive_allow_policy = var.redrive_allow_policy != null ? jsonencode(var.redrive_allow_policy) : null

  # Encryption configuration
  # Use SQS-managed encryption (SSE-SQS) if no KMS key is specified, otherwise use KMS (SSE-KMS)
  sqs_managed_sse_enabled           = var.kms_master_key_id == null ? true : null
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_master_key_id != null ? var.kms_data_key_reuse_period_seconds : null

  tags = merge(
    var.tags,
    {
      Name = var.fifo_queue ? (
        can(regex("\\.fifo$", var.queue_name)) ? var.queue_name : "${var.queue_name}.fifo"
      ) : var.queue_name
    }
  )
}

# Queue Policy (optional)
# Allows fine-grained access control to the queue
resource "aws_sqs_queue_policy" "this" {
  count = var.queue_policy != null ? 1 : 0

  queue_url = aws_sqs_queue.this.url
  policy    = var.queue_policy
}

# Dead Letter Queue Policy (optional)
resource "aws_sqs_queue_policy" "dlq" {
  count = var.create_dlq && var.dlq_policy != null ? 1 : 0

  queue_url = aws_sqs_queue.dlq[0].url
  policy    = var.dlq_policy
}
