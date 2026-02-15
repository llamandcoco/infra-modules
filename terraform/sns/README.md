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
cat tests/basic/

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
<!-- END_TF_DOCS -->
</details>
