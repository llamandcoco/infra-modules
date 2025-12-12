# -----------------------------------------------------------------------------
# Scheduled EventBridge Module Test
# This example demonstrates:
# - Creating a custom event bus
# - Using cron expressions for scheduled rules
# - Multiple targets (Lambda + SQS)
# - Static input transformation
# - Custom IAM role name
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  endpoints {
    events = "http://localhost:4566"
    iam    = "http://localhost:4566"
    lambda = "http://localhost:4566"
    sqs    = "http://localhost:4566"
  }
}

# -----------------------------------------------------------------------------
# Mock Resources
# -----------------------------------------------------------------------------

# Lambda function for processing scheduled events
resource "aws_lambda_function" "processor" {
  function_name = "scheduled-event-processor"
  role          = "arn:aws:iam::123456789012:role/lambda-role"
  handler       = "index.handler"
  runtime       = "python3.11"
  filename      = "lambda.zip"

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }
}

# SQS queue for event buffering
# tfsec:ignore:AVD-AWS-0096 - Test resource, encryption not required
resource "aws_sqs_queue" "events" {
  name                      = "scheduled-events-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  tags = {
    Environment = "test"
  }
}

# -----------------------------------------------------------------------------
# EventBridge Module - Scheduled with Cron Expression
# Triggers daily at noon UTC (12:00 PM)
# -----------------------------------------------------------------------------

module "eventbridge_daily" {
  source = "../.."

  caller_identity_override = {
    account_id = "123456789012"
    arn        = "arn:aws:iam::123456789012:user/mock"
    user_id    = "AIDAMOCK"
  }

  # Create custom event bus for scheduled events
  event_bus_name   = "scheduled-events-bus"
  create_event_bus = true

  # Cron expression: Daily at noon UTC
  # Format: cron(minutes hours day-of-month month day-of-week year)
  rule_name           = "daily-noon-trigger"
  rule_description    = "Triggers Lambda and SQS daily at noon UTC"
  schedule_expression = "cron(0 12 * * ? *)"
  is_enabled          = true

  # Multiple targets: Lambda + SQS
  targets = [
    {
      target_id = "lambda-processor"
      arn       = aws_lambda_function.processor.arn

      # Static JSON input to Lambda
      input = jsonencode({
        event_type = "daily_report"
        timestamp  = "scheduled"
        config = {
          report_format   = "json"
          include_metrics = true
        }
      })
    },
    {
      target_id = "sqs-buffer"
      arn       = aws_sqs_queue.events.arn

      # Different input for SQS
      input = jsonencode({
        event_source = "eventbridge-scheduler"
        trigger_type = "daily_cron"
      })
    }
  ]

  # Auto-create IAM role with custom name
  create_role      = true
  role_name        = "eventbridge-daily-scheduler-role"
  role_description = "Allows EventBridge to invoke Lambda and send messages to SQS for daily scheduled events"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Schedule    = "daily"
    Example     = "scheduled-cron"
  }
}

# -----------------------------------------------------------------------------
# EventBridge Module - Scheduled with Rate Expression
# Triggers every 15 minutes
# -----------------------------------------------------------------------------

module "eventbridge_frequent" {
  source = "../.."

  caller_identity_override = {
    account_id = "123456789012"
    arn        = "arn:aws:iam::123456789012:user/mock"
    user_id    = "AIDAMOCK"
  }

  # Use default event bus for frequent events
  event_bus_name   = "default"
  create_event_bus = false

  # Rate expression: Every 15 minutes
  rule_name           = "frequent-trigger"
  rule_description    = "Triggers Lambda every 15 minutes for health checks"
  schedule_expression = "rate(15 minutes)"
  is_enabled          = true

  # Single Lambda target
  targets = [
    {
      target_id = "health-check-lambda"
      arn       = aws_lambda_function.processor.arn

      input = jsonencode({
        event_type = "health_check"
        frequency  = "15_minutes"
      })
    }
  ]

  create_role = true

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Schedule    = "frequent"
    Example     = "scheduled-rate"
  }
}

# -----------------------------------------------------------------------------
# EventBridge Module - Weekday Morning Trigger
# Triggers Monday-Friday at 9 AM UTC
# -----------------------------------------------------------------------------

module "eventbridge_weekday" {
  source = "../.."

  caller_identity_override = {
    account_id = "123456789012"
    arn        = "arn:aws:iam::123456789012:user/mock"
    user_id    = "AIDAMOCK"
  }

  event_bus_name   = "default"
  create_event_bus = false

  # Cron expression: Weekdays at 9 AM UTC
  # cron(minutes hours day-of-month month day-of-week year)
  # ? means "no specific value" for day-of-month
  # MON-FRI means Monday through Friday
  rule_name           = "weekday-morning-trigger"
  rule_description    = "Triggers Lambda on weekday mornings at 9 AM UTC"
  schedule_expression = "cron(0 9 ? * MON-FRI *)"
  is_enabled          = true

  targets = [
    {
      target_id = "weekday-lambda"
      arn       = aws_lambda_function.processor.arn

      input = jsonencode({
        event_type     = "weekday_morning"
        business_hours = true
      })
    }
  ]

  create_role = true

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Schedule    = "weekday"
    Example     = "scheduled-weekday"
  }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "daily_rule_arn" {
  description = "ARN of the daily scheduled rule"
  value       = module.eventbridge_daily.rule_arn
}

output "daily_event_bus_name" {
  description = "Name of the custom event bus"
  value       = module.eventbridge_daily.event_bus_name
}

output "frequent_rule_arn" {
  description = "ARN of the frequent scheduled rule"
  value       = module.eventbridge_frequent.rule_arn
}

output "weekday_rule_arn" {
  description = "ARN of the weekday scheduled rule"
  value       = module.eventbridge_weekday.rule_arn
}

output "daily_role_arn" {
  description = "ARN of the IAM role for daily scheduler"
  value       = module.eventbridge_daily.role_arn
}
