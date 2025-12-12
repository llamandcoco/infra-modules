# -----------------------------------------------------------------------------
# Event Pattern EventBridge Module Test
# This example demonstrates:
# - Event pattern matching (EC2 state changes)
# - Input transformation using JSONPath
# - Dead letter queue configuration
# - Retry policy configuration
# - Multiple AWS service targets (Lambda, SNS, Step Functions)
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
    events        = "http://localhost:4566"
    iam           = "http://localhost:4566"
    lambda        = "http://localhost:4566"
    sns           = "http://localhost:4566"
    sqs           = "http://localhost:4566"
    stepfunctions = "http://localhost:4566"
  }
}

# -----------------------------------------------------------------------------
# Mock Resources
# -----------------------------------------------------------------------------

# Lambda function to process EC2 state changes
resource "aws_lambda_function" "ec2_processor" {
  function_name = "ec2-state-change-processor"
  role          = "arn:aws:iam::123456789012:role/lambda-role"
  handler       = "index.handler"
  runtime       = "python3.11"
  filename      = "lambda.zip"
}

# SNS topic for notifications
# tfsec:ignore:AVD-AWS-0095 - Test resource, encryption not required
resource "aws_sns_topic" "alerts" {
  name = "ec2-state-change-alerts"
}

# Step Functions state machine for workflow orchestration
resource "aws_sfn_state_machine" "workflow" {
  name     = "ec2-workflow"
  role_arn = "arn:aws:iam::123456789012:role/stepfunctions-role"

  definition = jsonencode({
    Comment = "EC2 state change workflow"
    StartAt = "ProcessEvent"
    States = {
      ProcessEvent = {
        Type = "Pass"
        End  = true
      }
    }
  })
}

# Dead letter queue for failed invocations
# tfsec:ignore:AVD-AWS-0096 - Test resource, encryption not required
resource "aws_sqs_queue" "dlq" {
  name                      = "eventbridge-dlq"
  message_retention_seconds = 1209600 # 14 days

  tags = {
    Purpose = "DLQ for failed EventBridge invocations"
  }
}

# -----------------------------------------------------------------------------
# EventBridge Module - EC2 State Change Pattern
# Matches EC2 instances transitioning to "running" state
# -----------------------------------------------------------------------------

module "eventbridge_ec2_running" {
  source = "../.."

  caller_identity_override = {
    account_id = "123456789012"
    arn        = "arn:aws:iam::123456789012:user/mock"
    user_id    = "AIDAMOCK"
  }

  # Use default event bus (receives AWS service events)
  event_bus_name   = "default"
  create_event_bus = false

  rule_name        = "ec2-running-state"
  rule_description = "Triggers when EC2 instances transition to running state"
  is_enabled       = true

  # Event pattern: Match EC2 instances starting
  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
    detail = {
      state = ["running"]
    }
  })

  # Multiple targets with different input transformations
  targets = [
    {
      target_id = "lambda-processor"
      arn       = aws_lambda_function.ec2_processor.arn

      # Input transformer: Extract specific fields from the event
      input_transformer = {
        # Map event fields to variables
        input_paths_map = {
          instance_id = "$.detail.instance-id"
          state       = "$.detail.state"
          time        = "$.time"
          region      = "$.region"
          account     = "$.account"
        }

        # Template: Construct custom input using extracted fields
        input_template = jsonencode({
          message = "EC2 instance <instance_id> is now <state>"
          metadata = {
            instance_id = "<instance_id>"
            state       = "<state>"
            timestamp   = "<time>"
            aws_region  = "<region>"
            aws_account = "<account>"
          }
          action = "process_running_instance"
        })
      }

      # Retry configuration for Lambda failures
      retry_policy = {
        maximum_retry_attempts       = 3
        maximum_event_age_in_seconds = 3600 # 1 hour
      }

      # Dead letter queue for failed invocations
      dead_letter_config = {
        arn = aws_sqs_queue.dlq.arn
      }
    },
    {
      target_id = "sns-notification"
      arn       = aws_sns_topic.alerts.arn

      # Static input with event details
      input = jsonencode({
        alert_type = "ec2_state_change"
        severity   = "info"
        message    = "EC2 instance started"
      })
    },
    {
      target_id = "stepfunctions-workflow"
      arn       = aws_sfn_state_machine.workflow.arn

      # Use input_path to send only specific part of the event
      input_path = "$.detail"

      retry_policy = {
        maximum_retry_attempts       = 2
        maximum_event_age_in_seconds = 7200 # 2 hours
      }
    }
  ]

  # Auto-create IAM role with permissions for Lambda, SNS, and Step Functions
  create_role = true
  role_name   = "eventbridge-ec2-pattern-role"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    EventType   = "ec2-state-change"
    Example     = "event-pattern"
  }
}

