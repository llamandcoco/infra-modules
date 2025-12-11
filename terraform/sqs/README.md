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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_sqs_queue.dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_sqs_queue_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_content_based_deduplication"></a> [content\_based\_deduplication](#input\_content\_based\_deduplication) | Enable content-based deduplication for FIFO queues.<br/>Only used when fifo\_queue = true.<br/><br/>- true: SQS uses SHA-256 hash of message body to generate deduplication ID automatically<br/>- false: Producer must provide explicit deduplication ID with each message<br/><br/>Use this when message content uniquely identifies the message. | `bool` | `false` | no |
| <a name="input_create_dlq"></a> [create\_dlq](#input\_create\_dlq) | Create a Dead Letter Queue (DLQ) for this queue.<br/><br/>- true: Creates a separate DLQ to capture failed messages<br/>- false: No DLQ is created<br/><br/>DLQs are useful for:<br/>- Isolating problematic messages that can't be processed<br/>- Debugging and troubleshooting processing failures<br/>- Preventing message loss from repeated processing failures<br/><br/>Recommended for production queues. | `bool` | `true` | no |
| <a name="input_deduplication_scope"></a> [deduplication\_scope](#input\_deduplication\_scope) | Specifies whether message deduplication occurs at the message group or queue level.<br/>Only used when fifo\_queue = true and fifo\_throughput\_limit is set.<br/><br/>Valid values:<br/>- messageGroup: Deduplication scope is per message group (default for high throughput FIFO)<br/>- queue: Deduplication scope is at the queue level | `string` | `null` | no |
| <a name="input_delay_seconds"></a> [delay\_seconds](#input\_delay\_seconds) | The time in seconds that the delivery of all messages in the queue is delayed.<br/><br/>- Range: 0 to 900 seconds (15 minutes)<br/>- Default: 0 (no delay)<br/><br/>Use this for delayed job processing or rate limiting message delivery. | `number` | `0` | no |
| <a name="input_dlq_delay_seconds"></a> [dlq\_delay\_seconds](#input\_dlq\_delay\_seconds) | The time in seconds that the delivery of all messages in the DLQ is delayed.<br/>Only used when create\_dlq = true.<br/><br/>- Range: 0 to 900 seconds (15 minutes)<br/>- Default: 0 (no delay) | `number` | `0` | no |
| <a name="input_dlq_message_retention_seconds"></a> [dlq\_message\_retention\_seconds](#input\_dlq\_message\_retention\_seconds) | The number of seconds the DLQ retains a message.<br/>Only used when create\_dlq = true.<br/><br/>- Range: 60 seconds (1 minute) to 1,209,600 seconds (14 days)<br/>- Default: 1,209,600 seconds (14 days)<br/><br/>Recommended: Set to maximum (14 days) to allow time for investigation and reprocessing. | `number` | `1209600` | no |
| <a name="input_dlq_name"></a> [dlq\_name](#input\_dlq\_name) | Name of the Dead Letter Queue.<br/>If not specified, defaults to '{queue\_name}-dlq'.<br/>Only used when create\_dlq = true. | `string` | `null` | no |
| <a name="input_dlq_policy"></a> [dlq\_policy](#input\_dlq\_policy) | The JSON policy document for the Dead Letter Queue.<br/>Only used when create\_dlq = true.<br/><br/>If null, no policy is attached to the DLQ. | `string` | `null` | no |
| <a name="input_dlq_visibility_timeout_seconds"></a> [dlq\_visibility\_timeout\_seconds](#input\_dlq\_visibility\_timeout\_seconds) | The visibility timeout for the DLQ in seconds.<br/>Only used when create\_dlq = true.<br/><br/>- Range: 0 to 43,200 (12 hours)<br/>- Default: 30 seconds | `number` | `30` | no |
| <a name="input_fifo_queue"></a> [fifo\_queue](#input\_fifo\_queue) | Enable FIFO (First-In-First-Out) queue.<br/>- false: Creates a standard queue with at-least-once delivery and best-effort ordering<br/>- true: Creates a FIFO queue with exactly-once processing and strict ordering<br/><br/>FIFO queues:<br/>- Guarantee message ordering within message groups<br/>- Prevent duplicate messages<br/>- Limited to 300 TPS (3000 TPS with batching or high throughput mode)<br/>- Required for applications needing strict ordering and deduplication<br/><br/>Standard queues:<br/>- Nearly unlimited throughput<br/>- At-least-once delivery (messages may be delivered more than once)<br/>- Best-effort ordering (messages may arrive out of order) | `bool` | `false` | no |
| <a name="input_fifo_throughput_limit"></a> [fifo\_throughput\_limit](#input\_fifo\_throughput\_limit) | Specifies throughput limit for FIFO queues.<br/>Only used when fifo\_queue = true.<br/><br/>Valid values:<br/>- perQueue: 300 TPS for all message groups in the queue (default)<br/>- perMessageGroupId: 300 TPS per message group (high throughput mode)<br/><br/>High throughput mode (perMessageGroupId) is useful when you have many message groups<br/>and need higher aggregate throughput. | `string` | `null` | no |
| <a name="input_kms_data_key_reuse_period_seconds"></a> [kms\_data\_key\_reuse\_period\_seconds](#input\_kms\_data\_key\_reuse\_period\_seconds) | The length of time in seconds for which SQS can reuse a data key before calling KMS again.<br/>Only used when kms\_master\_key\_id is specified.<br/><br/>- Range: 60 seconds (1 minute) to 86,400 seconds (24 hours)<br/>- Default: 300 seconds (5 minutes)<br/><br/>Longer periods reduce KMS API calls and costs but increase the number of messages encrypted with the same data key. | `number` | `300` | no |
| <a name="input_kms_master_key_id"></a> [kms\_master\_key\_id](#input\_kms\_master\_key\_id) | The ID or ARN of an AWS KMS key to use for server-side encryption (SSE-KMS).<br/><br/>- If specified: Uses customer-managed KMS key (SSE-KMS) for encryption<br/>- If null: Uses SQS-managed encryption (SSE-SQS) - AWS owned key<br/><br/>SSE-SQS (default):<br/>- No additional cost<br/>- AWS manages the encryption keys<br/>- Encryption enabled by default<br/><br/>SSE-KMS (customer-managed):<br/>- Additional KMS costs apply<br/>- Customer controls key policies and rotation<br/>- CloudTrail logs of key usage<br/>- Required for compliance scenarios needing customer-managed keys<br/><br/>Note: Both options encrypt messages at rest. Choose SSE-KMS only if you need customer-managed keys. | `string` | `null` | no |
| <a name="input_max_message_size"></a> [max\_message\_size](#input\_max\_message\_size) | The maximum message size in bytes.<br/><br/>- Range: 1,024 bytes (1 KB) to 262,144 bytes (256 KB)<br/>- Default: 262,144 bytes (256 KB)<br/><br/>For messages larger than 256 KB, consider using SQS Extended Client Library with S3. | `number` | `262144` | no |
| <a name="input_max_receive_count"></a> [max\_receive\_count](#input\_max\_receive\_count) | The maximum number of times a message can be received before being moved to the DLQ.<br/>Only used when create\_dlq = true.<br/><br/>- Range: 1 to 1,000<br/>- Default: 5<br/><br/>Set this based on expected transient failures. Lower values move messages to DLQ faster. | `number` | `5` | no |
| <a name="input_message_retention_seconds"></a> [message\_retention\_seconds](#input\_message\_retention\_seconds) | The number of seconds SQS retains a message.<br/><br/>- Range: 60 seconds (1 minute) to 1,209,600 seconds (14 days)<br/>- Default: 345,600 seconds (4 days)<br/><br/>Messages are automatically deleted after this retention period expires. | `number` | `345600` | no |
| <a name="input_queue_name"></a> [queue\_name](#input\_queue\_name) | Name of the SQS queue.<br/>- For standard queues: Can be any valid queue name<br/>- For FIFO queues: Must end with .fifo suffix (automatically added if missing when fifo\_queue = true)<br/>Must be unique within the AWS account and region. | `string` | n/a | yes |
| <a name="input_queue_policy"></a> [queue\_policy](#input\_queue\_policy) | The JSON policy document for the SQS queue.<br/>Use this to grant permissions to other AWS services or accounts to access the queue.<br/><br/>Example: Allow SNS topic to send messages to the queue<br/>Example: Allow cross-account access<br/>Example: Restrict to VPC endpoints<br/><br/>If null, no queue policy is attached (only IAM-based access control applies). | `string` | `null` | no |
| <a name="input_receive_wait_time_seconds"></a> [receive\_wait\_time\_seconds](#input\_receive\_wait\_time\_seconds) | The time in seconds for which a ReceiveMessage call waits for a message to arrive (long polling).<br/><br/>- Range: 0 to 20 seconds<br/>- Default: 0 (short polling)<br/><br/>Long polling (> 0) reduces the number of empty responses and false empty receives.<br/>Recommended: Set to 20 for cost optimization and reduced latency. | `number` | `0` | no |
| <a name="input_redrive_allow_policy"></a> [redrive\_allow\_policy](#input\_redrive\_allow\_policy) | The redrive allow policy for the queue. Controls which source queues can use this queue as a DLQ.<br/><br/>Structure:<br/>- redrivePermission: "allowAll", "denyAll", or "byQueue"<br/>- sourceQueueArns: List of source queue ARNs (required when redrivePermission = "byQueue")<br/><br/>Example:<br/>{<br/>  redrivePermission = "byQueue"<br/>  sourceQueueArns   = ["arn:aws:sqs:us-east-1:123456789012:source-queue"]<br/>}<br/><br/>If null, defaults to deny all (this queue cannot be used as a DLQ by other queues). | <pre>object({<br/>    redrivePermission = string<br/>    sourceQueueArns   = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. Use this to add consistent tagging across your infrastructure. | `map(string)` | `{}` | no |
| <a name="input_visibility_timeout_seconds"></a> [visibility\_timeout\_seconds](#input\_visibility\_timeout\_seconds) | The visibility timeout for the queue in seconds.<br/>This is the time a message is invisible to other consumers after being retrieved.<br/><br/>- Range: 0 to 43,200 (12 hours)<br/>- Default: 30 seconds<br/><br/>Set this to the maximum time your application needs to process and delete a message.<br/>If the message is not deleted within this time, it becomes visible again and can be received by another consumer. | `number` | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_content_based_deduplication"></a> [content\_based\_deduplication](#output\_content\_based\_deduplication) | Whether content-based deduplication is enabled for the FIFO queue. |
| <a name="output_deduplication_scope"></a> [deduplication\_scope](#output\_deduplication\_scope) | The deduplication scope for FIFO queue. Returns null for standard queues or when not configured. |
| <a name="output_delay_seconds"></a> [delay\_seconds](#output\_delay\_seconds) | The delivery delay configured for the queue in seconds. |
| <a name="output_dlq_arn"></a> [dlq\_arn](#output\_dlq\_arn) | The ARN of the Dead Letter Queue. Use this for monitoring and redriving messages. Returns null if DLQ is not enabled. |
| <a name="output_dlq_enabled"></a> [dlq\_enabled](#output\_dlq\_enabled) | Whether a Dead Letter Queue is enabled for this queue. |
| <a name="output_dlq_id"></a> [dlq\_id](#output\_dlq\_id) | The URL of the Dead Letter Queue. Returns null if DLQ is not enabled. |
| <a name="output_dlq_name"></a> [dlq\_name](#output\_dlq\_name) | The name of the Dead Letter Queue. Returns null if DLQ is not enabled. |
| <a name="output_dlq_policy_id"></a> [dlq\_policy\_id](#output\_dlq\_policy\_id) | The ID of the DLQ policy resource. Returns null if no DLQ policy is attached. |
| <a name="output_dlq_url"></a> [dlq\_url](#output\_dlq\_url) | The URL of the Dead Letter Queue. Use this for SDK operations. Returns null if DLQ is not enabled. |
| <a name="output_fifo_throughput_limit"></a> [fifo\_throughput\_limit](#output\_fifo\_throughput\_limit) | The FIFO throughput limit setting. Returns null for standard queues or when not configured. |
| <a name="output_kms_data_key_reuse_period_seconds"></a> [kms\_data\_key\_reuse\_period\_seconds](#output\_kms\_data\_key\_reuse\_period\_seconds) | The KMS data key reuse period in seconds. Returns null if not using customer-managed KMS encryption. |
| <a name="output_kms_master_key_id"></a> [kms\_master\_key\_id](#output\_kms\_master\_key\_id) | The ID or ARN of the KMS key used for encryption. Returns null if using SQS-managed encryption. |
| <a name="output_max_message_size"></a> [max\_message\_size](#output\_max\_message\_size) | The maximum message size configured for the queue in bytes. |
| <a name="output_max_receive_count"></a> [max\_receive\_count](#output\_max\_receive\_count) | The maximum receive count before messages are moved to DLQ. Returns null if DLQ is not enabled. |
| <a name="output_message_retention_seconds"></a> [message\_retention\_seconds](#output\_message\_retention\_seconds) | The message retention period configured for the queue in seconds. |
| <a name="output_queue_arn"></a> [queue\_arn](#output\_queue\_arn) | The ARN of the SQS queue. Use this for IAM policies, event source mappings, and cross-service integrations. |
| <a name="output_queue_fifo"></a> [queue\_fifo](#output\_queue\_fifo) | Whether the queue is a FIFO queue (true) or standard queue (false). |
| <a name="output_queue_id"></a> [queue\_id](#output\_queue\_id) | The URL of the SQS queue. Use this as the queue identifier for sending and receiving messages. |
| <a name="output_queue_name"></a> [queue\_name](#output\_queue\_name) | The name of the SQS queue (including .fifo suffix for FIFO queues). |
| <a name="output_queue_policy_id"></a> [queue\_policy\_id](#output\_queue\_policy\_id) | The ID of the queue policy resource. Returns null if no policy is attached. |
| <a name="output_queue_url"></a> [queue\_url](#output\_queue\_url) | The URL of the SQS queue. Use this for SDK operations (SendMessage, ReceiveMessage, etc.). |
| <a name="output_receive_wait_time_seconds"></a> [receive\_wait\_time\_seconds](#output\_receive\_wait\_time\_seconds) | The long polling wait time configured for the queue in seconds. |
| <a name="output_sqs_managed_sse_enabled"></a> [sqs\_managed\_sse\_enabled](#output\_sqs\_managed\_sse\_enabled) | Whether SQS-managed server-side encryption (SSE-SQS) is enabled. Returns true if no customer-managed KMS key is used. |
| <a name="output_tags"></a> [tags](#output\_tags) | All tags applied to the queue, including default and custom tags. |
| <a name="output_visibility_timeout_seconds"></a> [visibility\_timeout\_seconds](#output\_visibility\_timeout\_seconds) | The visibility timeout configured for the queue in seconds. |
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
