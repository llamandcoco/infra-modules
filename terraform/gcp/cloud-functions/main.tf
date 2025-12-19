terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

# Cloud Storage Bucket for Function Source Code
# Stores the Cloud Function source code archive
resource "google_storage_bucket" "function_source" {
  name          = "${var.function_name}-source-${var.project_id}"
  location      = var.region
  project       = var.project_id
  force_destroy = var.force_destroy

  uniform_bucket_level_access = true

  versioning {
    enabled = var.versioning_enabled
  }

  labels = merge(
    var.labels,
    {
      managed-by = "terraform"
      purpose    = "cloud-function-source"
    }
  )
}

# Service Account for Cloud Function
# Creates a dedicated service account with least privilege access
resource "google_service_account" "function" {
  count = var.service_account_email == null ? 1 : 0

  account_id   = "${var.function_name}-sa"
  display_name = "Service Account for ${var.function_name} Cloud Function"
  project      = var.project_id
  description  = "Managed by Terraform. Service account for Cloud Function ${var.function_name}."
}

# Cloud Function (2nd Generation)
# Creates a serverless function with production-ready defaults
resource "google_cloudfunctions2_function" "function" {
  name        = var.function_name
  location    = var.region
  project     = var.project_id
  description = var.description

  build_config {
    runtime     = var.runtime
    entry_point = var.entry_point

    source {
      storage_source {
        bucket = google_storage_bucket.function_source.name
        object = var.source_archive_object
      }
    }

    environment_variables = var.build_environment_variables
    docker_repository     = var.docker_repository
  }

  service_config {
    max_instance_count               = var.max_instance_count
    min_instance_count               = var.min_instance_count
    available_memory                 = var.available_memory
    timeout_seconds                  = var.timeout_seconds
    max_instance_request_concurrency = var.max_instance_request_concurrency
    available_cpu                    = var.available_cpu

    environment_variables          = var.environment_variables
    ingress_settings               = var.ingress_settings
    all_traffic_on_latest_revision = var.all_traffic_on_latest_revision
    service_account_email          = var.service_account_email != null ? var.service_account_email : google_service_account.function[0].email
    vpc_connector                  = var.vpc_connector
    vpc_connector_egress_settings  = var.vpc_connector_egress_settings

    dynamic "secret_environment_variables" {
      for_each = var.secret_environment_variables

      content {
        key        = secret_environment_variables.value.key
        project_id = secret_environment_variables.value.project_id
        secret     = secret_environment_variables.value.secret
        version    = secret_environment_variables.value.version
      }
    }

    dynamic "secret_volumes" {
      for_each = var.secret_volumes

      content {
        mount_path = secret_volumes.value.mount_path
        project_id = secret_volumes.value.project_id
        secret     = secret_volumes.value.secret

        dynamic "versions" {
          for_each = secret_volumes.value.versions

          content {
            version = versions.value.version
            path    = versions.value.path
          }
        }
      }
    }
  }

  labels = merge(
    var.labels,
    {
      managed-by = "terraform"
    }
  )

  depends_on = [
    google_storage_bucket.function_source
  ]
}

# IAM Policy for Function Invocation
# Controls who can invoke the Cloud Function
resource "google_cloudfunctions2_function_iam_member" "invoker" {
  for_each = toset(var.invoker_members)

  project        = var.project_id
  location       = var.region
  cloud_function = google_cloudfunctions2_function.function.name
  role           = "roles/cloudfunctions.invoker"
  member         = each.value
}

# IAM Policy for Public Access
# Allows unauthenticated invocation if enabled
resource "google_cloudfunctions2_function_iam_member" "public_invoker" {
  count = var.allow_unauthenticated_invocations ? 1 : 0

  project        = var.project_id
  location       = var.region
  cloud_function = google_cloudfunctions2_function.function.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}
