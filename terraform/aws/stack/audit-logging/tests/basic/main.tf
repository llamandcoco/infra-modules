terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  token                       = "mock_token"
  skip_credentials_validation = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  s3_use_path_style = true
}

# Generate random suffix for globally unique bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Full audit logging stack - Cost optimized
module "audit_logging" {
  source = "../.."

  trail_name     = "test-audit-trail"
  s3_bucket_name = "test-audit-logs-${random_id.bucket_suffix.hex}"

  # Multi-region for complete visibility (free)
  is_multi_region_trail         = true
  include_global_service_events = true

  # Security best practices (free)
  enable_log_file_validation = true

  # Cost optimization
  cloudwatch_logs_group_arn = null  # Disable CloudWatch Logs (saves ~$50/month)
  enable_insights           = false # Disable insights (saves $0.35/100k events)
  enable_lifecycle_policy   = true  # Archive old logs to Glacier

  # Archive to Glacier after 90 days, delete after 1 year
  glacier_transition_days = 90
  log_retention_days      = 365

  # Management events only (free tier)
  read_write_type = "All"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "audit-logging"
  }
}

output "trail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = module.audit_logging.trail_arn
}

output "s3_bucket_id" {
  description = "S3 bucket storing CloudTrail logs"
  value       = module.audit_logging.s3_bucket_id
}

output "estimated_monthly_cost" {
  description = "Estimated monthly cost (USD)"
  value       = "~$2-5 (S3 storage only, CloudTrail trail is free)"
}
