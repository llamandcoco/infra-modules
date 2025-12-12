# -----------------------------------------------------------------------------
# Cross-Account EventBridge Module Test
# This example demonstrates:
# - Creating a custom event bus with cross-account policy
# - Allowing specific AWS accounts to send events
# - Event pattern matching for cross-account events
# - Fan-out pattern (one event to multiple targets)
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

# -----------------------------------------------------------------------------
# Provider Configuration
# This represents the RECEIVER account (where the custom event bus lives)
# -----------------------------------------------------------------------------

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
    sns    = "http://localhost:4566"
  }
}

# -----------------------------------------------------------------------------
# Mock Resources in Receiver Account
# -----------------------------------------------------------------------------

# Lambda function to process cross-account events
resource "aws_lambda_function" "cross_account_processor" {
  function_name = "cross-account-event-processor"
  role          = "arn:aws:iam::999888777666:role/lambda-role"
  handler       = "index.handler"
  runtime       = "python3.11"
  filename      = "lambda.zip"

  environment {
    variables = {
      EVENT_SOURCE = "cross_account"
    }
  }
}

# SQS queue for event buffering
# tfsec:ignore:AVD-AWS-0096 - Test resource, encryption not required
resource "aws_sqs_queue" "cross_account_events" {
  name                      = "cross-account-events-queue"
  message_retention_seconds = 345600 # 4 days

  tags = {
    Purpose = "Cross-account event processing"
  }
}

# SNS topic for alerting
# tfsec:ignore:AVD-AWS-0095 - Test resource, encryption not required
resource "aws_sns_topic" "cross_account_alerts" {
  name = "cross-account-alerts"
}

# -----------------------------------------------------------------------------
# EventBridge Module - Cross-Account Event Bus (Receiver Side)
# This creates a custom event bus that accepts events from other AWS accounts
# -----------------------------------------------------------------------------

module "eventbridge_receiver" {
  source = "../.."

  # Create custom event bus for cross-account events
  event_bus_name   = "cross-account-events-bus"
  create_event_bus = true

  rule_name        = "cross-account-event-rule"
  rule_description = "Processes events from allowed AWS accounts"
  is_enabled       = true

  # Event pattern: Match events from specific source accounts
  # This pattern can match any events sent from the allowed accounts
  event_pattern = jsonencode({
    source = ["custom.application", "aws.ec2", "aws.s3"]
    # Optionally filter by detail-type or other fields
    # detail-type = ["Custom Event"]
  })

  # Fan-out pattern: Send to multiple targets
  targets = [
    {
      target_id = "lambda-processor"
      arn       = aws_lambda_function.cross_account_processor.arn

      input_transformer = {
        input_paths_map = {
          source      = "$.source"
          detail_type = "$.detail-type"
          account     = "$.account"
          region      = "$.region"
          time        = "$.time"
        }

        input_template = jsonencode({
          message = "Received event from account <account> in region <region>"
          event_metadata = {
            source      = "<source>"
            detail_type = "<detail_type>"
            account     = "<account>"
            region      = "<region>"
            timestamp   = "<time>"
          }
        })
      }

      retry_policy = {
        maximum_retry_attempts       = 3
        maximum_event_age_in_seconds = 3600
      }
    },
    {
      target_id = "sqs-buffer"
      arn       = aws_sqs_queue.cross_account_events.arn
    },
    {
      target_id = "sns-alerts"
      arn       = aws_sns_topic.cross_account_alerts.arn

      input = jsonencode({
        alert_type = "cross_account_event"
        message    = "New cross-account event received"
      })
    }
  ]

  # Allow specific AWS accounts to send events to this bus
  # Replace with actual AWS account IDs in production
  allow_account_ids = [
    "111122223333", # Development account
    "444455556666", # Production account
    "777788889999"  # Partner account
  ]

  create_role = true
  role_name   = "eventbridge-cross-account-role"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    EventType   = "cross-account"
    Example     = "receiver"
  }
}

# -----------------------------------------------------------------------------
# EventBridge Module - Alternative: Custom Policy for Advanced Scenarios
# This example shows how to use a custom policy statement instead of
# allow_account_ids for more complex cross-account scenarios
# -----------------------------------------------------------------------------

