# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "table_name" {
  description = "Name of the DynamoDB table. Must be unique within the AWS account and region."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]+$", var.table_name))
    error_message = "Table name must only contain alphanumeric characters, hyphens, underscores, and periods."
  }

  validation {
    condition     = length(var.table_name) >= 3 && length(var.table_name) <= 255
    error_message = "Table name must be between 3 and 255 characters long."
  }
}

variable "hash_key" {
  description = "The attribute to use as the hash (partition) key. Must be defined in attributes."
  type        = string
}

variable "hash_key_type" {
  description = "Hash key attribute type. Valid values: S (string), N (number), B (binary)."
  type        = string
  default     = "S"

  validation {
    condition     = contains(["S", "N", "B"], var.hash_key_type)
    error_message = "Hash key type must be one of: S (string), N (number), B (binary)."
  }
}

# -----------------------------------------------------------------------------
# Optional Primary Key Configuration
# -----------------------------------------------------------------------------

variable "range_key" {
  description = "The attribute to use as the range (sort) key. Must be defined in attributes if specified."
  type        = string
  default     = null
}

variable "range_key_type" {
  description = "Range key attribute type. Valid values: S (string), N (number), B (binary)."
  type        = string
  default     = "S"

  validation {
    condition     = contains(["S", "N", "B"], var.range_key_type)
    error_message = "Range key type must be one of: S (string), N (number), B (binary)."
  }
}

variable "attributes" {
  description = <<-EOT
    Additional attributes used for Global Secondary Indexes (GSI) or Local Secondary Indexes (LSI).
    Each attribute must have a name and type (S, N, or B).
    Note: Hash key and range key are automatically included and should not be listed here.
  EOT
  type = list(object({
    name = string
    type = string
  }))
  default = []

  validation {
    condition = alltrue([
      for attr in var.attributes :
      contains(["S", "N", "B"], attr.type)
    ])
    error_message = "Attribute type must be one of: S (string), N (number), B (binary)."
  }
}

# -----------------------------------------------------------------------------
# Billing Configuration
# -----------------------------------------------------------------------------

variable "billing_mode" {
  description = <<-EOT
    Billing mode for the table. Valid values: PROVISIONED or PAY_PER_REQUEST.
    - PROVISIONED: You specify read/write capacity units (supports auto-scaling)
    - PAY_PER_REQUEST: Pay only for what you use (on-demand pricing, no capacity planning needed)
  EOT
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "Billing mode must be either PROVISIONED or PAY_PER_REQUEST."
  }
}

variable "read_capacity" {
  description = "The number of read units for the table. Only used when billing_mode is PROVISIONED."
  type        = number
  default     = 5

  validation {
    condition     = var.read_capacity >= 1
    error_message = "Read capacity must be at least 1."
  }
}

variable "write_capacity" {
  description = "The number of write units for the table. Only used when billing_mode is PROVISIONED."
  type        = number
  default     = 5

  validation {
    condition     = var.write_capacity >= 1
    error_message = "Write capacity must be at least 1."
  }
}

variable "table_class" {
  description = <<-EOT
    Storage class of the table. Valid values: STANDARD or STANDARD_INFREQUENT_ACCESS.
    - STANDARD: Default storage class for frequently accessed data
    - STANDARD_INFREQUENT_ACCESS: Lower storage cost for infrequently accessed data
  EOT
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "STANDARD_INFREQUENT_ACCESS"], var.table_class)
    error_message = "Table class must be either STANDARD or STANDARD_INFREQUENT_ACCESS."
  }
}

# -----------------------------------------------------------------------------
# Auto Scaling Configuration (PROVISIONED mode only)
# -----------------------------------------------------------------------------

variable "enable_autoscaling" {
  description = "Enable auto-scaling for read and write capacity. Only applicable when billing_mode is PROVISIONED."
  type        = bool
  default     = true
}

