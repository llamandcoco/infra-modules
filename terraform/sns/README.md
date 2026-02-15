# SNS Topic Module

A production-ready Terraform module for creating and managing AWS SNS topics with support for Standard and FIFO topic types, KMS encryption, subscriptions, and delivery status logging.

## Features

- **Topic Types:** Support for both Standard and FIFO (First-In-First-Out) topics
- **Security:** Server-side encryption with customer-managed KMS keys
- **Subscriptions:** Create and manage topic subscriptions for SQS, Lambda, Email, SMS, HTTP/S, Firehose, and mobile push
- **FIFO Features:** Content-based deduplication and strict message ordering
- **Delivery Policies:** Configurable retry policies and delivery controls
- **Status Logging:** Delivery status logging for Lambda, SQS, HTTP, Firehose, and Application endpoints
- **X-Ray Tracing:** Optional AWS X-Ray integration for message tracing
- **Data Protection:** Optional sensitive data detection and redaction policies

## Quick Start

```hcl
module "sns" {
  source = "github.com/llamandcoco/infra-modules//terraform/sns?ref=<commit-sha>"

  topic_name = "my-topic"
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic Configuration | [`tests/basic/main.tf`](tests/basic/main.tf) |

**Usage:**
```bash
# View example
cat tests/basic/main.tf

