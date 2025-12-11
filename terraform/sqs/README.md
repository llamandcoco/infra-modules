# SQS Queue Module

Production-ready Terraform module for creating and managing AWS SQS queues with comprehensive features including Dead Letter Queues, encryption, and both standard and FIFO queue support.

## Features

- **Queue Types**: Support for both Standard and FIFO (First-In-First-Out) queues
- **Dead Letter Queue**: Automatic DLQ creation with configurable redrive policy
- **Security**: Server-side encryption with SQS-managed (SSE-SQS) or customer-managed KMS keys (SSE-KMS)
- **FIFO Features**: Content-based deduplication, high throughput mode, and message group-level controls
- **Message Configuration**: Configurable visibility timeout, retention, size limits, and delivery delays
- **Long Polling**: Optional long polling support for cost optimization
- **Queue Policies**: Optional resource-based policies for cross-account and service access
- **Redrive Policies**: Control which queues can use this queue as a DLQ

## Queue Type Comparison

### Standard Queues
- **Throughput**: Nearly unlimited transactions per second
- **Ordering**: Best-effort ordering (messages may arrive out of order)
- **Delivery**: At-least-once delivery (messages may be delivered more than once)
- **Use Cases**: High-throughput applications where ordering is not critical

### FIFO Queues
- **Throughput**: 300 TPS (3,000 TPS with batching or high throughput mode)
- **Ordering**: Strict message ordering within message groups
- **Delivery**: Exactly-once processing (deduplication)
- **Use Cases**: Applications requiring strict ordering and exactly-once processing

## Usage

### Basic Standard Queue with DLQ

```hcl
module "sqs_queue" {
  source = "github.com/llamandcoco/infra-modules//terraform/sqs"

  queue_name                 = "my-queue"
  visibility_timeout_seconds = 60
  receive_wait_time_seconds  = 20 # Enable long polling

  # Dead Letter Queue
  create_dlq        = true
  max_receive_count = 5

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}
```

### FIFO Queue with Content-Based Deduplication

```hcl
module "sqs_fifo_queue" {
  source = "github.com/llamandcoco/infra-modules//terraform/sqs"

  queue_name                  = "my-fifo-queue" # .fifo suffix added automatically
  fifo_queue                  = true
  content_based_deduplication = true
  visibility_timeout_seconds  = 60

  # Dead Letter Queue
  create_dlq        = true
  max_receive_count = 3

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}
```

### High Throughput FIFO Queue

```hcl
module "sqs_high_throughput_fifo" {
  source = "github.com/llamandcoco/infra-modules//terraform/sqs"

  queue_name                  = "my-high-throughput-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true

  # High throughput mode: 300 TPS per message group
  deduplication_scope   = "messageGroup"
  fifo_throughput_limit = "perMessageGroupId"

  create_dlq        = true
  max_receive_count = 5

  tags = {
    Environment = "production"
  }
}
```

### Queue with Customer-Managed KMS Encryption

```hcl
module "sqs_encrypted_queue" {
  source = "github.com/llamandcoco/infra-modules//terraform/sqs"

  queue_name = "my-encrypted-queue"

  # Use customer-managed KMS key
  kms_master_key_id                 = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  kms_data_key_reuse_period_seconds = 300

  create_dlq        = true
  max_receive_count = 5

  tags = {
    Environment = "production"
    Compliance  = "required"
  }
}
```

### Queue with Custom Policy (SNS Integration)

```hcl
data "aws_iam_policy_document" "sqs_policy" {
  statement {
    sid    = "AllowSNSPublish"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions = [
      "sqs:SendMessage"
    ]

    resources = [
      module.sqs_queue.queue_arn
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.my_topic.arn]
    }
  }
}

module "sqs_queue" {
  source = "github.com/llamandcoco/infra-modules//terraform/sqs"

  queue_name   = "my-sns-subscribed-queue"
  queue_policy = data.aws_iam_policy_document.sqs_policy.json

  create_dlq        = true
  max_receive_count = 5

  tags = {
    Environment = "production"
  }
}
```

### Queue with Delayed Delivery

