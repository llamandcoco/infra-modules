# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "topic_name" {
  description = <<-EOT
    Name of the SNS topic.
    - For standard topics: Can be any valid topic name
    - For FIFO topics: Can optionally end with .fifo suffix (automatically added if missing when fifo_topic = true)
    Must be unique within the AWS account and region.
  EOT
  type        = string

  validation {
    condition     = length(var.topic_name) > 0 && length(var.topic_name) <= 256
    error_message = "Topic name must be between 1 and 256 characters long."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+(\\.fifo)?$", var.topic_name))
    error_message = "Topic name must only contain alphanumeric characters, hyphens, underscores, and optionally end with .fifo for FIFO topics."
  }
}

# -----------------------------------------------------------------------------
# Topic Configuration
# -----------------------------------------------------------------------------

variable "display_name" {
  description = <<-EOT
    The display name for the SNS topic. This is used in the "From" field for SMS messages and email notifications.
    Maximum length is 100 characters.
  EOT
  type        = string
  default     = null

  validation {
    condition     = var.display_name == null || length(var.display_name) <= 100
    error_message = "Display name must be 100 characters or less."
  }
}

variable "fifo_topic" {
  description = <<-EOT
    Enable FIFO (First-In-First-Out) topic.
    - false: Creates a standard topic with at-least-once delivery
    - true: Creates a FIFO topic with exactly-once message delivery and strict ordering

    FIFO topics:
    - Guarantee message ordering
    - Prevent duplicate messages
    - Support message deduplication
    - Required for applications needing strict ordering
    - Only compatible with FIFO SQS queues as subscriptions

    Standard topics:
    - Nearly unlimited throughput
    - At-least-once delivery (messages may be delivered more than once)
    - Best-effort ordering (messages may arrive out of order)
  EOT
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = <<-EOT
    Enable content-based deduplication for FIFO topics.
    Only used when fifo_topic = true.

    - true: SNS uses SHA-256 hash of message body to generate deduplication ID automatically
    - false: Publisher must provide explicit deduplication ID with each message

    Use this when message content uniquely identifies the message.
  EOT
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Security Configuration
# -----------------------------------------------------------------------------

variable "kms_master_key_id" {
  description = <<-EOT
    The ID or ARN of an AWS KMS key to use for server-side encryption.

    - If specified: Messages are encrypted using the specified KMS key
    - If null: Messages are not encrypted at rest (default)

    Benefits of encryption:
    - Protects message content at rest
    - Compliance with security requirements
    - Customer controls key policies and rotation
    - CloudTrail logs of key usage

    Note: Encryption only protects data at rest. Messages in transit are always encrypted with TLS.
  EOT
  type        = string
  default     = null
}

variable "signature_version" {
  description = <<-EOT
    The signature version corresponds to the hashing algorithm used while creating the signature of the notifications.

    Valid values:
    - 1: Uses SHA1 (legacy, not recommended for new topics)
    - 2: Uses SHA256 (recommended for all new topics)

    Default: Uses AWS default (currently 1 for backward compatibility, but 2 is recommended)
  EOT
  type        = number
  default     = null

  validation {
    condition     = var.signature_version == null || contains([1, 2], var.signature_version)
    error_message = "signature_version must be 1, 2, or null."
  }
}

variable "tracing_config" {
  description = <<-EOT
    Tracing mode for AWS X-Ray integration.

    Valid values:
    - PassThrough: Only traces messages that have tracing enabled
    - Active: Traces all messages

    If null, X-Ray tracing is disabled (default).
  EOT
  type        = string
  default     = null

  validation {
    condition     = var.tracing_config == null || contains(["PassThrough", "Active"], var.tracing_config)
    error_message = "tracing_config must be one of: PassThrough, Active, or null."
  }
}

# -----------------------------------------------------------------------------
# Delivery Configuration
# -----------------------------------------------------------------------------

variable "delivery_policy" {
  description = <<-EOT
    The SNS delivery policy as a map. This defines how SNS retries failed message deliveries.

    Structure:
    - defaultHealthyRetryPolicy: Retry policy for healthy endpoints
      - minDelayTarget: Minimum delay for retries (seconds)
      - maxDelayTarget: Maximum delay for retries (seconds)
      - numRetries: Number of retries
      - numNoDelayRetries: Number of retries without delay
      - numMinDelayRetries: Number of retries at minimum delay
      - numMaxDelayRetries: Number of retries at maximum delay
      - backoffFunction: Backoff function (linear, arithmetic, geometric, exponential)
    - disableSubscriptionOverrides: Prevent subscriptions from overriding this policy

    If null, uses AWS default delivery policy.
  EOT
  type        = any
  default     = null
}

variable "archive_policy" {
  description = <<-EOT
    The message archive policy as a JSON string. This enables archiving messages to S3 Glacier.

    If null, message archiving is disabled (default).
  EOT
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Delivery Status Logging Configuration
# -----------------------------------------------------------------------------

variable "http_success_feedback_role_arn" {
  description = "IAM role ARN for successful HTTP/HTTPS deliveries logging. If null, success logging is disabled."
  type        = string
  default     = null
}

variable "http_success_feedback_sample_rate" {
  description = "Percentage of successful HTTP/HTTPS deliveries to log (0-100). Only used when http_success_feedback_role_arn is set."
  type        = number
  default     = null

  validation {
    condition     = var.http_success_feedback_sample_rate == null || (var.http_success_feedback_sample_rate >= 0 && var.http_success_feedback_sample_rate <= 100)
    error_message = "http_success_feedback_sample_rate must be between 0 and 100."
  }
}

variable "http_failure_feedback_role_arn" {
  description = "IAM role ARN for failed HTTP/HTTPS deliveries logging. If null, failure logging is disabled."
  type        = string
  default     = null
}

variable "lambda_success_feedback_role_arn" {
  description = "IAM role ARN for successful Lambda deliveries logging. If null, success logging is disabled."
  type        = string
  default     = null
}

variable "lambda_success_feedback_sample_rate" {
  description = "Percentage of successful Lambda deliveries to log (0-100). Only used when lambda_success_feedback_role_arn is set."
  type        = number
  default     = null

  validation {
    condition     = var.lambda_success_feedback_sample_rate == null || (var.lambda_success_feedback_sample_rate >= 0 && var.lambda_success_feedback_sample_rate <= 100)
    error_message = "lambda_success_feedback_sample_rate must be between 0 and 100."
  }
}

variable "lambda_failure_feedback_role_arn" {
  description = "IAM role ARN for failed Lambda deliveries logging. If null, failure logging is disabled."
  type        = string
  default     = null
}

variable "sqs_success_feedback_role_arn" {
  description = "IAM role ARN for successful SQS deliveries logging. If null, success logging is disabled."
  type        = string
  default     = null
}

variable "sqs_success_feedback_sample_rate" {
  description = "Percentage of successful SQS deliveries to log (0-100). Only used when sqs_success_feedback_role_arn is set."
  type        = number
  default     = null

  validation {
    condition     = var.sqs_success_feedback_sample_rate == null || (var.sqs_success_feedback_sample_rate >= 0 && var.sqs_success_feedback_sample_rate <= 100)
    error_message = "sqs_success_feedback_sample_rate must be between 0 and 100."
  }
}

variable "sqs_failure_feedback_role_arn" {
  description = "IAM role ARN for failed SQS deliveries logging. If null, failure logging is disabled."
  type        = string
  default     = null
}

variable "firehose_success_feedback_role_arn" {
  description = "IAM role ARN for successful Firehose deliveries logging. If null, success logging is disabled."
  type        = string
  default     = null
}

variable "firehose_success_feedback_sample_rate" {
  description = "Percentage of successful Firehose deliveries to log (0-100). Only used when firehose_success_feedback_role_arn is set."
  type        = number
  default     = null

  validation {
    condition     = var.firehose_success_feedback_sample_rate == null || (var.firehose_success_feedback_sample_rate >= 0 && var.firehose_success_feedback_sample_rate <= 100)
    error_message = "firehose_success_feedback_sample_rate must be between 0 and 100."
  }
}

variable "firehose_failure_feedback_role_arn" {
  description = "IAM role ARN for failed Firehose deliveries logging. If null, failure logging is disabled."
  type        = string
  default     = null
}

variable "application_success_feedback_role_arn" {
  description = "IAM role ARN for successful Application deliveries logging. If null, success logging is disabled."
  type        = string
  default     = null
}

variable "application_success_feedback_sample_rate" {
  description = "Percentage of successful Application deliveries to log (0-100). Only used when application_success_feedback_role_arn is set."
  type        = number
  default     = null

  validation {
    condition     = var.application_success_feedback_sample_rate == null || (var.application_success_feedback_sample_rate >= 0 && var.application_success_feedback_sample_rate <= 100)
    error_message = "application_success_feedback_sample_rate must be between 0 and 100."
  }
}

variable "application_failure_feedback_role_arn" {
  description = "IAM role ARN for failed Application deliveries logging. If null, failure logging is disabled."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Topic Policy Configuration
# -----------------------------------------------------------------------------

variable "topic_policy" {
  description = <<-EOT
    The JSON policy document for the SNS topic.
    Use this to grant permissions to other AWS services or accounts to publish to the topic.

    Example: Allow S3 bucket to send notifications
    Example: Allow cross-account access
    Example: Restrict to VPC endpoints

    If null, no topic policy is attached (only IAM-based access control applies).
  EOT
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Subscription Configuration
# -----------------------------------------------------------------------------

variable "subscriptions" {
  description = <<-EOT
    List of subscriptions to create for this topic. Each subscription delivers messages to a specific endpoint.

    Supported protocols:
    - http, https: HTTP/HTTPS endpoints
    - email, email-json: Email addresses (requires confirmation)
    - sms: Phone numbers
    - sqs: SQS queue ARNs
    - lambda: Lambda function ARNs
    - firehose: Kinesis Data Firehose ARNs
    - application: Mobile push notifications

    Each subscription object can include:
    - protocol (required): The protocol to use
    - endpoint (required): The endpoint to send messages to
    - endpoint_auto_confirms: Whether endpoint auto-confirms subscription
    - confirmation_timeout_in_minutes: Confirmation timeout (1-1440 minutes)
    - filter_policy: Message filtering policy
    - filter_policy_scope: Scope of filter policy (MessageAttributes or MessageBody)
    - raw_message_delivery: Enable raw message delivery (true/false)
    - redrive_policy: Dead letter queue policy
    - delivery_policy: Custom delivery policy for this subscription
    - subscription_role_arn: IAM role for Firehose subscriptions
    - replay_policy: Message replay policy

    Example:
    [
      {
        protocol = "sqs"
        endpoint = "arn:aws:sqs:us-east-1:123456789012:my-queue"
        raw_message_delivery = true
      },
      {
        protocol = "lambda"
        endpoint = "arn:aws:lambda:us-east-1:123456789012:function:my-function"
      }
    ]
  EOT
  type        = list(any)
  default     = []
}

# -----------------------------------------------------------------------------
# Data Protection Configuration
# -----------------------------------------------------------------------------

variable "data_protection_policy" {
  description = <<-EOT
    The data protection policy as a JSON string. This enables automatic detection and redaction of sensitive data.

    The policy defines:
    - Data identifiers to detect (e.g., credit card numbers, SSN, email addresses)
    - Actions to take (Audit, Deny, De-identify)
    - Destinations for audit findings

    If null, data protection is disabled (default).
  EOT
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to all resources. Use this to add consistent tagging across your infrastructure."
  type        = map(string)
  default     = {}
}
