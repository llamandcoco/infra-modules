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

  # Skip CloudTrail-specific validations
  s3_use_path_style = true
}

# Generate random suffix for globally unique bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Create S3 bucket for CloudTrail logs
module "cloudtrail_s3" {
  source = "../../../s3"

  bucket_name   = "cloudtrail-logs-${random_id.bucket_suffix.hex}"
  force_destroy = true

  # Security best practices
  versioning_enabled      = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Cost optimization
  lifecycle_rules = [
    {
      id      = "archive-old-logs"
      enabled = true

      transitions = [
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]

      expiration_days = 365
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
  }
}

# Minimum configuration - Cost optimized
module "cloudtrail_minimum" {
  source = "../.."

  trail_name    = "test-cloudtrail-minimum"
  s3_bucket_id  = module.cloudtrail_s3.bucket_id
  s3_bucket_arn = module.cloudtrail_s3.bucket_arn

  # Multi-region for complete visibility (free)
  is_multi_region_trail         = true
  include_global_service_events = true

  # Security best practices (free)
  enable_log_file_validation = true

  # Cost optimization
  cloudwatch_logs_group_arn = null  # Disable CloudWatch Logs (saves ~$50/month)
  enable_insights           = false # Disable insights (saves $0.35/100k events)

  # Management events only (free tier)
  read_write_type = "All"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
  }
}

# Example: With CloudWatch Logs (higher cost but real-time analysis)
# Uncomment to test
# resource "aws_cloudwatch_log_group" "cloudtrail" {
#   name              = "/aws/cloudtrail/test-cloudtrail"
#   retention_in_days = 7
# }
#
# module "cloudtrail_with_cloudwatch" {
#   source = "../.."
#
#   trail_name                = "test-cloudtrail-cloudwatch"
#   s3_bucket_name            = "test-cloudtrail-cw-${random_id.bucket_suffix.hex}"
#   is_multi_region_trail     = true
#   cloudwatch_logs_group_arn = aws_cloudwatch_log_group.cloudtrail.arn
# }

output "trail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = module.cloudtrail_minimum.trail_arn
}

output "s3_bucket_id" {
  description = "S3 bucket storing CloudTrail logs"
  value       = module.cloudtrail_s3.bucket_id
}

output "estimated_monthly_cost" {
  description = "Estimated monthly cost (USD)"
  value       = "~$2-5 (S3 storage only, CloudTrail trail is free)"
}
