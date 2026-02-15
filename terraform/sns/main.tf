terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  # Compute the topic name once to avoid duplication
  topic_name = var.fifo_topic ? (can(regex("\\.fifo$", var.topic_name)) ? var.topic_name : "${var.topic_name}.fifo") : var.topic_name
}

# SNS Topic
# Creates an SNS topic with configurable encryption, access policies, and delivery settings
resource "aws_sns_topic" "this" {
  name         = local.topic_name
  display_name = var.display_name

  # FIFO-specific settings
  fifo_topic                  = var.fifo_topic
  content_based_deduplication = var.fifo_topic ? var.content_based_deduplication : null

  # Encryption configuration
  # Use KMS encryption if key is specified, otherwise no encryption (default)
  kms_master_key_id = var.kms_master_key_id

  # Delivery configuration
  delivery_policy = var.delivery_policy != null ? jsonencode(var.delivery_policy) : null

  # Signature version for message authenticity
  signature_version = var.signature_version

  # Tracing configuration for AWS X-Ray
  tracing_config = var.tracing_config

  # Archive policy for message archiving to S3 Glacier
  archive_policy = var.archive_policy

  # HTTP delivery settings
  http_success_feedback_role_arn    = var.http_success_feedback_role_arn
  http_success_feedback_sample_rate = var.http_success_feedback_sample_rate
  http_failure_feedback_role_arn    = var.http_failure_feedback_role_arn

  # Lambda delivery settings
  lambda_success_feedback_role_arn    = var.lambda_success_feedback_role_arn
  lambda_success_feedback_sample_rate = var.lambda_success_feedback_sample_rate
  lambda_failure_feedback_role_arn    = var.lambda_failure_feedback_role_arn

  # SQS delivery settings
  sqs_success_feedback_role_arn    = var.sqs_success_feedback_role_arn
  sqs_success_feedback_sample_rate = var.sqs_success_feedback_sample_rate
  sqs_failure_feedback_role_arn    = var.sqs_failure_feedback_role_arn

  # Firehose delivery settings
  firehose_success_feedback_role_arn    = var.firehose_success_feedback_role_arn
  firehose_success_feedback_sample_rate = var.firehose_success_feedback_sample_rate
  firehose_failure_feedback_role_arn    = var.firehose_failure_feedback_role_arn

  # Application delivery settings
  application_success_feedback_role_arn    = var.application_success_feedback_role_arn
  application_success_feedback_sample_rate = var.application_success_feedback_sample_rate
  application_failure_feedback_role_arn    = var.application_failure_feedback_role_arn

  tags = merge(
    var.tags,
    {
      Name = local.topic_name
    }
  )

  lifecycle {
    precondition {
      condition     = length(local.topic_name) <= 256
      error_message = "Final topic name must be 256 characters or less (including auto-appended .fifo suffix)."
    }

    precondition {
      condition     = var.fifo_topic || !can(regex("\\.fifo$", var.topic_name))
      error_message = "topic_name must not end with .fifo when fifo_topic is false."
    }
  }
}

# Topic Policy (optional)
# Allows fine-grained access control to the topic
resource "aws_sns_topic_policy" "this" {
  count = var.topic_policy != null ? 1 : 0

  arn    = aws_sns_topic.this.arn
  policy = var.topic_policy
}

# Topic Subscription (optional)
# Creates subscriptions to the topic for various endpoints
resource "aws_sns_topic_subscription" "this" {
  for_each = { for idx, sub in var.subscriptions : idx => sub }

  topic_arn = aws_sns_topic.this.arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint

  # Optional subscription attributes
  endpoint_auto_confirms          = lookup(each.value, "endpoint_auto_confirms", null)
  confirmation_timeout_in_minutes = lookup(each.value, "confirmation_timeout_in_minutes", null)
  filter_policy                   = lookup(each.value, "filter_policy", null) != null ? jsonencode(lookup(each.value, "filter_policy", null)) : null
  filter_policy_scope             = lookup(each.value, "filter_policy_scope", null)
  raw_message_delivery            = lookup(each.value, "raw_message_delivery", null)
  redrive_policy                  = lookup(each.value, "redrive_policy", null) != null ? jsonencode(lookup(each.value, "redrive_policy", null)) : null
  delivery_policy                 = lookup(each.value, "delivery_policy", null) != null ? jsonencode(lookup(each.value, "delivery_policy", null)) : null
  subscription_role_arn           = lookup(each.value, "subscription_role_arn", null)
  replay_policy                   = lookup(each.value, "replay_policy", null) != null ? jsonencode(lookup(each.value, "replay_policy", null)) : null
}

# Data Source Protection Policy (optional)
# Protects sensitive data in messages using data protection policies
resource "aws_sns_topic_data_protection_policy" "this" {
  count = var.data_protection_policy != null ? 1 : 0

  arn    = aws_sns_topic.this.arn
  policy = var.data_protection_policy
}
