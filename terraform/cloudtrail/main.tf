terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  count  = var.create_s3_bucket_policy ? 1 : 0
  bucket = var.s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = var.s3_bucket_arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${var.s3_bucket_arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# CloudTrail
resource "aws_cloudtrail" "this" {
  name                          = var.trail_name
  s3_bucket_name                = var.s3_bucket_id
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  enable_log_file_validation    = var.enable_log_file_validation
  is_organization_trail         = var.is_organization_trail
  kms_key_id                    = var.kms_key_id

  # CloudWatch Logs (optional, increases cost)
  cloud_watch_logs_group_arn = var.cloudwatch_logs_group_arn != null ? "${var.cloudwatch_logs_group_arn}:*" : null
  cloud_watch_logs_role_arn  = var.cloudwatch_logs_group_arn != null ? aws_iam_role.cloudwatch_logs[0].arn : null

  # Management events only (free tier)
  event_selector {
    read_write_type           = var.read_write_type
    include_management_events = true

    # Exclude data events by default (cost optimization)
    exclude_management_event_sources = var.exclude_management_event_sources
  }

  # Advanced event selectors for more granular control
  dynamic "advanced_event_selector" {
    for_each = var.advanced_event_selectors
    content {
      name = advanced_event_selector.value.name

      dynamic "field_selector" {
        for_each = advanced_event_selector.value.field_selectors
        content {
          field           = field_selector.value.field
          equals          = lookup(field_selector.value, "equals", null)
          not_equals      = lookup(field_selector.value, "not_equals", null)
          starts_with     = lookup(field_selector.value, "starts_with", null)
          not_starts_with = lookup(field_selector.value, "not_starts_with", null)
          ends_with       = lookup(field_selector.value, "ends_with", null)
          not_ends_with   = lookup(field_selector.value, "not_ends_with", null)
        }
      }
    }
  }

  # Insights (optional, additional cost)
  dynamic "insight_selector" {
    for_each = var.enable_insights ? [1] : []
    content {
      insight_type = "ApiCallRateInsight"
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.trail_name
    }
  )

  depends_on = [aws_s3_bucket_policy.cloudtrail[0]]
}

# IAM role for CloudWatch Logs (if enabled)
resource "aws_iam_role" "cloudwatch_logs" {
  count = var.cloudwatch_logs_group_arn != null ? 1 : 0

  name = "${var.trail_name}-cloudwatch-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "cloudwatch_logs" {
  count = var.cloudwatch_logs_group_arn != null ? 1 : 0

  name = "${var.trail_name}-cloudwatch-logs-policy"
  role = aws_iam_role.cloudwatch_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailCreateLogStream"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${var.cloudwatch_logs_group_arn}:*"
      }
    ]
  })
}