module "eventbridge_receiver_custom_policy" {
  source = "../.."

  event_bus_name   = "cross-account-custom-policy-bus"
  create_event_bus = true

  rule_name        = "custom-policy-rule"
  rule_description = "Uses custom event bus policy for fine-grained access control"
  is_enabled       = true

  event_pattern = jsonencode({
    source = ["custom.application"]
  })

  targets = [
    {
      target_id = "custom-lambda"
      arn       = aws_lambda_function.cross_account_processor.arn
    }
  ]

  # Custom policy: Allow specific accounts with conditions
  event_bus_policy_statement = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSpecificAccountsWithCondition"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::111122223333:root",
            "arn:aws:iam::444455556666:root"
          ]
        }
        Action   = "events:PutEvents"
        Resource = "arn:aws:events:us-east-1:999888777666:event-bus/cross-account-custom-policy-bus"
        Condition = {
          StringEquals = {
            "events:source" = ["custom.application"]
          }
        }
      }
    ]
  })

  create_role = true

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    EventType   = "cross-account-custom"
    Example     = "receiver-custom-policy"
  }
}

# -----------------------------------------------------------------------------
# Documentation: Sender Account Configuration
# -----------------------------------------------------------------------------

# NOTE: In the SENDER account (accounts 111122223333, 444455556666, etc.),
# you would configure EventBridge to send events to the receiver's custom bus:
#
# resource "aws_cloudwatch_event_rule" "sender" {
#   name           = "send-to-receiver-account"
#   description    = "Send events to receiver account event bus"
#   event_pattern  = jsonencode({
#     source = ["custom.application"]
#   })
# }
#
# resource "aws_cloudwatch_event_target" "cross_account_bus" {
#   rule      = aws_cloudwatch_event_rule.sender.name
#   target_id = "receiver-event-bus"
#   arn       = "arn:aws:events:us-east-1:999888777666:event-bus/cross-account-events-bus"
#
#   # Note: You need an IAM role in the sender account with permission to
#   # put events to the receiver's event bus
#   role_arn  = aws_iam_role.sender_role.arn
# }
#
# resource "aws_iam_role" "sender_role" {
#   name = "eventbridge-cross-account-sender"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Service = "events.amazonaws.com"
#       }
#       Action = "sts:AssumeRole"
#     }]
#   })
# }
#
# resource "aws_iam_role_policy" "sender_policy" {
#   name = "put-events-to-receiver"
#   role = aws_iam_role.sender_role.id
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Action = "events:PutEvents"
#       Resource = "arn:aws:events:us-east-1:999888777666:event-bus/cross-account-events-bus"
#     }]
#   })
# }

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "event_bus_arn" {
  description = "ARN of the cross-account event bus (receiver side)"
  value       = module.eventbridge_receiver.event_bus_arn
}

output "event_bus_name" {
  description = "Name of the cross-account event bus"
  value       = module.eventbridge_receiver.event_bus_name
}

output "rule_arn" {
  description = "ARN of the cross-account event rule"
  value       = module.eventbridge_receiver.rule_arn
}

output "role_arn" {
  description = "ARN of the IAM role for processing cross-account events"
  value       = module.eventbridge_receiver.role_arn
}

output "allowed_account_ids" {
  description = "AWS account IDs allowed to send events to this bus"
  value       = ["111122223333", "444455556666", "777788889999"]
}

output "custom_policy_bus_arn" {
  description = "ARN of the custom policy event bus"
  value       = module.eventbridge_receiver_custom_policy.event_bus_arn
}

output "sender_configuration_guide" {
  description = "Guide for configuring the sender account"
  value       = <<-EOT
    To send events from another account to this event bus:

    1. In the sender account, create an EventBridge rule with a target pointing to:
       ARN: ${module.eventbridge_receiver.event_bus_arn}

    2. Create an IAM role in the sender account with this policy:
       {
         "Version": "2012-10-17",
         "Statement": [{
           "Effect": "Allow",
           "Action": "events:PutEvents",
           "Resource": "${module.eventbridge_receiver.event_bus_arn}"
         }]
       }

    3. Ensure the sender account ID is in the allowed list:
       ${jsonencode(["111122223333", "444455556666", "777788889999"])}
  EOT
}
