# EventBridge Module

Production-ready Terraform module for creating and managing AWS EventBridge (CloudWatch Events) with comprehensive features for event-driven architectures.

## Features

- **Event Bus Management**: Support for both default and custom event buses
- **Multiple Rule Types**: Scheduled rules (cron/rate expressions) and event pattern matching
- **Rich Target Support**: Lambda, SQS, SNS, Step Functions, Kinesis, ECS, CloudWatch Logs, Batch
- **Input Transformation**: JSONPath-based input transformation and template support
- **Reliability**: Dead letter queue and retry policy configuration
- **Cross-Account**: Built-in support for cross-account event delivery
- **Auto IAM**: Automatic IAM role creation with least-privilege permissions based on target types
- **Multi-Target**: Support for up to 5 targets per rule (AWS limit)
- **Security**: Fine-grained access control with event bus policies

## Rule Types

### Scheduled Rules

Use `schedule_expression` with rate() or cron() expressions:

**Rate expressions:**
- `rate(5 minutes)` - Every 5 minutes
- `rate(1 hour)` - Every hour
- `rate(1 day)` - Every day

**Cron expressions (UTC timezone):**
- `cron(0 12 * * ? *)` - Daily at noon
- `cron(0 9 ? * MON-FRI *)` - Weekdays at 9 AM
- `cron(0 0 1 * ? *)` - First day of month at midnight
- `cron(0/15 * * * ? *)` - Every 15 minutes

### Event Pattern Rules

Use `event_pattern` with JSON matching patterns for AWS service or custom application events.

## Usage

### Basic Scheduled Rule

```hcl
module "eventbridge" {
  source = "github.com/llamandcoco/infra-modules//terraform/eventbridge"

  # Use default event bus
  event_bus_name  = "default"
  create_event_bus = false

  # Scheduled rule - every 5 minutes
  rule_name           = "lambda-trigger"
  rule_description    = "Trigger Lambda every 5 minutes"
  schedule_expression = "rate(5 minutes)"

  # Lambda target
  targets = [
    {
      target_id = "lambda"
      arn       = "arn:aws:lambda:us-east-1:123456789012:function:my-function"
    }
  ]

  # Auto-create IAM role
  create_role = true

  tags = {
    Environment = "production"
  }
}
```

### Cron Schedule with Multiple Targets

```hcl
module "eventbridge" {
  source = "github.com/llamandcoco/infra-modules//terraform/eventbridge"

  event_bus_name      = "default"
  rule_name           = "daily-report"
  rule_description    = "Generate daily report at noon UTC"
  schedule_expression = "cron(0 12 * * ? *)"

  # Multiple targets: Lambda + SQS
  targets = [
    {
      target_id = "report-lambda"
      arn       = "arn:aws:lambda:us-east-1:123456789012:function:generate-report"

      # Static input
      input = jsonencode({
        report_type = "daily"
        format      = "pdf"
      })
    },
    {
      target_id = "notification-queue"
      arn       = "arn:aws:sqs:us-east-1:123456789012:my-queue"
    }
  ]

  create_role = true

  tags = {
    Environment = "production"
  }
}
```

### Event Pattern - EC2 State Changes

```hcl
module "eventbridge" {
  source = "github.com/llamandcoco/infra-modules//terraform/eventbridge"

  event_bus_name   = "default"
  rule_name        = "ec2-state-change"
  rule_description = "React to EC2 instance state changes"

  # Event pattern matching
  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
    detail = {
      state = ["running", "stopped"]
    }
  })

  targets = [
    {
      target_id = "lambda-processor"
      arn       = "arn:aws:lambda:us-east-1:123456789012:function:ec2-handler"
    }
  ]

  create_role = true

  tags = {
    Environment = "production"
  }
}
```

### Input Transformation

```hcl
module "eventbridge" {
  source = "github.com/llamandcoco/infra-modules//terraform/eventbridge"

  event_bus_name = "default"
  rule_name      = "s3-object-created"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
  })

  targets = [
    {
      target_id = "lambda"
      arn       = "arn:aws:lambda:us-east-1:123456789012:function:s3-processor"

      # Transform input using JSONPath
      input_transformer = {
        input_paths_map = {
          bucket = "$.detail.bucket.name"
          key    = "$.detail.object.key"
          size   = "$.detail.object.size"
          time   = "$.time"
        }

        input_template = jsonencode({
          s3_event = {
            bucket_name = "<bucket>"
            object_key  = "<key>"
            object_size = "<size>"
            timestamp   = "<time>"
          }
          action = "process_new_object"
        })
      }
    }
  ]

  create_role = true

  tags = {
    Environment = "production"
  }
}
```

### Dead Letter Queue and Retry Policy