variable "autoscaling_read_min_capacity" {
  description = "Minimum read capacity for auto-scaling. Only used when billing_mode is PROVISIONED and enable_autoscaling is true."
  type        = number
  default     = 5

  validation {
    condition     = var.autoscaling_read_min_capacity >= 1
    error_message = "Minimum read capacity must be at least 1."
  }
}

variable "autoscaling_read_max_capacity" {
  description = "Maximum read capacity for auto-scaling. Only used when billing_mode is PROVISIONED and enable_autoscaling is true."
  type        = number
  default     = 100

  validation {
    condition     = var.autoscaling_read_max_capacity >= 1
    error_message = "Maximum read capacity must be at least 1."
  }
}

variable "autoscaling_read_target_value" {
  description = "Target utilization percentage for read capacity auto-scaling (1-100). Only used when billing_mode is PROVISIONED and enable_autoscaling is true."
  type        = number
  default     = 70

  validation {
    condition     = var.autoscaling_read_target_value >= 1 && var.autoscaling_read_target_value <= 100
    error_message = "Target value must be between 1 and 100."
  }
}

variable "autoscaling_write_min_capacity" {
  description = "Minimum write capacity for auto-scaling. Only used when billing_mode is PROVISIONED and enable_autoscaling is true."
  type        = number
  default     = 5

  validation {
    condition     = var.autoscaling_write_min_capacity >= 1
    error_message = "Minimum write capacity must be at least 1."
  }
}

variable "autoscaling_write_max_capacity" {
  description = "Maximum write capacity for auto-scaling. Only used when billing_mode is PROVISIONED and enable_autoscaling is true."
  type        = number
  default     = 100

  validation {
    condition     = var.autoscaling_write_max_capacity >= 1
    error_message = "Maximum write capacity must be at least 1."
  }
}

variable "autoscaling_write_target_value" {
  description = "Target utilization percentage for write capacity auto-scaling (1-100). Only used when billing_mode is PROVISIONED and enable_autoscaling is true."
  type        = number
  default     = 70

  validation {
    condition     = var.autoscaling_write_target_value >= 1 && var.autoscaling_write_target_value <= 100
    error_message = "Target value must be between 1 and 100."
  }
}

# -----------------------------------------------------------------------------
# Security Configuration
# -----------------------------------------------------------------------------

variable "kms_key_arn" {
  description = <<-EOT
    ARN of the KMS key to use for server-side encryption.
    - If specified: Uses customer-managed KMS key (SSE-KMS)
    - If null: Uses AWS owned key (default encryption)
    Note: Using customer-managed KMS keys incurs additional costs.
  EOT
  type        = string
  default     = null
}