```hcl
module "sqs_delayed_queue" {
  source = "github.com/llamandcoco/infra-modules//terraform/sqs"

  queue_name    = "my-delayed-queue"
  delay_seconds = 300 # 5 minute delay for all messages

  create_dlq        = false

  tags = {
    Environment = "production"
    Purpose     = "delayed-jobs"
  }
}
```

### Queue Without DLQ

```hcl
module "sqs_simple_queue" {
  source = "github.com/llamandcoco/infra-modules//terraform/sqs"

  queue_name = "my-simple-queue"
  create_dlq = false

  tags = {
    Environment = "development"
  }
}
```

## Dead Letter Queue (DLQ) Setup

Dead Letter Queues are essential for production workloads to handle message processing failures:

1. **Isolation**: Failed messages are moved to the DLQ after `max_receive_count` attempts
2. **Debugging**: Analyze problematic messages without blocking the main queue
3. **Reprocessing**: Messages in the DLQ can be manually inspected and redriven to the source queue

### DLQ Best Practices

- Set `max_receive_count` based on expected transient failures (3-5 is typical)
- Set DLQ retention to maximum (14 days) to allow time for investigation
- Monitor DLQ depth with CloudWatch alarms
- Implement a process to review and redrive messages from the DLQ

## Encryption

This module enables encryption at rest by default:

### SSE-SQS (Default)
- Uses AWS-owned encryption keys
- No additional cost
- Automatically enabled when `kms_master_key_id` is null
- Suitable for most use cases

### SSE-KMS (Customer-Managed)
- Uses customer-managed KMS keys
- Additional KMS API costs apply
- Required for compliance scenarios needing customer-managed keys
- Provides CloudTrail audit logs for key usage
- Enabled by setting `kms_master_key_id`

## Visibility Timeout

The visibility timeout is the time a message is invisible to other consumers after being retrieved:

- Set to the maximum time your application needs to process and delete a message
- If processing takes longer, use `ChangeMessageVisibility` API to extend timeout
- Messages return to the queue if not deleted within the timeout
- After `max_receive_count` failed attempts, messages move to the DLQ

## Long Polling

Enable long polling by setting `receive_wait_time_seconds` to 1-20 seconds:

**Benefits:**
- Reduces empty responses and API costs
- Decreases latency for message delivery
- More efficient than short polling (default)

**Recommendation:** Set to 20 seconds for most use cases

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Security Best Practices

This module implements several security best practices by default:

1. **Encryption at Rest**: Server-side encryption is always enabled (SSE-SQS by default)
2. **Dead Letter Queue**: Enabled by default to prevent message loss
3. **Secure Defaults**: Reasonable message retention and visibility timeouts
4. **Encryption Key Reuse**: Optimized for security and cost balance (5 minute default)

## Testing

The module includes comprehensive test configurations in `tests/basic/` that can be run without AWS credentials:

```bash
cd tests/basic
terraform init -backend=false
terraform plan
```

Tests cover:
- Standard queue with DLQ
- FIFO queue with content-based deduplication
- KMS encrypted queue
- High throughput FIFO queue
- Delayed delivery queue

## Common Use Cases

### Event-Driven Architecture
Use SQS to decouple microservices and handle asynchronous processing.

### Job Queues
Implement background job processing with DLQ for failed jobs.

### SNS Fan-Out
Subscribe SQS queues to SNS topics for message distribution.

### Lambda Event Sources
Trigger Lambda functions from SQS queues for serverless processing.

### API Request Buffering
Buffer API requests during traffic spikes to prevent overload.

## Migration from SNS or Other Messaging Systems

When migrating to SQS:

1. **From SNS**: Consider SNS → SQS fan-out pattern for multiple consumers
2. **Message Format**: Ensure message size is under 256 KB (use S3 for larger messages)
3. **Ordering**: Use FIFO queues if strict ordering is required
4. **Deduplication**: Enable content-based deduplication for FIFO queues or implement application-level deduplication

## Limitations

### Standard Queues
- Message order is not guaranteed
- Messages may be delivered more than once

### FIFO Queues
- 300 TPS limit (3,000 with batching or high throughput mode)
- Must end with `.fifo` suffix (automatically added by this module)
- Cannot convert standard queue to FIFO or vice versa

### General
- Maximum message size: 256 KB
- Maximum retention period: 14 days
- Maximum visibility timeout: 12 hours
