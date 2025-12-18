# -----------------------------------------------------------------------------
# Function Identification Outputs
# -----------------------------------------------------------------------------

output "function_id" {
  description = "The unique identifier of the Cloud Function."
  value       = google_cloudfunctions2_function.function.id
}

output "function_name" {
  description = "The name of the Cloud Function."
  value       = google_cloudfunctions2_function.function.name
}

# -----------------------------------------------------------------------------
# Function Endpoint Outputs
# -----------------------------------------------------------------------------

output "function_uri" {
  description = "The URI of the Cloud Function. Use this to invoke the function via HTTP."
  value       = google_cloudfunctions2_function.function.service_config[0].uri
}

output "function_url" {
  description = "The URL of the Cloud Function (alias for function_uri for convenience)."
  value       = google_cloudfunctions2_function.function.service_config[0].uri
}

# -----------------------------------------------------------------------------
# Service Account Outputs
# -----------------------------------------------------------------------------

output "service_account_email" {
  description = "The email address of the service account used by the Cloud Function."
  value       = var.service_account_email != null ? var.service_account_email : google_service_account.function[0].email
}

output "service_account_id" {
  description = "The unique ID of the created service account, if one was created by this module."
  value       = var.service_account_email == null ? google_service_account.function[0].id : null
}

# -----------------------------------------------------------------------------
# Storage Outputs
# -----------------------------------------------------------------------------

output "source_bucket_name" {
  description = "The name of the Cloud Storage bucket containing the function source code."
  value       = google_storage_bucket.function_source.name
}

output "source_bucket_url" {
  description = "The URL of the Cloud Storage bucket containing the function source code."
  value       = google_storage_bucket.function_source.url
}

# -----------------------------------------------------------------------------
# Configuration Outputs
# -----------------------------------------------------------------------------

output "region" {
  description = "The GCP region where the Cloud Function is deployed."
  value       = google_cloudfunctions2_function.function.location
}

output "project_id" {
  description = "The GCP project ID where the Cloud Function is deployed."
  value       = google_cloudfunctions2_function.function.project
}

output "runtime" {
  description = "The runtime environment of the Cloud Function."
  value       = google_cloudfunctions2_function.function.build_config[0].runtime
}

output "available_memory" {
  description = "The amount of memory allocated to the Cloud Function."
  value       = google_cloudfunctions2_function.function.service_config[0].available_memory
}

output "timeout_seconds" {
  description = "The timeout setting of the Cloud Function in seconds."
  value       = google_cloudfunctions2_function.function.service_config[0].timeout_seconds
}

output "max_instance_count" {
  description = "The maximum number of function instances configured."
  value       = google_cloudfunctions2_function.function.service_config[0].max_instance_count
}

output "min_instance_count" {
  description = "The minimum number of function instances configured."
  value       = google_cloudfunctions2_function.function.service_config[0].min_instance_count
}

# -----------------------------------------------------------------------------
# Security Outputs
# -----------------------------------------------------------------------------

output "ingress_settings" {
  description = "The ingress settings configured for the Cloud Function."
  value       = google_cloudfunctions2_function.function.service_config[0].ingress_settings
}

output "allow_unauthenticated" {
  description = "Whether unauthenticated invocations are allowed."
  value       = var.allow_unauthenticated_invocations
}

# -----------------------------------------------------------------------------
# Reference Outputs
# -----------------------------------------------------------------------------

output "labels" {
  description = "All labels applied to the Cloud Function."
  value       = google_cloudfunctions2_function.function.labels
}

output "state" {
  description = "The current state of the Cloud Function."
  value       = google_cloudfunctions2_function.function.state
}
