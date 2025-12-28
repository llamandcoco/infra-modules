terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# S3 Bucket
# Creates the main S3 bucket resource
# tfsec:ignore:aws-s3-enable-bucket-logging - Logging is optional and configurable via logging_target_bucket variable
resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = merge(
    var.tags,
    {
      Name = var.bucket_name
    }
  )
}

# Bucket Versioning
# Enables versioning to protect against accidental deletion and provide object history
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

# Server-Side Encryption
# Encrypts all objects stored in the bucket using either SSE-S3 or SSE-KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_id != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_id
    }
    bucket_key_enabled = var.kms_key_id != null ? var.bucket_key_enabled : null
  }
}

# Public Access Block
# Blocks all public access to the bucket for security best practices
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

# Bucket Logging
# Enables access logging for audit and compliance purposes
resource "aws_s3_bucket_logging" "this" {
  count  = var.logging_target_bucket != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  target_bucket = var.logging_target_bucket
  target_prefix = var.logging_target_prefix
}

# Lifecycle Configuration
# Manages object lifecycle transitions and expiration
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      # Filter is required (either with prefix/tags or empty)
      filter {
        # Use 'and' block when both prefix and tags are present
        dynamic "and" {
          for_each = rule.value.prefix != null && length(rule.value.tags) > 0 ? [1] : []

          content {
            prefix = rule.value.prefix
            tags   = rule.value.tags
          }
        }

        # Use simple prefix when only prefix is set
        prefix = rule.value.prefix != null && length(rule.value.tags) == 0 ? rule.value.prefix : null

        # Use tag blocks when only tags are set
        dynamic "tag" {
          for_each = rule.value.prefix == null && length(rule.value.tags) > 0 ? rule.value.tags : {}

          content {
            key   = tag.key
            value = tag.value
          }
        }
      }

      # Transition to different storage classes
      dynamic "transition" {
        for_each = rule.value.transitions

        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      # Expire objects after specified days
      dynamic "expiration" {
        for_each = rule.value.expiration_days != null ? [1] : []

        content {
          days = rule.value.expiration_days
        }
      }

      # Clean up incomplete multipart uploads
      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_multipart_upload_days != null ? [1] : []

        content {
          days_after_initiation = rule.value.abort_incomplete_multipart_upload_days
        }
      }

      # Manage noncurrent (versioned) objects
      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transitions

        content {
          noncurrent_days = noncurrent_version_transition.value.days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }

      # Expire old versions
      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration_days != null ? [1] : []

        content {
          noncurrent_days           = rule.value.noncurrent_version_expiration_days
          newer_noncurrent_versions = rule.value.newer_noncurrent_versions
        }
      }
    }
  }

  # Validate that each rule has at least one action
  lifecycle {
    precondition {
      condition = alltrue([
        for rule in var.lifecycle_rules :
        length(rule.transitions) > 0 ||
        rule.expiration_days != null ||
        rule.abort_incomplete_multipart_upload_days != null ||
        length(rule.noncurrent_version_transitions) > 0 ||
        rule.noncurrent_version_expiration_days != null
      ])
      error_message = "Each lifecycle rule must have at least one action: transitions, expiration_days, abort_incomplete_multipart_upload_days, noncurrent_version_transitions, or noncurrent_version_expiration_days."
    }
  }
}
