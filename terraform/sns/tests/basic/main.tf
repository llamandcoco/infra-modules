terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Mock AWS provider for testing without credentials
provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  access_key = "test"
  secret_key = "test"
}

# Test 1: Basic standard topic
module "test_standard_topic" {
  source = "../../"

  topic_name   = "test-standard-topic"
  display_name = "Test Standard Topic"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    TopicType   = "standard"
  }
}

# Test 2: FIFO topic with content-based deduplication
module "test_fifo_topic" {
  source = "../../"

  topic_name                  = "test-fifo-topic" # .fifo suffix added automatically
  display_name                = "Test FIFO Topic"
  fifo_topic                  = true
  content_based_deduplication = true

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    TopicType   = "fifo"
  }
}

# Test 3: Topic with KMS encryption
module "test_encrypted_topic" {
  source = "../../"

  topic_name   = "test-encrypted-topic"
  display_name = "Test Encrypted Topic"

  # Simulate KMS encryption (this ARN won't be validated in mock mode)
  kms_master_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    Encryption  = "kms"
  }
}

# Test 4: Topic with subscriptions
module "test_topic_with_subscriptions" {
  source = "../../"

  topic_name   = "test-topic-with-subscriptions"
  display_name = "Test Topic with Subscriptions"

  subscriptions = [
    {
      protocol             = "sqs"
      endpoint             = "arn:aws:sqs:us-east-1:123456789012:test-queue"
      raw_message_delivery = true
    },
    {
      protocol = "lambda"
      endpoint = "arn:aws:lambda:us-east-1:123456789012:function:test-function"
    },
    {
      protocol = "email"
      endpoint = "test@example.com"
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    Feature     = "subscriptions"
  }
}

# Test 5: Topic with delivery policy and X-Ray tracing
module "test_advanced_topic" {
  source = "../../"

  topic_name        = "test-advanced-topic"
  display_name      = "Test Advanced Topic"
  signature_version = 2
  tracing_config    = "Active"

  delivery_policy = {
    defaultHealthyRetryPolicy = {
      minDelayTarget     = 1
      maxDelayTarget     = 60
      numRetries         = 10
      numNoDelayRetries  = 0
      numMinDelayRetries = 3
      numMaxDelayRetries = 7
      backoffFunction    = "exponential"
    }
    disableSubscriptionOverrides = false
  }

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    Feature     = "advanced-config"
  }
}

# Test 6: Topic with delivery status logging
module "test_topic_with_logging" {
  source = "../../"

  topic_name   = "test-topic-with-logging"
  display_name = "Test Topic with Logging"

  # Simulate IAM roles for delivery status logging (ARNs won't be validated in mock mode)
  lambda_success_feedback_role_arn    = "arn:aws:iam::123456789012:role/sns-lambda-success"
  lambda_success_feedback_sample_rate = 100
  lambda_failure_feedback_role_arn    = "arn:aws:iam::123456789012:role/sns-lambda-failure"

  sqs_success_feedback_role_arn    = "arn:aws:iam::123456789012:role/sns-sqs-success"
  sqs_success_feedback_sample_rate = 50
  sqs_failure_feedback_role_arn    = "arn:aws:iam::123456789012:role/sns-sqs-failure"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    Feature     = "delivery-logging"
  }
}

# Outputs for verification
output "standard_topic_arn" {
  description = "ARN of the standard test topic"
  value       = module.test_standard_topic.topic_arn
}

output "standard_topic_name" {
  description = "Name of the standard test topic"
  value       = module.test_standard_topic.topic_name
}

output "fifo_topic_arn" {
  description = "ARN of the FIFO test topic"
  value       = module.test_fifo_topic.topic_arn
}

output "fifo_topic_name" {
  description = "Name of the FIFO test topic (should include .fifo suffix)"
  value       = module.test_fifo_topic.topic_name
}

output "fifo_topic_is_fifo" {
  description = "Whether the FIFO topic is actually FIFO"
  value       = module.test_fifo_topic.topic_fifo
}

output "encrypted_topic_arn" {
  description = "ARN of the encrypted test topic"
  value       = module.test_encrypted_topic.topic_arn
}

output "encrypted_topic_kms_key" {
  description = "KMS key ID for encrypted topic"
  value       = module.test_encrypted_topic.kms_master_key_id
}

output "topic_with_subscriptions_arn" {
  description = "ARN of the topic with subscriptions"
  value       = module.test_topic_with_subscriptions.topic_arn
}

output "topic_subscriptions_count" {
  description = "Number of subscriptions created"
  value       = module.test_topic_with_subscriptions.subscription_count
}

output "topic_subscription_arns" {
  description = "ARNs of all subscriptions"
  value       = module.test_topic_with_subscriptions.subscription_arns
}

output "advanced_topic_signature_version" {
  description = "Signature version for advanced topic"
  value       = module.test_advanced_topic.signature_version
}

output "advanced_topic_tracing" {
  description = "X-Ray tracing config for advanced topic"
  value       = module.test_advanced_topic.tracing_config
}

output "logging_topic_lambda_success_role" {
  description = "Lambda success feedback role ARN"
  value       = module.test_topic_with_logging.lambda_success_feedback_role_arn
}
