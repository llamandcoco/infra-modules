# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "bucket_name" {
  description = "Name of the GCS bucket. Must be globally unique across all Google Cloud projects."
  type        = string

  validation {
    condition = alltrue([
      can(regex("^[a-z0-9][a-z0-9_.-]*[a-z0-9]$", var.bucket_name)),
      !can(regex("\\.\\.", var.bucket_name)),
      !can(regex("\\.-", var.bucket_name)),
      !can(regex("-\\.", var.bucket_name)),
      !can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$", var.bucket_name))
    ])
    error_message = "Bucket name must start and end with a lowercase letter or number, can only contain lowercase letters, numbers, hyphens, underscores, and dots. Cannot contain consecutive dots (..), dots adjacent to hyphens (.- or .-), or resemble an IP address."
  }

  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "Bucket name must be between 3 and 63 characters long."
  }
}

# -----------------------------------------------------------------------------
# Location and Storage Configuration
# -----------------------------------------------------------------------------

variable "location" {
  description = "The GCS location (region or multi-region) where the bucket will be created. Examples: 'US', 'EU', 'us-central1', 'europe-west1'."
  type        = string
  default     = "US"
}

variable "storage_class" {
  description = "The Storage Class of the bucket. Supported values: STANDARD, NEARLINE, COLDLINE, ARCHIVE."
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "NEARLINE", "COLDLINE", "ARCHIVE"], var.storage_class)
    error_message = "Storage class must be one of: STANDARD, NEARLINE, COLDLINE, ARCHIVE."
  }
}

# -----------------------------------------------------------------------------
# Access Control Configuration
# -----------------------------------------------------------------------------

variable "uniform_bucket_level_access" {
  description = "Enable uniform bucket-level access to use IAM exclusively for access control. Recommended for security and simplicity."
  type        = bool
  default     = true
}

variable "public_access_prevention" {
  description = "Prevents public access to the bucket. Set to 'enforced' to block all public access, 'inherited' to inherit from organization policy."
  type        = string
  default     = "enforced"

  validation {
    condition     = contains(["enforced", "inherited"], var.public_access_prevention)
    error_message = "Public access prevention must be either 'enforced' or 'inherited'."
  }
}

# -----------------------------------------------------------------------------
# Data Protection & Reliability Variables
# -----------------------------------------------------------------------------

variable "versioning_enabled" {
  description = "Enable versioning to protect against accidental deletion and provide object history. Recommended for production buckets."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Security Variables
# -----------------------------------------------------------------------------

variable "encryption_key_name" {
  description = "The full resource name of the Cloud KMS key to use for default encryption. If not specified, Google-managed encryption keys will be used. Format: projects/PROJECT_ID/locations/LOCATION/keyRings/KEY_RING/cryptoKeys/KEY_NAME"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Logging Configuration
# -----------------------------------------------------------------------------

variable "logging_config" {
  description = "Logging configuration for the bucket. If not specified, logging is disabled. The log_bucket should be the name (not a resource path) of the destination bucket for logs."
  type = object({
    log_bucket        = string
    log_object_prefix = optional(string, "")
  })
  default = null
}

# -----------------------------------------------------------------------------
# Lifecycle Management Variables
# -----------------------------------------------------------------------------

variable "lifecycle_rules" {
  description = <<-EOT
    List of lifecycle rules to manage object transitions and deletion.
    Each rule supports:
    - action_type: Type of action (Delete, SetStorageClass, AbortIncompleteMultipartUpload)
    - action_storage_class: Target storage class for SetStorageClass action
    - age: Age of object in days
    - created_before: Date in RFC 3339 format (e.g., "2023-01-15")
    - custom_time_before: Date in RFC 3339 format for custom time metadata
    - days_since_custom_time: Days since custom time
    - days_since_noncurrent_time: Days since object became noncurrent
    - noncurrent_time_before: Date in RFC 3339 format
    - num_newer_versions: Number of newer versions to keep
    - with_state: Match objects with state (LIVE, ARCHIVED, ANY)
    - matches_prefix: List of prefixes to match
    - matches_suffix: List of suffixes to match
    - matches_storage_class: List of storage classes to match
  EOT
  type = list(object({
    action_type                = string
    action_storage_class       = optional(string)
    age                        = optional(number)
    created_before             = optional(string)
    custom_time_before         = optional(string)
    days_since_custom_time     = optional(number)
    days_since_noncurrent_time = optional(number)
    noncurrent_time_before     = optional(string)
    num_newer_versions         = optional(number)
    with_state                 = optional(string, "ANY")
    matches_prefix             = optional(list(string), [])
    matches_suffix             = optional(list(string), [])
    matches_storage_class      = optional(list(string), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules :
      contains(["Delete", "SetStorageClass", "AbortIncompleteMultipartUpload"], rule.action_type)
    ])
    error_message = "Action type must be one of: Delete, SetStorageClass, AbortIncompleteMultipartUpload."
  }

  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules :
      rule.action_type != "SetStorageClass" || (rule.action_storage_class != null && contains(["NEARLINE", "COLDLINE", "ARCHIVE"], rule.action_storage_class))
    ])
    error_message = "When action_type is SetStorageClass, action_storage_class must be one of: NEARLINE, COLDLINE, ARCHIVE."
  }

  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules :
      rule.with_state == null || contains(["LIVE", "ARCHIVED", "ANY"], rule.with_state)
    ])
    error_message = "with_state must be one of: LIVE, ARCHIVED, ANY."
  }
}

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "force_destroy" {
  description = "Allow deletion of non-empty bucket. Use with caution in production environments as this will permanently delete all objects."
  type        = bool
  default     = false
}

variable "labels" {
  description = "A map of labels (key-value pairs) to add to the bucket. Use this to add consistent labeling across your infrastructure."
  type        = map(string)
  default     = {}
}
