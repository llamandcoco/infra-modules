# -----------------------------------------------------------------------------
# Event Source Mapping Test
# Tests Lambda function with SQS event source mapping
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  # Mock credentials for validation testing - no real AWS resources will be created
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  skip_region_validation      = true

  access_key = "mock_access_key"
  secret_key = "mock_secret_key"

  default_tags {
    tags = {
      Environment = "test"
      ManagedBy   = "terraform"
      Test        = "event-source-mapping"
    }
  }
}

# -----------------------------------------------------------------------------
# Test SQS Queue
# -----------------------------------------------------------------------------

resource "aws_sqs_queue" "test" {
  name                       = "lambda-test-event-source-${random_id.test.hex}"
  visibility_timeout_seconds = 35
  message_retention_seconds  = 86400
  sqs_managed_sse_enabled    = true

  tags = {
    Name = "lambda-test-event-source"
  }
}

resource "aws_sqs_queue" "test_dlq" {
  name                    = "lambda-test-event-source-dlq-${random_id.test.hex}"
  sqs_managed_sse_enabled = true

  tags = {
    Name = "lambda-test-event-source-dlq"
  }
}

resource "random_id" "test" {
  byte_length = 4
}

# -----------------------------------------------------------------------------
# Test Lambda Function with Event Source Mapping
# -----------------------------------------------------------------------------

module "lambda_with_sqs" {
  source = "../../"

  function_name = "test-lambda-event-source-${random_id.test.hex}"
  description   = "Test Lambda function with SQS event source mapping"
  runtime       = "nodejs20.x"
  handler       = "index.handler"

  # Use inline code for testing
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout     = 30
  memory_size = 256

  environment_variables = {
    QUEUE_NAME = aws_sqs_queue.test.name
  }

  # Event source mapping - SQS trigger
  event_source_mappings = [
    {
      event_source_arn                   = aws_sqs_queue.test.arn
      batch_size                         = 1
      maximum_batching_window_in_seconds = 0
      enabled                            = true
      function_response_types            = ["ReportBatchItemFailures"]
      scaling_config = {
        maximum_concurrency = 5
      }
      filter_criteria = null
    }
  ]

  # IAM permissions for SQS
  policy_statements = [
    {
      effect = "Allow"
      actions = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ChangeMessageVisibility"
      ]
      resources = [aws_sqs_queue.test.arn]
    }
  ]

  log_retention_days = 1

  tags = {
    TestType = "event-source-mapping"
  }
}

# -----------------------------------------------------------------------------
# Lambda Function Code
# -----------------------------------------------------------------------------

resource "local_file" "lambda_code" {
  filename = "${path.module}/lambda/index.js"
  content  = <<-EOT
    exports.handler = async (event) => {
      console.log('Received SQS event:', JSON.stringify(event, null, 2));

      const batchItemFailures = [];

      for (const record of event.Records) {
        try {
          console.log('Processing message:', record.messageId);
          console.log('Message body:', record.body);

          const body = JSON.parse(record.body);
          console.log('Parsed body:', body);

          // Simulate processing
          if (body.error) {
            throw new Error('Simulated error');
          }

          console.log('Message processed successfully');
        } catch (error) {
          console.error('Failed to process message:', error);
          batchItemFailures.push({
            itemIdentifier: record.messageId
          });
        }
      }

      return {
        batchItemFailures
      };
    };
  EOT
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"

  source {
    content  = local_file.lambda_code.content
    filename = "index.js"
  }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda_with_sqs.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda_with_sqs.function_arn
}

output "queue_url" {
  description = "URL of the test SQS queue"
  value       = aws_sqs_queue.test.url
}

output "queue_arn" {
  description = "ARN of the test SQS queue"
  value       = aws_sqs_queue.test.arn
}

output "event_source_mapping_uuids" {
  description = "UUIDs of event source mappings"
  value       = module.lambda_with_sqs.event_source_mapping_uuids
}

output "event_source_mapping_states" {
  description = "States of event source mappings"
  value       = module.lambda_with_sqs.event_source_mapping_states
}