```hcl
module "eventbridge" {
  source = "github.com/llamandcoco/infra-modules//terraform/eventbridge"

  event_bus_name      = "default"
  rule_name           = "critical-events"
  schedule_expression = "rate(1 hour)"

  targets = [
    {
      target_id = "lambda"
      arn       = "arn:aws:lambda:us-east-1:123456789012:function:critical-processor"

      # Retry configuration
      retry_policy = {
        maximum_retry_attempts       = 3
        maximum_event_age_in_seconds = 3600 # 1 hour
      }

      # Dead letter queue for failed invocations
      dead_letter_config = {
        arn = "arn:aws:sqs:us-east-1:123456789012:eventbridge-dlq"
      }
    }
  ]

  create_role = true

  tags = {
    Environment = "production"
  }
}
```

### ECS Task Target

```hcl
module "eventbridge" {
  source = "github.com/llamandcoco/infra-modules//terraform/eventbridge"

  event_bus_name      = "default"
  rule_name           = "ecs-task-trigger"
  schedule_expression = "rate(1 hour)"

  targets = [
    {
      target_id = "ecs-task"
      arn       = "arn:aws:ecs:us-east-1:123456789012:cluster/my-cluster"

      # ECS-specific parameters
      ecs_parameters = {
        task_definition_arn = "arn:aws:ecs:us-east-1:123456789012:task-definition/my-task:1"
        task_count          = 1
        launch_type         = "FARGATE"

        network_configuration = {
          subnets          = ["subnet-12345678"]
          security_groups  = ["sg-12345678"]
          assign_public_ip = true
        }
      }
    }
  ]

  create_role = true

  tags = {
    Environment = "production"
  }
}
```

### Cross-Account Event Bus (Receiver)

```hcl
module "eventbridge_receiver" {
  source = "github.com/llamandcoco/infra-modules//terraform/eventbridge"

  # Create custom event bus
  event_bus_name   = "cross-account-events"
  create_event_bus = true

  rule_name     = "cross-account-rule"
  event_pattern = jsonencode({
    source = ["custom.application"]
  })

  targets = [
    {
      target_id = "lambda-processor"
      arn       = "arn:aws:lambda:us-east-1:999888777666:function:process-events"
    }
  ]

  # Allow specific AWS accounts to send events
  allow_account_ids = [
    "111122223333", # Dev account
    "444455556666"  # Prod account
  ]

  create_role = true

  tags = {
    Environment = "production"
  }
}
```

### Custom Application Events

```hcl
module "eventbridge" {
  source = "github.com/llamandcoco/infra-modules//terraform/eventbridge"

  event_bus_name = "default"
  rule_name      = "custom-app-orders"

  # Match custom application events
  event_pattern = jsonencode({
    source      = ["custom.orders"]
    detail-type = ["Order Placed"]
    detail = {
      order_status = ["confirmed"]
      order_total = {
        numeric = [">", 100] # Orders over $100
      }
    }
  })

  targets = [
    {
      target_id = "order-processor"
      arn       = "arn:aws:lambda:us-east-1:123456789012:function:process-order"

      input_transformer = {
        input_paths_map = {
          order_id    = "$.detail.order_id"
          customer_id = "$.detail.customer_id"
          total       = "$.detail.order_total"
        }

        input_template = jsonencode({
          order_id    = "<order_id>"
          customer_id = "<customer_id>"
          total       = "<total>"
          priority    = "high"
        })
      }
    }
  ]

  create_role = true

  tags = {
    Environment = "production"
  }
}
```

### SQS FIFO Queue Target

```hcl
module "eventbridge" {
  source = "github.com/llamandcoco/infra-modules//terraform/eventbridge"

  event_bus_name      = "default"
  rule_name           = "fifo-queue-events"
  schedule_expression = "rate(5 minutes)"

  targets = [
    {
      target_id = "sqs-fifo"
      arn       = "arn:aws:sqs:us-east-1:123456789012:my-queue.fifo"

      # SQS FIFO parameters
      sqs_parameters = {
        message_group_id = "event-group-1"
      }
    }
  ]

  create_role = true

  tags = {
    Environment = "production"
  }
}
```

### Step Functions Target

```hcl
module "eventbridge" {
  source = "github.com/llamandcoco/infra-modules//terraform/eventbridge"

  event_bus_name      = "default"
  rule_name           = "workflow-trigger"
  schedule_expression = "rate(1 hour)"

  targets = [
    {
      target_id = "stepfunctions"
      arn       = "arn:aws:states:us-east-1:123456789012:stateMachine:my-workflow"

      # Use input_path to send only part of the event
      input_path = "$.detail"

      retry_policy = {
        maximum_retry_attempts       = 2
        maximum_event_age_in_seconds = 7200 # 2 hours
      }
    }
  ]

  create_role = true

  tags = {
    Environment = "production"
  }
}
```

## Event Pattern Examples

### AWS Service Events

**EC2 Instance State Changes:**
```json
{
  "source": ["aws.ec2"],
  "detail-type": ["EC2 Instance State-change Notification"],
  "detail": {
    "state": ["running", "stopped", "terminated"]
  }
}
```

