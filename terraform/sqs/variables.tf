# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "queue_name" {
  description = <<-EOT
    Name of the SQS queue.
    - For standard queues: Can be any valid queue name
    - For FIFO queues: Must end with .fifo suffix (automatically added if missing when fifo_queue = true)
    Must be unique within the AWS account and region.
  EOT
  type        = string

  validation {
    condition     = length(var.queue_name) > 0 && length(var.queue_name) <= 80
    error_message = "Queue name must be between 1 and 80 characters long."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+(\\.fifo)?$", var.queue_name))
    error_message = "Queue name must only contain alphanumeric characters, hyphens, underscores, and optionally end with .fifo for FIFO queues."
  }
}

# -----------------------------------------------------------------------------
# Queue Type Configuration
# -----------------------------------------------------------------------------

variable "fifo_queue" {
  description = <<-EOT
    Enable FIFO (First-In-First-Out) queue.
    - false: Creates a standard queue with at-least-once delivery and best-effort ordering
    - true: Creates a FIFO queue with exactly-once processing and strict ordering

    FIFO queues:
    - Guarantee message ordering within message groups
    - Prevent duplicate messages
    - Limited to 300 TPS (3000 TPS with batching or high throughput mode)
    - Required for applications needing strict ordering and deduplication

    Standard queues:
    - Nearly unlimited throughput
    - At-least-once delivery (messages may be delivered more than once)
    - Best-effort ordering (messages may arrive out of order)
  EOT
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = <<-EOT
    Enable content-based deduplication for FIFO queues.
    Only used when fifo_queue = true.

    - true: SQS uses SHA-256 hash of message body to generate deduplication ID automatically
    - false: Producer must provide explicit deduplication ID with each message

    Use this when message content uniquely identifies the message.
  EOT
  type        = bool
  default     = false
}

variable "deduplication_scope" {
  description = <<-EOT
    Specifies whether message deduplication occurs at the message group or queue level.
    Only used when fifo_queue = true and fifo_throughput_limit is set.

    Valid values:
    - messageGroup: Deduplication scope is per message group (default for high throughput FIFO)
    - queue: Deduplication scope is at the queue level
  EOT
  type        = string
  default     = null

  validation {
    condition     = var.deduplication_scope == null || contains(["messageGroup", "queue"], var.deduplication_scope)
    error_message = "Deduplication scope must be either 'messageGroup' or 'queue'."
  }
}

variable "fifo_throughput_limit" {
  description = <<-EOT
    Specifies throughput limit for FIFO queues.
    Only used when fifo_queue = true.

    Valid values:
    - perQueue: 300 TPS for all message groups in the queue (default)
    - perMessageGroupId: 300 TPS per message group (high throughput mode)

    High throughput mode (perMessageGroupId) is useful when you have many message groups
    and need higher aggregate throughput.
  EOT
  type        = string
  default     = null

  validation {
    condition     = var.fifo_throughput_limit == null || contains(["perQueue", "perMessageGroupId"], var.fifo_throughput_limit)
    error_message = "FIFO throughput limit must be either 'perQueue' or 'perMessageGroupId'."
  }
}

# -----------------------------------------------------------------------------
# Message Configuration
# -----------------------------------------------------------------------------

variable "visibility_timeout_seconds" {
  description = <<-EOT
    The visibility timeout for the queue in seconds.
    This is the time a message is invisible to other consumers after being retrieved.

    - Range: 0 to 43,200 (12 hours)
    - Default: 30 seconds

    Set this to the maximum time your application needs to process and delete a message.
    If the message is not deleted within this time, it becomes visible again and can be received by another consumer.
  EOT
  type        = number
  default     = 30

  validation {
    condition     = var.visibility_timeout_seconds >= 0 && var.visibility_timeout_seconds <= 43200
    error_message = "Visibility timeout must be between 0 and 43,200 seconds (12 hours)."
  }
}

variable "message_retention_seconds" {
  description = <<-EOT
    The number of seconds SQS retains a message.

    - Range: 60 seconds (1 minute) to 1,209,600 seconds (14 days)
    - Default: 345,600 seconds (4 days)

    Messages are automatically deleted after this retention period expires.
  EOT
  type        = number
  default     = 345600

  validation {
    condition     = var.message_retention_seconds >= 60 && var.message_retention_seconds <= 1209600
    error_message = "Message retention must be between 60 seconds (1 minute) and 1,209,600 seconds (14 days)."
  }
}

