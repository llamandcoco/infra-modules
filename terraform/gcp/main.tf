terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# GCS Bucket
# Creates the main Cloud Storage bucket resource with all configurations
# trivy:ignore:google-storage-enable-ubla - Uniform bucket-level access is optional and configurable via uniform_bucket_level_access variable
resource "google_storage_bucket" "this" {
  name          = var.bucket_name
  location      = var.location
  storage_class = var.storage_class
  force_destroy = var.force_destroy

  labels = var.labels

  # Uniform bucket-level access for modern IAM management
  uniform_bucket_level_access = var.uniform_bucket_level_access

  # Public access prevention for security
  public_access_prevention = var.public_access_prevention

  # Versioning to protect against accidental deletion
  versioning {
    enabled = var.versioning_enabled
  }

  # Customer-Managed Encryption Keys (CMEK)
  # Google-managed encryption is enabled by default
  dynamic "encryption" {
    for_each = var.encryption_key_name != null ? [1] : []

    content {
      default_kms_key_name = var.encryption_key_name
    }
  }

  # Bucket Logging for audit and compliance
  dynamic "logging" {
    for_each = var.logging_config != null ? [1] : []

    content {
      log_bucket        = var.logging_config.log_bucket
      log_object_prefix = var.logging_config.log_object_prefix
    }
  }

  # Lifecycle rules for cost optimization
  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules

    content {
      action {
        type          = lifecycle_rule.value.action_type
        storage_class = lifecycle_rule.value.action_storage_class
      }

      condition {
        age                        = lifecycle_rule.value.age
        created_before             = lifecycle_rule.value.created_before
        custom_time_before         = lifecycle_rule.value.custom_time_before
        days_since_custom_time     = lifecycle_rule.value.days_since_custom_time
        days_since_noncurrent_time = lifecycle_rule.value.days_since_noncurrent_time
        noncurrent_time_before     = lifecycle_rule.value.noncurrent_time_before
        num_newer_versions         = lifecycle_rule.value.num_newer_versions
        with_state                 = lifecycle_rule.value.with_state
        matches_prefix             = length(lifecycle_rule.value.matches_prefix) > 0 ? lifecycle_rule.value.matches_prefix : null
        matches_suffix             = length(lifecycle_rule.value.matches_suffix) > 0 ? lifecycle_rule.value.matches_suffix : null
        matches_storage_class      = length(lifecycle_rule.value.matches_storage_class) > 0 ? lifecycle_rule.value.matches_storage_class : null
      }
    }
  }
}

