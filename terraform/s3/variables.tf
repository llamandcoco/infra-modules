# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "bucket_name" {
  description = "Name of the S3 bucket. Must be globally unique across all AWS accounts."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must start and end with a lowercase letter or number, and can only contain lowercase letters, numbers, and hyphens."
  }

  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "Bucket name must be between 3 and 63 characters long."
  }
}

# -----------------------------------------------------------------------------
# Security Variables
# -----------------------------------------------------------------------------

variable "versioning_enabled" {
  description = "Enable versioning to protect against accidental deletion and provide object history. Recommended for production buckets."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "ARN of the KMS key to use for SSE-KMS encryption. If not specified, SSE-S3 (AES256) encryption will be used."
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Enable S3 Bucket Keys to reduce KMS costs by decreasing request traffic from S3 to KMS. Only applies when using KMS encryption."
  type        = bool
  default     = true
}

variable "block_public_acls" {
  description = "Block public ACLs on this bucket. Recommended to keep enabled for security."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Block public bucket policies on this bucket. Recommended to keep enabled for security."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignore public ACLs on this bucket. Recommended to keep enabled for security."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restrict public bucket policies for this bucket. Recommended to keep enabled for security."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Lifecycle Management Variables
# -----------------------------------------------------------------------------

variable "lifecycle_rules" {
  description = <<-EOT
    List of lifecycle rules to manage object transitions and expiration.
    Each rule can include:
    - id: Unique identifier for the rule
    - enabled: Whether the rule is active
    - prefix: Object key prefix to apply the rule (optional)
    - tags: Map of tags to filter objects (optional)
    - transitions: List of storage class transitions with days and storage_class
    - expiration_days: Number of days until objects expire (optional)
    - abort_incomplete_multipart_upload_days: Days to abort incomplete uploads (optional)
    - noncurrent_version_transitions: List of transitions for old versions (optional)
    - noncurrent_version_expiration_days: Days until old versions expire (optional)
  EOT
  type = list(object({
    id          = string
    enabled     = bool
    prefix      = optional(string)
    tags        = optional(map(string), {})
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
    expiration_days                        = optional(number)
    abort_incomplete_multipart_upload_days = optional(number)
    noncurrent_version_transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
    noncurrent_version_expiration_days = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules :
      contains(["STANDARD_IA", "ONEZONE_IA", "INTELLIGENT_TIERING", "GLACIER", "GLACIER_IR", "DEEP_ARCHIVE"], rule.transitions != null ? try(rule.transitions[0].storage_class, "STANDARD_IA") : "STANDARD_IA") || length(rule.transitions) == 0
    ])
    error_message = "Storage class must be one of: STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER, GLACIER_IR, DEEP_ARCHIVE."
  }
}

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "force_destroy" {
  description = "Allow deletion of non-empty bucket. Use with caution in production environments."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources. Use this to add consistent tagging across your infrastructure."
  type        = map(string)
  default     = {}
}