variable "max_message_size" {
  description = <<-EOT
    The maximum message size in bytes.

    - Range: 1,024 bytes (1 KB) to 262,144 bytes (256 KB)
    - Default: 262,144 bytes (256 KB)

    For messages larger than 256 KB, consider using SQS Extended Client Library with S3.
  EOT
  type        = number
  default     = 262144

  validation {
    condition     = var.max_message_size >= 1024 && var.max_message_size <= 262144
    error_message = "Max message size must be between 1,024 bytes (1 KB) and 262,144 bytes (256 KB)."
  }
}

variable "delay_seconds" {
  description = <<-EOT
    The time in seconds that the delivery of all messages in the queue is delayed.

    - Range: 0 to 900 seconds (15 minutes)
    - Default: 0 (no delay)

    Use this for delayed job processing or rate limiting message delivery.
  EOT
  type        = number
  default     = 0

  validation {
    condition     = var.delay_seconds >= 0 && var.delay_seconds <= 900
    error_message = "Delay seconds must be between 0 and 900 seconds (15 minutes)."
  }
}

variable "receive_wait_time_seconds" {
  description = <<-EOT
    The time in seconds for which a ReceiveMessage call waits for a message to arrive (long polling).

    - Range: 0 to 20 seconds
    - Default: 0 (short polling)

    Long polling (> 0) reduces the number of empty responses and false empty receives.
    Recommended: Set to 20 for cost optimization and reduced latency.
  EOT
  type        = number
  default     = 0

  validation {
    condition     = var.receive_wait_time_seconds >= 0 && var.receive_wait_time_seconds <= 20
    error_message = "Receive wait time must be between 0 and 20 seconds."
  }
}

# -----------------------------------------------------------------------------
# Dead Letter Queue Configuration
# -----------------------------------------------------------------------------

variable "create_dlq" {
  description = <<-EOT
    Create a Dead Letter Queue (DLQ) for this queue.

    - true: Creates a separate DLQ to capture failed messages
    - false: No DLQ is created

    DLQs are useful for:
    - Isolating problematic messages that can't be processed
    - Debugging and troubleshooting processing failures
    - Preventing message loss from repeated processing failures

    Recommended for production queues.
  EOT
  type        = bool
  default     = true
}

variable "dlq_name" {
  description = <<-EOT
    Name of the Dead Letter Queue.
    If not specified, defaults to '{queue_name}-dlq'.
    Only used when create_dlq = true.
  EOT
  type        = string
  default     = null
}

variable "max_receive_count" {
  description = <<-EOT
    The maximum number of times a message can be received before being moved to the DLQ.
    Only used when create_dlq = true.

    - Range: 1 to 1,000
    - Default: 5

    Set this based on expected transient failures. Lower values move messages to DLQ faster.
  EOT
  type        = number
  default     = 5

  validation {
    condition     = var.max_receive_count >= 1 && var.max_receive_count <= 1000
    error_message = "Max receive count must be between 1 and 1,000."
  }
}

variable "dlq_message_retention_seconds" {
  description = <<-EOT
    The number of seconds the DLQ retains a message.
    Only used when create_dlq = true.

    - Range: 60 seconds (1 minute) to 1,209,600 seconds (14 days)
    - Default: 1,209,600 seconds (14 days)

    Recommended: Set to maximum (14 days) to allow time for investigation and reprocessing.
  EOT
  type        = number
  default     = 1209600

  validation {
    condition     = var.dlq_message_retention_seconds >= 60 && var.dlq_message_retention_seconds <= 1209600
    error_message = "DLQ message retention must be between 60 seconds (1 minute) and 1,209,600 seconds (14 days)."
  }
}

variable "dlq_visibility_timeout_seconds" {
  description = <<-EOT
    The visibility timeout for the DLQ in seconds.
    Only used when create_dlq = true.

    - Range: 0 to 43,200 (12 hours)
    - Default: 30 seconds
  EOT
  type        = number
  default     = 30

  validation {
    condition     = var.dlq_visibility_timeout_seconds >= 0 && var.dlq_visibility_timeout_seconds <= 43200
    error_message = "DLQ visibility timeout must be between 0 and 43,200 seconds (12 hours)."
  }
}

