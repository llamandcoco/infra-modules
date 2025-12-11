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

# Test 1: Basic standard queue with DLQ
module "test_standard_queue" {
  source = "../../"

  queue_name                 = "test-standard-queue"
  visibility_timeout_seconds = 60
  receive_wait_time_seconds  = 20 # Enable long polling

  # DLQ configuration
  create_dlq        = true
  max_receive_count = 3

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    QueueType   = "standard"
  }
}

# Test 2: FIFO queue with content-based deduplication
module "test_fifo_queue" {
  source = "../../"

  queue_name                  = "test-fifo-queue" # .fifo suffix added automatically
  fifo_queue                  = true
  content_based_deduplication = true
  visibility_timeout_seconds  = 60

  # DLQ configuration
  create_dlq        = true
  max_receive_count = 5

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    QueueType   = "fifo"
  }
}

# Test 3: Standard queue with custom KMS encryption (simulated)
module "test_encrypted_queue" {
  source = "../../"

  queue_name                 = "test-encrypted-queue"
  visibility_timeout_seconds = 30

  # Simulate KMS encryption (this ARN won't be validated in mock mode)
  kms_master_key_id                 = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  kms_data_key_reuse_period_seconds = 300

  # No DLQ for this test
  create_dlq = false

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    Encryption  = "kms"
  }
}

# Test 4: FIFO queue with high throughput mode
module "test_high_throughput_fifo" {
  source = "../../"

  queue_name                  = "test-high-throughput-fifo.fifo" # Explicit .fifo suffix
  fifo_queue                  = true
  content_based_deduplication = true

  # High throughput settings
  deduplication_scope   = "messageGroup"
  fifo_throughput_limit = "perMessageGroupId"

  # DLQ configuration
  create_dlq        = true
  max_receive_count = 5

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    Mode        = "high-throughput"
  }
}

# Test 5: Queue with delayed delivery
module "test_delayed_queue" {
  source = "../../"

  queue_name    = "test-delayed-queue"
  delay_seconds = 60 # 1 minute delay

  # No DLQ for this test
  create_dlq = false

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    Feature     = "delayed-delivery"
  }
}

# Outputs for verification
output "standard_queue_url" {
  description = "URL of the standard test queue"
  value       = module.test_standard_queue.queue_url
}

output "standard_queue_arn" {
  description = "ARN of the standard test queue"
  value       = module.test_standard_queue.queue_arn
}

output "standard_dlq_url" {
  description = "URL of the standard queue DLQ"
  value       = module.test_standard_queue.dlq_url
}

output "fifo_queue_url" {
  description = "URL of the FIFO test queue"
  value       = module.test_fifo_queue.queue_url
}

output "fifo_queue_name" {
  description = "Name of the FIFO test queue (should include .fifo suffix)"
  value       = module.test_fifo_queue.queue_name
}

output "fifo_dlq_url" {
  description = "URL of the FIFO queue DLQ"
  value       = module.test_fifo_queue.dlq_url
}

output "encrypted_queue_arn" {
  description = "ARN of the encrypted test queue"
  value       = module.test_encrypted_queue.queue_arn
}

output "encrypted_queue_kms_enabled" {
  description = "Whether KMS encryption is enabled (should be false, indicating customer-managed key)"
  value       = module.test_encrypted_queue.sqs_managed_sse_enabled
}

output "high_throughput_fifo_name" {
  description = "Name of the high throughput FIFO queue"
  value       = module.test_high_throughput_fifo.queue_name
}

output "high_throughput_deduplication_scope" {
  description = "Deduplication scope for high throughput queue"
  value       = module.test_high_throughput_fifo.deduplication_scope
}

output "delayed_queue_delay" {
  description = "Delay seconds configured for the delayed queue"
  value       = module.test_delayed_queue.delay_seconds
}