**S3 Object Created:**
```json
{
  "source": ["aws.s3"],
  "detail-type": ["Object Created"],
  "detail": {
    "bucket": {
      "name": ["my-bucket"]
    }
  }
}
```

**CloudTrail API Calls:**
```json
{
  "source": ["aws.cloudtrail"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventName": ["PutObject", "DeleteObject"],
    "eventSource": ["s3.amazonaws.com"]
  }
}
```

**Auto Scaling Events:**
```json
{
  "source": ["aws.autoscaling"],
  "detail-type": ["EC2 Instance Launch Successful"]
}
```

### Custom Application Events

```json
{
  "source": ["custom.myapp"],
  "detail-type": ["User Signup"],
  "detail": {
    "user_type": ["premium"],
    "country": ["US", "CA"]
  }
}
```

## Cross-Account Setup

### Receiver Account (Event Bus)

Create the custom event bus and allow sender accounts:

```hcl
module "eventbridge_receiver" {
  source = "github.com/llamandcoco/infra-modules//terraform/eventbridge"

  event_bus_name   = "shared-events"
  create_event_bus = true

  rule_name     = "shared-event-rule"
  event_pattern = jsonencode({
    source = ["custom.app"]
  })

  targets = [{
    target_id = "processor"
    arn       = "arn:aws:lambda:us-east-1:999888777666:function:process"
  }]

  # Allow sender accounts
  allow_account_ids = ["111122223333"]

  create_role = true
}
```

### Sender Account (Event Source)

In the sender account, create a rule that targets the receiver's event bus:

```hcl
# IAM role for EventBridge to put events cross-account
resource "aws_iam_role" "sender" {
  name = "eventbridge-cross-account-sender"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "events.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "sender" {
  name = "put-events-policy"
  role = aws_iam_role.sender.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "events:PutEvents"
      Resource = "arn:aws:events:us-east-1:999888777666:event-bus/shared-events"
    }]
  })
}

# Rule in sender account
resource "aws_cloudwatch_event_rule" "sender" {
  name          = "send-to-receiver"
  description   = "Send events to receiver account"
  event_pattern = jsonencode({
    source = ["custom.app"]
  })
}

# Target pointing to receiver's event bus
resource "aws_cloudwatch_event_target" "receiver_bus" {
  rule      = aws_cloudwatch_event_rule.sender.name
  target_id = "receiver-bus"
  arn       = "arn:aws:events:us-east-1:999888777666:event-bus/shared-events"
  role_arn  = aws_iam_role.sender.arn
}
```

## Target Types and IAM Permissions

The module automatically creates IAM roles with appropriate permissions based on target types:

| Target Type | Service | Auto-Generated IAM Permissions |
|-------------|---------|--------------------------------|
| Lambda | `lambda` | `lambda:InvokeFunction` |
| SQS | `sqs` | `sqs:SendMessage` |
| SNS | `sns` | `sns:Publish` |
| Step Functions | `states` | `states:StartExecution` |
| Kinesis | `kinesis` | `kinesis:PutRecord`, `kinesis:PutRecords` |
| ECS | `ecs` | `ecs:RunTask`, `iam:PassRole` |
| CloudWatch Logs | `logs` | `logs:CreateLogStream`, `logs:PutLogEvents` |
| Batch | `batch` | `batch:SubmitJob` |

## Important Limits

- **Maximum targets per rule**: 5 (AWS limit)
- **Maximum retry attempts**: 185
- **Event age range**: 60 seconds to 86400 seconds (1 minute to 24 hours)
- **Event bus name**: 1-256 characters
- **Rule name**: 1-64 characters

## Future Enhancements

The following features are planned for future releases:

- Event archive and replay
- Schema registry integration
- API destinations (HTTP endpoints)
- Customer-managed KMS encryption for event buses
- Advanced CloudWatch metrics and alarms

## Testing

See the `tests/` directory for complete examples:

- `tests/basic/` - Basic scheduled rule with Lambda target
- `tests/scheduled/` - Advanced cron/rate expressions with multiple targets
- `tests/pattern/` - Event pattern matching with input transformation
- `tests/cross_account/` - Cross-account event bus configuration

## Security Considerations

1. **IAM Roles**: The module creates least-privilege IAM roles automatically
2. **DLQ**: Configure dead letter queues for critical events
3. **Retry Policy**: Set appropriate retry attempts and event age limits
4. **Cross-Account**: Use explicit account ID allowlists
5. **Event Patterns**: Validate JSON syntax at plan time
6. **Encryption**: Custom event buses use AWS-managed encryption by default

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

<!-- BEGIN_TF_DOCS -->
<!-- This section will be automatically generated by terraform-docs -->
<!-- END_TF_DOCS -->

## License

Apache 2.0 Licensed. See LICENSE for full details.
