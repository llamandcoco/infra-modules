# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "storage_account_name" {
  description = "Name of the Azure Storage Account. Must be globally unique, between 3-24 characters, and contain only lowercase letters and numbers."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be between 3-24 characters, lowercase letters and numbers only."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group where the storage account will be created."
  type        = string
}

variable "location" {
  description = "Azure region where the storage account will be created (e.g., 'eastus', 'westeurope')."
  type        = string
}

variable "container_name" {
  description = "Name of the blob container. Must be between 3-63 characters, lowercase letters, numbers, and hyphens only."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{1,61}[a-z0-9])?$", var.container_name))
    error_message = "Container name must be between 3-63 characters, start and end with lowercase letter or number, and contain only lowercase letters, numbers, and hyphens."
  }
}

# -----------------------------------------------------------------------------
# Storage Account Configuration
# -----------------------------------------------------------------------------

variable "account_tier" {
  description = "Storage account tier. Standard for general-purpose v2, Premium for high-performance scenarios."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be either 'Standard' or 'Premium'."
  }
}

variable "replication_type" {
  description = "Storage account replication type. Options: LRS (Locally Redundant), GRS (Geo-Redundant), RAGRS (Read-Access Geo-Redundant), ZRS (Zone-Redundant), GZRS (Geo-Zone-Redundant), RAGZRS (Read-Access Geo-Zone-Redundant)."
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.replication_type)
    error_message = "Replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "account_kind" {
  description = "Storage account kind. StorageV2 is recommended for most scenarios."
  type        = string
  default     = "StorageV2"

  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.account_kind)
    error_message = "Account kind must be one of: BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2."
  }
}

# -----------------------------------------------------------------------------
# Security Configuration
# -----------------------------------------------------------------------------

variable "enable_https_traffic_only" {
  description = "Enforce HTTPS-only traffic to the storage account. Recommended to keep enabled for security."
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "Minimum TLS version for requests to the storage account."
  type        = string
  default     = "TLS1_2"

  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "Minimum TLS version must be one of: TLS1_0, TLS1_1, TLS1_2."
  }
}

variable "allow_public_access" {
  description = "Allow public access to blobs. Recommended to keep disabled (false) for security."
  type        = bool
  default     = false
}

variable "infrastructure_encryption_enabled" {
  description = "Enable infrastructure encryption for additional security layer. Recommended for sensitive data."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Container Configuration
# -----------------------------------------------------------------------------

variable "container_access_type" {
  description = "Access type for the container. Options: 'private' (no public access), 'blob' (public read for blobs only), 'container' (public read for container and blobs)."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["private", "blob", "container"], var.container_access_type)
    error_message = "Container access type must be one of: private, blob, container."
  }
}

