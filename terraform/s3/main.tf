// terraform/s3/main.tf
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  create_lifecycle = length(var.lifecycle_rules) > 0
}

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name != "" ? var.bucket_name : null
  bucket_prefix = var.bucket_name == "" && var.bucket_prefix != "" ? var.bucket_prefix : null
  force_destroy = var.force_destroy

  tags = merge(var.default_tags, var.tags)
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = var.acl

  depends_on = [aws_s3_bucket_public_access_block.this]
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = [1]
    content {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.encryption_algorithm
        kms_master_key_id = var.kms_master_key_id != "" ? var.kms_master_key_id : null
      }
    }
  }
  depends_on = [aws_s3_bucket.this]
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = local.create_lifecycle ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      dynamic "filter" {
        for_each = lookup(rule.value, "prefix", null) != null ? [1] : []
        content {
          prefix = rule.value.prefix
        }
      }

      dynamic "transition" {
        for_each = lookup(rule.value, "transitions", [])
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = lookup(rule.value, "expiration", [])
        content {
          days = expiration.value.days
        }
      }
    }
  }
  depends_on = [aws_s3_bucket.this]
}
