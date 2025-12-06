// terraform/s3/variables.tf
variable "bucket_name" {
  description = "The name of the S3 bucket. Provide a globally unique name. If empty, Terraform will generate a name based on the bucket_prefix."
  type        = string
  default     = ""
  validation {
    condition     = (var.bucket_name == "") || (length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63)
    error_message = "bucket_name must be empty (to allow generated name) or a valid bucket name between 3 and 63 characters."
  }
}

variable "bucket_prefix" {
  description = "Optional bucket name prefix to be used when bucket_name is not provided. Useful for environments where fully unique bucket names are generated."
  type        = string
  default     = ""
  validation {
    condition     = length(var.bucket_prefix) <= 50
    error_message = "bucket_prefix must be 50 characters or less."
  }
}

variable "acl" {
  description = "Canned ACL to apply to the S3 bucket. Default is private. Avoid using public ACLs."
  type        = string
  default     = "private"
  validation {
    condition     = contains(["private", "public-read", "public-read-write", "authenticated-read"], var.acl)
    error_message = "ACL must be one of: private, public-read, public-read-write, authenticated-read."
  }
}

variable "versioning_enabled" {
  description = "Enable S3 bucket versioning. Defaults to true for safety (prevents accidental deletes/overwrites)."
  type        = bool
  default     = true
}

variable "encryption_algorithm" {
  description = "Server-side encryption algorithm for the bucket. Use 'AES256' for SSE-S3 or 'aws:kms' for KMS-managed keys."
  type        = string
  default     = "AES256"
  validation {
    condition     = contains(["AES256", "aws:kms"], var.encryption_algorithm)
    error_message = "encryption_algorithm must be one of: 'AES256' or 'aws:kms'."
  }
}

variable "kms_master_key_id" {
  description = "KMS key id/arn to use when encryption_algorithm = 'aws:kms'. If empty and aws:kms is chosen, the default KMS key will be used by AWS."
  type        = string
  default     = ""
}

variable "block_public_acls" {
  description = "Block public ACLs on the bucket."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignore public ACLs on the bucket."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Block public bucket policies."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Only allow access if the bucket and its objects do not have public access."
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "Optional list of lifecycle rules. Each rule is an object with keys: id (string), enabled (bool), prefix (string, optional), transitions (list of { days = number, storage_class = string } optional), expiration (list of { days = number } optional)."
  type = list(object({
    id          = string
    enabled     = bool
    prefix      = optional(string)
    transitions = optional(list(object({ days = number, storage_class = string })))
    expiration  = optional(list(object({ days = number })))
  }))
  default = []
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. Use with caution."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to add to all resources created by this module."
  type        = map(string)
  default     = {}
}

variable "default_tags" {
  description = "Default tags applied to the bucket. Users can override/extend via the 'tags' variable."
  type        = map(string)
  default     = { "managed_by" = "terraform" }
}