# Copy and adapt
cp -r tests/basic/ my-project/
```

## Testing

```bash
cd tests/basic && terraform init && terraform plan
```

<details>
<summary>Terraform Documentation</summary>

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_sns_topic.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_data_protection_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_data_protection_policy) | resource |
| [aws_sns_topic_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_subscription.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_failure_feedback_role_arn"></a> [application\_failure\_feedback\_role\_arn](#input\_application\_failure\_feedback\_role\_arn) | IAM role ARN for failed Application deliveries logging. If null, failure logging is disabled. | `string` | `null` | no |
| <a name="input_application_success_feedback_role_arn"></a> [application\_success\_feedback\_role\_arn](#input\_application\_success\_feedback\_role\_arn) | IAM role ARN for successful Application deliveries logging. If null, success logging is disabled. | `string` | `null` | no |
| <a name="input_application_success_feedback_sample_rate"></a> [application\_success\_feedback\_sample\_rate](#input\_application\_success\_feedback\_sample\_rate) | Percentage of successful Application deliveries to log (0-100). Only used when application\_success\_feedback\_role\_arn is set. | `number` | `null` | no |
| <a name="input_archive_policy"></a> [archive\_policy](#input\_archive\_policy) | The message archive policy as a JSON string. This enables archiving messages to S3 Glacier.<br/><br/>If null, message archiving is disabled (default). | `string` | `null` | no |
| <a name="input_content_based_deduplication"></a> [content\_based\_deduplication](#input\_content\_based\_deduplication) | Enable content-based deduplication for FIFO topics.<br/>Only used when fifo\_topic = true.<br/><br/>- true: SNS uses SHA-256 hash of message body to generate deduplication ID automatically<br/>- false: Publisher must provide explicit deduplication ID with each message<br/><br/>Use this when message content uniquely identifies the message. | `bool` | `false` | no |
| <a name="input_data_protection_policy"></a> [data\_protection\_policy](#input\_data\_protection\_policy) | The data protection policy as a JSON string. This enables automatic detection and redaction of sensitive data.<br/><br/>The policy defines:<br/>- Data identifiers to detect (e.g., credit card numbers, SSN, email addresses)<br/>- Actions to take (Audit, Deny, De-identify)<br/>- Destinations for audit findings<br/><br/>If null, data protection is disabled (default). | `string` | `null` | no |
| <a name="input_delivery_policy"></a> [delivery\_policy](#input\_delivery\_policy) | The SNS delivery policy as a map. This defines how SNS retries failed message deliveries.<br/><br/>Structure:<br/>- defaultHealthyRetryPolicy: Retry policy for healthy endpoints<br/>  - minDelayTarget: Minimum delay for retries (seconds)<br/>  - maxDelayTarget: Maximum delay for retries (seconds)<br/>  - numRetries: Number of retries<br/>  - numNoDelayRetries: Number of retries without delay<br/>  - numMinDelayRetries: Number of retries at minimum delay<br/>  - numMaxDelayRetries: Number of retries at maximum delay<br/>  - backoffFunction: Backoff function (linear, arithmetic, geometric, exponential)<br/>- disableSubscriptionOverrides: Prevent subscriptions from overriding this policy<br/><br/>If null, uses AWS default delivery policy. | `any` | `null` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | The display name for the SNS topic. This is used in the "From" field for SMS messages and email notifications.<br/>Maximum length is 100 characters. | `string` | `null` | no |
| <a name="input_fifo_topic"></a> [fifo\_topic](#input\_fifo\_topic) | Enable FIFO (First-In-First-Out) topic.<br/>- false: Creates a standard topic with at-least-once delivery<br/>- true: Creates a FIFO topic with exactly-once message delivery and strict ordering<br/><br/>FIFO topics:<br/>- Guarantee message ordering<br/>- Prevent duplicate messages<br/>- Support message deduplication<br/>- Required for applications needing strict ordering<br/>- Only compatible with FIFO SQS queues as subscriptions<br/><br/>Standard topics:<br/>- Nearly unlimited throughput<br/>- At-least-once delivery (messages may be delivered more than once)<br/>- Best-effort ordering (messages may arrive out of order) | `bool` | `false` | no |
| <a name="input_firehose_failure_feedback_role_arn"></a> [firehose\_failure\_feedback\_role\_arn](#input\_firehose\_failure\_feedback\_role\_arn) | IAM role ARN for failed Firehose deliveries logging. If null, failure logging is disabled. | `string` | `null` | no |
| <a name="input_firehose_success_feedback_role_arn"></a> [firehose\_success\_feedback\_role\_arn](#input\_firehose\_success\_feedback\_role\_arn) | IAM role ARN for successful Firehose deliveries logging. If null, success logging is disabled. | `string` | `null` | no |
| <a name="input_firehose_success_feedback_sample_rate"></a> [firehose\_success\_feedback\_sample\_rate](#input\_firehose\_success\_feedback\_sample\_rate) | Percentage of successful Firehose deliveries to log (0-100). Only used when firehose\_success\_feedback\_role\_arn is set. | `number` | `null` | no |
| <a name="input_http_failure_feedback_role_arn"></a> [http\_failure\_feedback\_role\_arn](#input\_http\_failure\_feedback\_role\_arn) | IAM role ARN for failed HTTP/HTTPS deliveries logging. If null, failure logging is disabled. | `string` | `null` | no |
| <a name="input_http_success_feedback_role_arn"></a> [http\_success\_feedback\_role\_arn](#input\_http\_success\_feedback\_role\_arn) | IAM role ARN for successful HTTP/HTTPS deliveries logging. If null, success logging is disabled. | `string` | `null` | no |
| <a name="input_http_success_feedback_sample_rate"></a> [http\_success\_feedback\_sample\_rate](#input\_http\_success\_feedback\_sample\_rate) | Percentage of successful HTTP/HTTPS deliveries to log (0-100). Only used when http\_success\_feedback\_role\_arn is set. | `number` | `null` | no |
| <a name="input_kms_master_key_id"></a> [kms\_master\_key\_id](#input\_kms\_master\_key\_id) | The ID or ARN of an AWS KMS key to use for server-side encryption.<br/><br/>- If specified: Messages are encrypted using the specified KMS key<br/>- If null: Messages are not encrypted at rest (default)<br/><br/>Benefits of encryption:<br/>- Protects message content at rest<br/>- Compliance with security requirements<br/>- Customer controls key policies and rotation<br/>- CloudTrail logs of key usage<br/><br/>Note: Encryption only protects data at rest. Messages in transit are always encrypted with TLS. | `string` | `null` | no |
| <a name="input_lambda_failure_feedback_role_arn"></a> [lambda\_failure\_feedback\_role\_arn](#input\_lambda\_failure\_feedback\_role\_arn) | IAM role ARN for failed Lambda deliveries logging. If null, failure logging is disabled. | `string` | `null` | no |
| <a name="input_lambda_success_feedback_role_arn"></a> [lambda\_success\_feedback\_role\_arn](#input\_lambda\_success\_feedback\_role\_arn) | IAM role ARN for successful Lambda deliveries logging. If null, success logging is disabled. | `string` | `null` | no |
| <a name="input_lambda_success_feedback_sample_rate"></a> [lambda\_success\_feedback\_sample\_rate](#input\_lambda\_success\_feedback\_sample\_rate) | Percentage of successful Lambda deliveries to log (0-100). Only used when lambda\_success\_feedback\_role\_arn is set. | `number` | `null` | no |
| <a name="input_signature_version"></a> [signature\_version](#input\_signature\_version) | The signature version corresponds to the hashing algorithm used while creating the signature of the notifications.<br/><br/>Valid values:<br/>- 1: Uses SHA1 (legacy, not recommended for new topics)<br/>- 2: Uses SHA256 (recommended for all new topics)<br/><br/>Default: Uses AWS default (currently 1 for backward compatibility, but 2 is recommended) | `number` | `null` | no |
| <a name="input_sqs_failure_feedback_role_arn"></a> [sqs\_failure\_feedback\_role\_arn](#input\_sqs\_failure\_feedback\_role\_arn) | IAM role ARN for failed SQS deliveries logging. If null, failure logging is disabled. | `string` | `null` | no |
| <a name="input_sqs_success_feedback_role_arn"></a> [sqs\_success\_feedback\_role\_arn](#input\_sqs\_success\_feedback\_role\_arn) | IAM role ARN for successful SQS deliveries logging. If null, success logging is disabled. | `string` | `null` | no |
| <a name="input_sqs_success_feedback_sample_rate"></a> [sqs\_success\_feedback\_sample\_rate](#input\_sqs\_success\_feedback\_sample\_rate) | Percentage of successful SQS deliveries to log (0-100). Only used when sqs\_success\_feedback\_role\_arn is set. | `number` | `null` | no |
| <a name="input_subscriptions"></a> [subscriptions](#input\_subscriptions) | List of subscriptions to create for this topic. Each subscription delivers messages to a specific endpoint.<br/><br/>Supported protocols:<br/>- http, https: HTTP/HTTPS endpoints<br/>- email, email-json: Email addresses (requires confirmation)<br/>- sms: Phone numbers<br/>- sqs: SQS queue ARNs<br/>- lambda: Lambda function ARNs<br/>- firehose: Kinesis Data Firehose ARNs<br/>- application: Mobile push notifications<br/><br/>Each subscription object can include:<br/>- protocol (required): The protocol to use<br/>- endpoint (required): The endpoint to send messages to<br/>- endpoint\_auto\_confirms: Whether endpoint auto-confirms subscription<br/>- confirmation\_timeout\_in\_minutes: Confirmation timeout (1-1440 minutes)<br/>- filter\_policy: Message filtering policy<br/>- filter\_policy\_scope: Scope of filter policy (MessageAttributes or MessageBody)<br/>- raw\_message\_delivery: Enable raw message delivery (true/false)<br/>- redrive\_policy: Dead letter queue policy<br/>- delivery\_policy: Custom delivery policy for this subscription<br/>- subscription\_role\_arn: IAM role for Firehose subscriptions<br/>- replay\_policy: Message replay policy<br/><br/>Example:<br/>[<br/>  {<br/>    protocol = "sqs"<br/>    endpoint = "arn:aws:sqs:us-east-1:123456789012:my-queue"<br/>    raw\_message\_delivery = true<br/>  },<br/>  {<br/>    protocol = "lambda"<br/>    endpoint = "arn:aws:lambda:us-east-1:123456789012:function:my-function"<br/>  }<br/>] | `list(any)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. Use this to add consistent tagging across your infrastructure. | `map(string)` | `{}` | no |
| <a name="input_topic_name"></a> [topic\_name](#input\_topic\_name) | Name of the SNS topic.<br/>- For standard topics: Can be any valid topic name<br/>- For FIFO topics: Can optionally end with .fifo suffix (automatically added if missing when fifo\_topic = true)<br/>Must be unique within the AWS account and region. | `string` | n/a | yes |
| <a name="input_topic_policy"></a> [topic\_policy](#input\_topic\_policy) | The JSON policy document for the SNS topic.<br/>Use this to grant permissions to other AWS services or accounts to publish to the topic.<br/><br/>Example: Allow S3 bucket to send notifications<br/>Example: Allow cross-account access<br/>Example: Restrict to VPC endpoints<br/><br/>If null, no topic policy is attached (only IAM-based access control applies). | `string` | `null` | no |
| <a name="input_tracing_config"></a> [tracing\_config](#input\_tracing\_config) | Tracing mode for AWS X-Ray integration.<br/><br/>Valid values:<br/>- PassThrough: Only traces messages that have tracing enabled<br/>- Active: Traces all messages<br/><br/>If null, X-Ray tracing is disabled (default). | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_failure_feedback_role_arn"></a> [application\_failure\_feedback\_role\_arn](#output\_application\_failure\_feedback\_role\_arn) | The IAM role ARN for Application failure feedback. Returns null if not configured. |
| <a name="output_application_success_feedback_role_arn"></a> [application\_success\_feedback\_role\_arn](#output\_application\_success\_feedback\_role\_arn) | The IAM role ARN for Application success feedback. Returns null if not configured. |
| <a name="output_content_based_deduplication"></a> [content\_based\_deduplication](#output\_content\_based\_deduplication) | Whether content-based deduplication is enabled for the FIFO topic. |
| <a name="output_data_protection_policy_enabled"></a> [data\_protection\_policy\_enabled](#output\_data\_protection\_policy\_enabled) | Whether data protection policy is enabled for this topic. |
| <a name="output_firehose_failure_feedback_role_arn"></a> [firehose\_failure\_feedback\_role\_arn](#output\_firehose\_failure\_feedback\_role\_arn) | The IAM role ARN for Firehose failure feedback. Returns null if not configured. |
| <a name="output_firehose_success_feedback_role_arn"></a> [firehose\_success\_feedback\_role\_arn](#output\_firehose\_success\_feedback\_role\_arn) | The IAM role ARN for Firehose success feedback. Returns null if not configured. |
| <a name="output_http_failure_feedback_role_arn"></a> [http\_failure\_feedback\_role\_arn](#output\_http\_failure\_feedback\_role\_arn) | The IAM role ARN for HTTP failure feedback. Returns null if not configured. |
| <a name="output_http_success_feedback_role_arn"></a> [http\_success\_feedback\_role\_arn](#output\_http\_success\_feedback\_role\_arn) | The IAM role ARN for HTTP success feedback. Returns null if not configured. |
| <a name="output_kms_master_key_id"></a> [kms\_master\_key\_id](#output\_kms\_master\_key\_id) | The ID or ARN of the KMS key used for encryption. Returns null if encryption is not enabled. |
| <a name="output_lambda_failure_feedback_role_arn"></a> [lambda\_failure\_feedback\_role\_arn](#output\_lambda\_failure\_feedback\_role\_arn) | The IAM role ARN for Lambda failure feedback. Returns null if not configured. |
| <a name="output_lambda_success_feedback_role_arn"></a> [lambda\_success\_feedback\_role\_arn](#output\_lambda\_success\_feedback\_role\_arn) | The IAM role ARN for Lambda success feedback. Returns null if not configured. |
| <a name="output_signature_version"></a> [signature\_version](#output\_signature\_version) | The signature version used for message signing. |
| <a name="output_sqs_failure_feedback_role_arn"></a> [sqs\_failure\_feedback\_role\_arn](#output\_sqs\_failure\_feedback\_role\_arn) | The IAM role ARN for SQS failure feedback. Returns null if not configured. |
| <a name="output_sqs_success_feedback_role_arn"></a> [sqs\_success\_feedback\_role\_arn](#output\_sqs\_success\_feedback\_role\_arn) | The IAM role ARN for SQS success feedback. Returns null if not configured. |
| <a name="output_subscription_arns"></a> [subscription\_arns](#output\_subscription\_arns) | Map of subscription ARNs indexed by their position in the subscriptions list. |
| <a name="output_subscription_count"></a> [subscription\_count](#output\_subscription\_count) | The number of subscriptions created for this topic. |
| <a name="output_subscription_ids"></a> [subscription\_ids](#output\_subscription\_ids) | Map of subscription IDs indexed by their position in the subscriptions list. |
| <a name="output_tags"></a> [tags](#output\_tags) | All tags applied to the topic, including default and custom tags. |
| <a name="output_topic_arn"></a> [topic\_arn](#output\_topic\_arn) | The ARN of the SNS topic. Use this for IAM policies, event source mappings, and cross-service integrations. |
| <a name="output_topic_display_name"></a> [topic\_display\_name](#output\_topic\_display\_name) | The display name of the SNS topic. |
| <a name="output_topic_fifo"></a> [topic\_fifo](#output\_topic\_fifo) | Whether the topic is a FIFO topic (true) or standard topic (false). |
| <a name="output_topic_id"></a> [topic\_id](#output\_topic\_id) | The ID of the SNS topic. Same as the ARN. |
| <a name="output_topic_name"></a> [topic\_name](#output\_topic\_name) | The name of the SNS topic (including .fifo suffix for FIFO topics). |
| <a name="output_topic_owner"></a> [topic\_owner](#output\_topic\_owner) | The AWS account ID of the topic owner. |
| <a name="output_topic_policy_id"></a> [topic\_policy\_id](#output\_topic\_policy\_id) | The ID of the topic policy resource. Returns null if no policy is attached. |
| <a name="output_tracing_config"></a> [tracing\_config](#output\_tracing\_config) | The tracing configuration for AWS X-Ray. Returns null if tracing is not enabled. |
<!-- END_TF_DOCS -->
</details>
