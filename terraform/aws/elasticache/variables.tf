# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "cluster_id" {
  description = "Unique identifier for the ElastiCache cluster. Must be lowercase alphanumeric and hyphens only."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.cluster_id))
    error_message = "Cluster ID must only contain lowercase alphanumeric characters and hyphens."
  }

  validation {
    condition     = length(var.cluster_id) >= 1 && length(var.cluster_id) <= 40
    error_message = "Cluster ID must be between 1 and 40 characters long."
  }
}

variable "engine" {
  description = "Cache engine to use. Valid values: redis or memcached."
  type        = string

  validation {
    condition     = contains(["redis", "memcached"], var.engine)
    error_message = "Engine must be either 'redis' or 'memcached'."
  }
}

variable "node_type" {
  description = "Instance type for cache nodes (e.g., cache.t3.micro, cache.r6g.large)."
  type        = string
}

variable "subnet_ids" {
  description = "List of VPC subnet IDs for the cache subnet group. Required unless subnet_group_name is specified."
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the ElastiCache cluster."
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Engine Configuration
# -----------------------------------------------------------------------------

variable "engine_version" {
  description = "Version number of the cache engine. For Redis, use 6.x or 7.x. For Memcached, use 1.6.x."
  type        = string
  default     = null
}

variable "port" {
  description = "Port number on which the cache accepts connections. Default: 6379 for Redis, 11211 for Memcached."
  type        = number
  default     = null

  validation {
    condition     = var.port == null ? true : (var.port >= 1 && var.port <= 65535)
    error_message = "Port must be between 1 and 65535."
  }
}

variable "parameter_group_family" {
  description = "Parameter group family for the cache engine (e.g., redis7, redis6.x, memcached1.6). If null, uses redis7 for Redis or memcached1.6 for Memcached."
  type        = string
  default     = null
}

variable "parameters" {
  description = "List of cache parameters to apply. Each parameter must have a name and value."
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Cluster Configuration
# -----------------------------------------------------------------------------

variable "num_cache_nodes" {
  description = <<-EOT
    Number of cache nodes in the cluster.
    - For Redis: Number of replica nodes + 1 primary (minimum 2 for automatic failover)
    - For Memcached: Total number of nodes in the cluster
  EOT
  type        = number
  default     = 1

  validation {
    condition     = var.num_cache_nodes >= 1
    error_message = "Number of cache nodes must be at least 1."
  }
}

variable "description" {
  description = "Description for the replication group (Redis only)."
  type        = string
  default     = "Managed by Terraform"
}

# -----------------------------------------------------------------------------
# High Availability Configuration (Redis only)
# -----------------------------------------------------------------------------

variable "automatic_failover_enabled" {
  description = <<-EOT
    Enable automatic failover for Redis. Requires at least 2 nodes and multi_az_enabled.
    Automatically promotes a replica to primary if the primary fails.
  EOT
  type        = bool
  default     = false
}

variable "multi_az_enabled" {
  description = <<-EOT
    Enable Multi-AZ for Redis. Distributes replica nodes across multiple availability zones.
    Required for automatic failover.
  EOT
  type        = bool
  default     = false
}

variable "availability_zones" {
  description = "List of availability zones for Memcached cluster nodes. Only used when num_cache_nodes > 1 for Memcached."
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Backup Configuration (Redis only)
# -----------------------------------------------------------------------------

variable "snapshot_retention_limit" {
  description = <<-EOT
    Number of days to retain automatic snapshots (Redis only).
    Set to 0 to disable automated backups. Maximum: 35 days.
  EOT
  type        = number
  default     = 7

  validation {
    condition     = var.snapshot_retention_limit >= 0 && var.snapshot_retention_limit <= 35
    error_message = "Snapshot retention limit must be between 0 and 35 days."
  }
}

variable "snapshot_window" {
  description = <<-EOT
    Daily time range during which ElastiCache begins taking daily snapshots (Redis only).
    Format: HH:MM-HH:MM in UTC (e.g., '03:00-05:00'). Must not overlap with maintenance_window.
  EOT
  type        = string
  default     = "03:00-05:00"
}

variable "final_snapshot_identifier" {
  description = "Name of the final snapshot to create when the cluster is deleted (Redis only). If null, no final snapshot is created."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Maintenance Configuration
# -----------------------------------------------------------------------------

variable "maintenance_window" {
  description = <<-EOT
    Weekly time range during which system maintenance can occur.
    Format: ddd:HH:MM-ddd:HH:MM in UTC (e.g., 'sun:05:00-sun:09:00').
    Must not overlap with snapshot_window.
  EOT
  type        = string
  default     = "sun:05:00-sun:09:00"
}

variable "auto_minor_version_upgrade" {
  description = "Automatically upgrade to new minor versions during the maintenance window."
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = <<-EOT
    Apply changes immediately instead of during the next maintenance window.
    Use with caution as this may cause downtime.
  EOT
  type        = bool
  default     = false
}

variable "notification_topic_arn" {
  description = "ARN of an SNS topic to send ElastiCache notifications to (cluster events, failures, etc.)."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Security Configuration (Redis only)
# -----------------------------------------------------------------------------

variable "at_rest_encryption_enabled" {
  description = <<-EOT
    Enable encryption at rest for Redis data.
    Can only be enabled when creating a new cluster.
  EOT
  type        = bool
  default     = true
}

variable "transit_encryption_enabled" {
  description = <<-EOT
    Enable in-transit encryption (TLS) for Redis.
    Can only be enabled when creating a new cluster.
  EOT
  type        = bool
  default     = true
}

variable "auth_token" {
  description = <<-EOT
    Password used to access a password-protected Redis server.
    Only used when transit_encryption_enabled is true.
    Must be 16-128 alphanumeric characters.
  EOT
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition     = var.auth_token == null ? true : (length(var.auth_token) >= 16 && length(var.auth_token) <= 128)
    error_message = "Auth token must be between 16 and 128 characters long."
  }
}

variable "kms_key_id" {
  description = <<-EOT
    ARN of the KMS key to use for at-rest encryption.
    If not specified, uses the default AWS managed key for ElastiCache.
  EOT
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Logging Configuration (Redis only)
# -----------------------------------------------------------------------------

variable "log_delivery_configuration" {
  description = <<-EOT
    Log delivery configuration for Redis slow log and engine log.
    Each configuration must specify destination, destination_type, log_format, and log_type.
  EOT
  type = list(object({
    destination      = string
    destination_type = string
    log_format       = string
    log_type         = string
  }))
  default = []

  validation {
    condition = alltrue([
      for config in var.log_delivery_configuration :
      contains(["cloudwatch-logs", "kinesis-firehose"], config.destination_type)
    ])
    error_message = "Destination type must be either 'cloudwatch-logs' or 'kinesis-firehose'."
  }

  validation {
    condition = alltrue([
      for config in var.log_delivery_configuration :
      contains(["slow-log", "engine-log"], config.log_type)
    ])
    error_message = "Log type must be either 'slow-log' or 'engine-log'."
  }

  validation {
    condition = alltrue([
      for config in var.log_delivery_configuration :
      contains(["json", "text"], config.log_format)
    ])
    error_message = "Log format must be either 'json' or 'text'."
  }
}

# -----------------------------------------------------------------------------
# Existing Resource References
# -----------------------------------------------------------------------------

variable "subnet_group_name" {
  description = "Name of an existing ElastiCache subnet group to use. If null, a new subnet group will be created."
  type        = string
  default     = null
}

variable "parameter_group_name" {
  description = "Name of an existing ElastiCache parameter group to use. If null, a new parameter group will be created."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to all resources. Use this to add consistent tagging across your infrastructure."
  type        = map(string)
  default     = {}
}