variable "dlq_delay_seconds" {
  description = <<-EOT
    The time in seconds that the delivery of all messages in the DLQ is delayed.
    Only used when create_dlq = true.

    - Range: 0 to 900 seconds (15 minutes)
    - Default: 0 (no delay)
  EOT
  type        = number
  default     = 0

  validation {
    condition     = var.dlq_delay_seconds >= 0 && var.dlq_delay_seconds <= 900
    error_message = "DLQ delay seconds must be between 0 and 900 seconds (15 minutes)."
  }
}

# -----------------------------------------------------------------------------
# Security Configuration
# -----------------------------------------------------------------------------

variable "kms_master_key_id" {
  description = <<-EOT
    The ID or ARN of an AWS KMS key to use for server-side encryption (SSE-KMS).

    - If specified: Uses customer-managed KMS key (SSE-KMS) for encryption
    - If null: Uses SQS-managed encryption (SSE-SQS) - AWS owned key

    SSE-SQS (default):
    - No additional cost
    - AWS manages the encryption keys
    - Encryption enabled by default

    SSE-KMS (customer-managed):
    - Additional KMS costs apply
    - Customer controls key policies and rotation
    - CloudTrail logs of key usage
    - Required for compliance scenarios needing customer-managed keys

    Note: Both options encrypt messages at rest. Choose SSE-KMS only if you need customer-managed keys.
  EOT
  type        = string
  default     = null
}

variable "kms_data_key_reuse_period_seconds" {
  description = <<-EOT
    The length of time in seconds for which SQS can reuse a data key before calling KMS again.
    Only used when kms_master_key_id is specified.

    - Range: 60 seconds (1 minute) to 86,400 seconds (24 hours)
    - Default: 300 seconds (5 minutes)

    Longer periods reduce KMS API calls and costs but increase the number of messages encrypted with the same data key.
  EOT
  type        = number
  default     = 300

  validation {
    condition     = var.kms_data_key_reuse_period_seconds >= 60 && var.kms_data_key_reuse_period_seconds <= 86400
    error_message = "KMS data key reuse period must be between 60 and 86,400 seconds (1 minute to 24 hours)."
  }
}

# -----------------------------------------------------------------------------
# Queue Policy Configuration
# -----------------------------------------------------------------------------

variable "queue_policy" {
  description = <<-EOT
    The JSON policy document for the SQS queue.
    Use this to grant permissions to other AWS services or accounts to access the queue.

    Example: Allow SNS topic to send messages to the queue
    Example: Allow cross-account access
    Example: Restrict to VPC endpoints

    If null, no queue policy is attached (only IAM-based access control applies).
  EOT
  type        = string
  default     = null
}

variable "dlq_policy" {
  description = <<-EOT
    The JSON policy document for the Dead Letter Queue.
    Only used when create_dlq = true.

    If null, no policy is attached to the DLQ.
  EOT
  type        = string
  default     = null
}

variable "redrive_allow_policy" {
  description = <<-EOT
    The redrive allow policy for the queue. Controls which source queues can use this queue as a DLQ.

    Structure:
    - redrivePermission: "allowAll", "denyAll", or "byQueue"
    - sourceQueueArns: List of source queue ARNs (required when redrivePermission = "byQueue")

    Example:
    {
      redrivePermission = "byQueue"
      sourceQueueArns   = ["arn:aws:sqs:us-east-1:123456789012:source-queue"]
    }

    If null, defaults to deny all (this queue cannot be used as a DLQ by other queues).
  EOT
  type = object({
    redrivePermission = string
    sourceQueueArns   = optional(list(string))
  })
  default = null

  validation {
    condition = var.redrive_allow_policy == null || (
      contains(["allowAll", "denyAll", "byQueue"], var.redrive_allow_policy.redrivePermission)
    )
    error_message = "Redrive permission must be one of: allowAll, denyAll, byQueue."
  }
}

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to all resources. Use this to add consistent tagging across your infrastructure."
  type        = map(string)
  default     = {}
}