variable "container_metadata" {
  description = "Metadata to assign to the container as key-value pairs."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Data Protection Configuration
# -----------------------------------------------------------------------------

variable "versioning_enabled" {
  description = "Enable blob versioning to protect against accidental deletion and provide object history. Recommended for production."
  type        = bool
  default     = true
}

variable "blob_soft_delete_retention_days" {
  description = "Number of days to retain deleted blobs. Set to 0 to disable soft delete. Recommended: 7-30 days."
  type        = number
  default     = 7

  validation {
    condition     = var.blob_soft_delete_retention_days >= 0 && var.blob_soft_delete_retention_days <= 365
    error_message = "Blob soft delete retention days must be between 0 and 365."
  }
}

variable "container_soft_delete_retention_days" {
  description = "Number of days to retain deleted containers. Set to 0 to disable soft delete. Recommended: 7-30 days."
  type        = number
  default     = 7

  validation {
    condition     = var.container_soft_delete_retention_days >= 0 && var.container_soft_delete_retention_days <= 365
    error_message = "Container soft delete retention days must be between 0 and 365."
  }
}

variable "change_feed_enabled" {
  description = "Enable change feed to track create, update, and delete changes to blobs. Useful for auditing and event-driven architectures."
  type        = bool
  default     = false
}

variable "last_access_time_enabled" {
  description = "Enable last access time tracking for lifecycle management policies based on access patterns."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Network Security Configuration
# -----------------------------------------------------------------------------

variable "network_rules_enabled" {
  description = "Enable network rules to restrict access to the storage account."
  type        = bool
  default     = false
}

variable "network_rules_default_action" {
  description = "Default action for network rules. 'Deny' blocks all traffic except allowed IPs/VNets. 'Allow' permits all traffic."
  type        = string
  default     = "Deny"

  validation {
    condition     = contains(["Allow", "Deny"], var.network_rules_default_action)
    error_message = "Network rules default action must be either 'Allow' or 'Deny'."
  }
}

variable "network_rules_bypass" {
  description = "Services that can bypass network rules. Options: 'AzureServices', 'Logging', 'Metrics', 'None'."
  type        = list(string)
  default     = ["AzureServices"]

  validation {
    condition = alltrue([
      for service in var.network_rules_bypass :
      contains(["AzureServices", "Logging", "Metrics", "None"], service)
    ])
    error_message = "Each bypass value must be one of: AzureServices, Logging, Metrics, None."
  }
}

variable "network_rules_ip_rules" {
  description = "List of public IP addresses or CIDR ranges that can access the storage account."
  type        = list(string)
  default     = []
}

variable "network_rules_subnet_ids" {
  description = "List of virtual network subnet IDs that can access the storage account."
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Encryption Configuration
# -----------------------------------------------------------------------------

variable "customer_managed_key_vault_key_id" {
  description = "Key Vault Key ID for customer-managed encryption keys. If not specified, Microsoft-managed keys will be used."
  type        = string
  default     = null
}

variable "customer_managed_key_user_assigned_identity_id" {
  description = "User-assigned managed identity ID for accessing the customer-managed key. If not specified, system-assigned identity will be used."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Lifecycle Management Configuration
# -----------------------------------------------------------------------------

variable "lifecycle_rules" {
  description = <<-EOT
    List of lifecycle management rules for optimizing storage costs.
    Each rule can include:
    - name: Unique name for the rule
    - enabled: Whether the rule is active
    - prefix_match: List of blob prefixes to match (optional)
    - blob_types: Types of blobs to apply the rule to (e.g., ["blockBlob"])
    - base_blob_actions: Actions for current versions
      - tier_to_cool_after_days: Days to tier to cool storage
      - tier_to_cool_after_last_access_days: Days since last access to tier to cool
      - tier_to_archive_after_days: Days to tier to archive storage
      - tier_to_archive_after_last_access_days: Days since last access to tier to archive
      - delete_after_days: Days to delete blobs
      - delete_after_last_access_days: Days since last access to delete
    - snapshot_actions: Actions for snapshots
    - version_actions: Actions for older versions
  EOT
  type = list(object({
    name         = string
    enabled      = bool
    prefix_match = optional(list(string), [])
    blob_types   = list(string)
    base_blob_actions = optional(object({
      tier_to_cool_after_days                = optional(number)
      tier_to_cool_after_last_access_days    = optional(number)
      tier_to_archive_after_days             = optional(number)
      tier_to_archive_after_last_access_days = optional(number)
      delete_after_days                      = optional(number)
      delete_after_last_access_days          = optional(number)
    }))
    snapshot_actions = optional(object({
      tier_to_cool_after_days    = optional(number)
      tier_to_archive_after_days = optional(number)
      delete_after_days          = optional(number)
    }))
    version_actions = optional(object({
      tier_to_cool_after_days    = optional(number)
      tier_to_archive_after_days = optional(number)
      delete_after_days          = optional(number)
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules :
      length(rule.blob_types) > 0
    ])
    error_message = "Each lifecycle rule must specify at least one blob type."
  }
}

# -----------------------------------------------------------------------------
# General Configuration
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to all resources. Use this to add consistent tagging across your infrastructure."
  type        = map(string)
  default     = {}
}
