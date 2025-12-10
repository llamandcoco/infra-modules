terraform {
  required_version = ">= 1.0"
}

# S3 bucket for CloudTrail logs
module "s3" {
  source = "../../s3"

  bucket_name   = var.s3_bucket_name
  force_destroy = var.force_destroy

  # Security best practices
  versioning_enabled      = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  kms_key_id              = var.kms_key_id

  # Cost optimization with lifecycle policy
  lifecycle_rules = var.enable_lifecycle_policy ? [
    {
      id      = "archive-old-cloudtrail-logs"
      enabled = true

      transitions = [
        {
          days          = var.glacier_transition_days
          storage_class = "GLACIER"
        }
      ]

      expiration_days = var.log_retention_days
    }
  ] : []

  tags = merge(
    var.tags,
    {
      Purpose = "CloudTrail logs storage"
    }
  )
}

# CloudTrail
module "cloudtrail" {
  source = "../../cloudtrail"

  trail_name    = var.trail_name
  s3_bucket_id  = module.s3.bucket_id
  s3_bucket_arn = module.s3.bucket_arn

  # Multi-region configuration
  is_multi_region_trail         = var.is_multi_region_trail
  include_global_service_events = var.include_global_service_events

  # Security settings
  enable_log_file_validation = var.enable_log_file_validation
  is_organization_trail      = var.is_organization_trail
  kms_key_id                 = var.kms_key_id

  # CloudWatch Logs (optional, increases cost)
  cloudwatch_logs_group_arn = var.cloudwatch_logs_group_arn

  # Event filtering
  read_write_type                  = var.read_write_type
  exclude_management_event_sources = var.exclude_management_event_sources
  advanced_event_selectors         = var.advanced_event_selectors

  # Insights (optional, additional cost)
  enable_insights = var.enable_insights

  # Automatically create bucket policy
  create_s3_bucket_policy = true

  tags = var.tags

  depends_on = [module.s3]
}