variable "point_in_time_recovery_enabled" {
  description = <<-EOT
    Enable point-in-time recovery (PITR) for the table. Recommended for production tables.
    PITR provides continuous backups for the last 35 days and allows restore to any point in that timeframe.
  EOT
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# DynamoDB Streams Configuration
# -----------------------------------------------------------------------------

variable "stream_enabled" {
  description = <<-EOT
    Enable DynamoDB Streams for the table. Streams capture item-level changes.
    Useful for triggering Lambda functions, cross-region replication, or maintaining aggregates.
  EOT
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = <<-EOT
    Type of data written to the stream. Only used when stream_enabled is true.
    Valid values:
    - KEYS_ONLY: Only the key attributes of modified items
    - NEW_IMAGE: Entire item after modification
    - OLD_IMAGE: Entire item before modification
    - NEW_AND_OLD_IMAGES: Both new and old images of the item
  EOT
  type        = string
  default     = "NEW_AND_OLD_IMAGES"

  validation {
    condition     = contains(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"], var.stream_view_type)
    error_message = "Stream view type must be one of: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES."
  }
}

# -----------------------------------------------------------------------------
# Time To Live (TTL) Configuration
# -----------------------------------------------------------------------------

variable "ttl_enabled" {
  description = "Enable Time To Live (TTL) for automatic item expiration. Only used when ttl_attribute_name is specified."
  type        = bool
  default     = true
}

variable "ttl_attribute_name" {
  description = <<-EOT
    Name of the table attribute to use for TTL. Items with a timestamp in this attribute will be automatically deleted after expiration.
    The attribute must contain a Unix timestamp (in seconds). Set to null to disable TTL.
  EOT
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Global Secondary Indexes (GSI)
# -----------------------------------------------------------------------------

variable "global_secondary_indexes" {
  description = <<-EOT
    List of Global Secondary Indexes (GSI) for the table.
    Each GSI allows querying the table using different key attributes.
    GSI can have different partition key (hash_key) and optional sort key (range_key) from the base table.
    
    Required fields:
    - name: Name of the GSI
    - hash_key: Partition key for the GSI (must be defined in attributes)
    - projection_type: Attributes to project (KEYS_ONLY, INCLUDE, or ALL)
    
    Optional fields:
    - range_key: Sort key for the GSI (must be defined in attributes if specified)
    - non_key_attributes: List of attributes to include when projection_type is INCLUDE
    - read_capacity: Read capacity for GSI (PROVISIONED mode only)
    - write_capacity: Write capacity for GSI (PROVISIONED mode only)
    - enable_autoscaling: Enable autoscaling for this GSI (default: true, PROVISIONED mode only)
    - autoscaling_read_min_capacity: Min read capacity for autoscaling
    - autoscaling_read_max_capacity: Max read capacity for autoscaling
    - autoscaling_write_min_capacity: Min write capacity for autoscaling
    - autoscaling_write_max_capacity: Max write capacity for autoscaling
  EOT
  type = list(object({
    name                           = string
    hash_key                       = string
    range_key                      = optional(string)
    projection_type                = string
    non_key_attributes             = optional(list(string))
    read_capacity                  = optional(number)
    write_capacity                 = optional(number)
    enable_autoscaling             = optional(bool, true)
    autoscaling_read_min_capacity  = optional(number)
    autoscaling_read_max_capacity  = optional(number)
    autoscaling_write_min_capacity = optional(number)
    autoscaling_write_max_capacity = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for gsi in var.global_secondary_indexes :
      contains(["KEYS_ONLY", "INCLUDE", "ALL"], gsi.projection_type)
    ])
    error_message = "GSI projection_type must be one of: KEYS_ONLY, INCLUDE, ALL."
  }

  validation {
    condition = alltrue([
      for gsi in var.global_secondary_indexes :
      gsi.projection_type != "INCLUDE" || (gsi.non_key_attributes != null && length(gsi.non_key_attributes) > 0)
    ])
    error_message = "When projection_type is INCLUDE, non_key_attributes must be specified."
  }
}

# -----------------------------------------------------------------------------
# Local Secondary Indexes (LSI)
# -----------------------------------------------------------------------------

variable "local_secondary_indexes" {
  description = <<-EOT
    List of Local Secondary Indexes (LSI) for the table.
    LSI must have the same partition key as the base table but different sort key.
    LSI can only be created at table creation time and cannot be modified later.
    
    Required fields:
    - name: Name of the LSI
    - range_key: Sort key for the LSI (must be defined in attributes, different from table's range_key)
    - projection_type: Attributes to project (KEYS_ONLY, INCLUDE, or ALL)
    
    Optional fields:
    - non_key_attributes: List of attributes to include when projection_type is INCLUDE
  EOT
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = optional(list(string))
  }))
  default = []

  validation {
    condition = alltrue([
      for lsi in var.local_secondary_indexes :
      contains(["KEYS_ONLY", "INCLUDE", "ALL"], lsi.projection_type)
    ])
    error_message = "LSI projection_type must be one of: KEYS_ONLY, INCLUDE, ALL."
  }

  validation {
    condition = alltrue([
      for lsi in var.local_secondary_indexes :
      lsi.projection_type != "INCLUDE" || (lsi.non_key_attributes != null && length(lsi.non_key_attributes) > 0)
    ])
    error_message = "When projection_type is INCLUDE, non_key_attributes must be specified."
  }
}

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to all resources. Use this to add consistent tagging across your infrastructure."
  type        = map(string)
  default     = {}
}
