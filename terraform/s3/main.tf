terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = merge(
    var.tags,
    {
      Name = var.bucket_name
    },
  )
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    bucket_key_enabled = var.encryption_type == "SSE-KMS" ? var.bucket_key_enabled : null

    apply_server_side_encryption_by_default {
      sse_algorithm     = var.encryption_type == "SSE-KMS" ? "aws:kms" : "AES256"
      kms_master_key_id = var.encryption_type == "SSE-KMS" ? var.kms_key_id : null
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  count = var.public_access_block_enabled ? 1 : 0

  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      filter {
        prefix = coalesce(rule.value.prefix, "")
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_multipart_upload_days != null ? [rule.value.abort_incomplete_multipart_upload_days] : []

        content {
          days_after_initiation = abort_incomplete_multipart_upload.value
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration_days != null ? [rule.value.expiration_days] : []

        content {
          days = expiration.value
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration_days != null ? [rule.value.noncurrent_version_expiration_days] : []

        content {
          noncurrent_days = noncurrent_version_expiration.value
        }
      }

      dynamic "transition" {
        for_each = rule.value.transitions

        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }
    }
  }
}