# -----------------------------------------------------------------------------
# EventBridge Module - S3 Object Created Pattern
# Matches S3 object creation events
# -----------------------------------------------------------------------------

module "eventbridge_s3_created" {
  source = "../.."

  caller_identity_override = {
    account_id = "123456789012"
    arn        = "arn:aws:iam::123456789012:user/mock"
    user_id    = "AIDAMOCK"
  }

  event_bus_name   = "default"
  create_event_bus = false

  rule_name        = "s3-object-created"
  rule_description = "Triggers when objects are created in S3 buckets"
  is_enabled       = true

  # Event pattern: Match S3 object creation
  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = {
        name = ["my-important-bucket"]
      }
    }
  })

  targets = [
    {
      target_id = "s3-lambda-processor"
      arn       = aws_lambda_function.ec2_processor.arn

      input_transformer = {
        input_paths_map = {
          bucket_name = "$.detail.bucket.name"
          object_key  = "$.detail.object.key"
          size        = "$.detail.object.size"
        }

        input_template = jsonencode({
          s3_event = {
            bucket = "<bucket_name>"
            key    = "<object_key>"
            size   = "<size>"
          }
          action = "process_new_object"
        })
      }

      retry_policy = {
        maximum_retry_attempts       = 5
        maximum_event_age_in_seconds = 21600 # 6 hours
      }

      dead_letter_config = {
        arn = aws_sqs_queue.dlq.arn
      }
    }
  ]

  create_role = true

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    EventType   = "s3-object-created"
    Example     = "event-pattern-s3"
  }
}

# -----------------------------------------------------------------------------
# EventBridge Module - Custom Application Events
# Matches events from custom applications
# -----------------------------------------------------------------------------

module "eventbridge_custom_app" {
  source = "../.."

  caller_identity_override = {
    account_id = "123456789012"
    arn        = "arn:aws:iam::123456789012:user/mock"
    user_id    = "AIDAMOCK"
  }

  event_bus_name   = "default"
  create_event_bus = false

  rule_name        = "custom-app-orders"
  rule_description = "Triggers on new orders from custom application"
  is_enabled       = true

  # Event pattern: Match custom application events
  event_pattern = jsonencode({
    source      = ["custom.orders"]
    detail-type = ["Order Placed"]
    detail = {
      order_status = ["pending", "confirmed"]
      order_total = {
        numeric = [">", 100] # Orders over $100
      }
    }
  })

  targets = [
    {
      target_id = "order-processor"
      arn       = aws_lambda_function.ec2_processor.arn

      input_transformer = {
        input_paths_map = {
          order_id     = "$.detail.order_id"
          customer_id  = "$.detail.customer_id"
          order_total  = "$.detail.order_total"
          order_status = "$.detail.order_status"
        }

        input_template = jsonencode({
          order = {
            id          = "<order_id>"
            customer_id = "<customer_id>"
            total       = "<order_total>"
            status      = "<order_status>"
          }
          processing_priority = "high"
        })
      }

      retry_policy = {
        maximum_retry_attempts       = 3
        maximum_event_age_in_seconds = 3600
      }

      dead_letter_config = {
        arn = aws_sqs_queue.dlq.arn
      }
    }
  ]

  create_role = true

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    EventType   = "custom-application"
    Example     = "event-pattern-custom"
  }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "ec2_rule_arn" {
  description = "ARN of the EC2 state change rule"
  value       = module.eventbridge_ec2_running.rule_arn
}

output "ec2_role_arn" {
  description = "ARN of the IAM role for EC2 events"
  value       = module.eventbridge_ec2_running.role_arn
}

output "s3_rule_arn" {
  description = "ARN of the S3 object created rule"
  value       = module.eventbridge_s3_created.rule_arn
}

output "custom_app_rule_arn" {
  description = "ARN of the custom application rule"
  value       = module.eventbridge_custom_app.rule_arn
}

output "dlq_arn" {
  description = "ARN of the dead letter queue"
  value       = aws_sqs_queue.dlq.arn
}
