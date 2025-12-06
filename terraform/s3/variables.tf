variable "bucket_name" {
  description = "Unique name for the S3 bucket. Use lowercase letters, numbers, and hyphens only."
  type        = string

  validation {
    condition     = length(var.bucket_name) > 2 && length(regexall("^[a-z0-9.-]+$", var.bucket_name)) > 0
    error_message = "bucket_name must be at least 3 characters and contain only lowercase letters, numbers, dots, and hyphens."
  }
}

variable "force_destroy" {
  description = "When true, bucket and all objects are destroyed without recovery. Use cautiously."
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enable object versioning. Recommended for auditability and recovery."
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Server-side encryption type to apply. Use SSE-KMS to bring your own KMS key."
  type        = string
  default     = "SSE-S3"

  validation {
    condition     = contains(["SSE-S3", "SSE-KMS"], var.encryption_type)
    error_message = "encryption_type must be either SSE-S3 or SSE-KMS."
  }
}

variable "kms_key_id" {
  description = "KMS key ARN or ID to use when encryption_type is SSE-KMS. Leave null to use default S3 key."
  type        = string
  default     = null

  validation {
    condition     = var.encryption_type != "SSE-KMS" || try(length(var.kms_key_id) > 0, false)
    error_message = "kms_key_id is required when encryption_type is SSE-KMS."
  }
}

variable "bucket_key_enabled" {
  description = "Enable S3 Bucket Keys when using SSE-KMS to reduce cost. Ignored for SSE-S3."
  type        = bool
  default     = true
}

variable "public_access_block_enabled" {
  description = "Create a public access block to prevent accidental public exposure."
  type        = bool
  default     = true
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket."
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "Lifecycle rules to apply to the bucket. Leave empty to disable lifecycle configuration."
  type = list(object({
    id                                     = string
    enabled                                = bool
    prefix                                 = optional(string)
    expiration_days                        = optional(number)
    noncurrent_version_expiration_days     = optional(number)
    abort_incomplete_multipart_upload_days = optional(number)
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules : (
        (rule.expiration_days == null || rule.expiration_days >= 1) &&
        (rule.noncurrent_version_expiration_days == null || rule.noncurrent_version_expiration_days >= 1) &&
        (rule.abort_incomplete_multipart_upload_days == null || rule.abort_incomplete_multipart_upload_days >= 1)
      )
    ])
    error_message = "Lifecycle rule numeric values must be 1 or greater when provided."
  }
}

variable "tags" {
  description = "A map of tags to add to all resources. Name is automatically set to bucket_name."
  type        = map(string)
  default     = {}
}
