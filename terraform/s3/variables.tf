variable "bucket_name" {
  description = "Name of the S3 bucket. Must be globally unique and DNS-compliant (3-63 characters, lowercase letters, numbers, hyphens, and periods only)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be 3-63 characters long, start and end with a lowercase letter or number, and contain only lowercase letters, numbers, hyphens, and periods."
  }

  validation {
    condition     = !can(regex("[A-Z_]", var.bucket_name))
    error_message = "Bucket name must not contain uppercase letters or underscores."
  }

  validation {
    condition     = !can(regex("\\.\\.", var.bucket_name))
    error_message = "Bucket name must not contain consecutive periods."
  }

  validation {
    condition     = !can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.bucket_name))
    error_message = "Bucket name must not be formatted as an IP address (e.g., 192.168.1.1)."
  }
}

variable "force_destroy" {
  description = "WARNING: If true, the bucket can be destroyed even if it contains objects. This will delete all objects in the bucket when the bucket is destroyed. Use with caution in production environments."
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enable versioning for the S3 bucket. Versioning allows you to preserve, retrieve, and restore every version of every object stored in the bucket. Recommended for production data."
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Type of server-side encryption to use. Valid values are 'AES256' (SSE-S3) or 'aws:kms' (SSE-KMS). SSE-S3 uses Amazon S3-managed keys, while SSE-KMS uses AWS Key Management Service."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.encryption_type)
    error_message = "Encryption type must be either 'AES256' or 'aws:kms'."
  }
}

variable "kms_master_key_id" {
  description = "The AWS KMS master key ID for SSE-KMS encryption. Required when encryption_type is 'aws:kms'. Can be the key ID, key ARN, alias name, or alias ARN."
  type        = string
  default     = null
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket. When true, PUT requests with public ACLs will fail."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket. When true, PUT bucket policy requests with public policies will fail."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket. When true, public ACLs are ignored and the bucket is treated as private."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket. When true, only AWS service principals and authorized users can access the bucket."
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = <<-EOT
    List of lifecycle rules for the bucket. Each rule can define transitions between storage classes and expiration policies.
    Example:
    [{
      id      = "archive-old-logs"
      enabled = true
      filter_prefix = "logs/"
      transition = [{
        days          = 90
        storage_class = "STANDARD_IA"
      }]
      expiration = {
        days = 365
      }
    }]
  EOT
  type = list(object({
    id                                     = string
    enabled                                = bool
    filter_prefix                          = optional(string)
    filter_tags                            = optional(map(string))
    abort_incomplete_multipart_upload_days = optional(number)
    transition = optional(list(object({
      days          = optional(number)
      date          = optional(string)
      storage_class = string
    })))
    expiration = optional(object({
      days                         = optional(number)
      date                         = optional(string)
      expired_object_delete_marker = optional(bool)
    }))
    noncurrent_version_transition = optional(list(object({
      noncurrent_days = number
      storage_class   = string
    })))
    noncurrent_version_expiration = optional(object({
      noncurrent_days = number
    }))
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to add to all resources. Tags are key-value pairs that help you organize and identify your AWS resources."
  type        = map(string)
  default     = {}
}
