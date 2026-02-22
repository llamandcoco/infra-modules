# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "identifier" {
  description = "The name of the RDS replica instance. Must be unique within the AWS account and region."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.identifier))
    error_message = "Identifier must start with a letter and contain only lowercase letters, numbers, and hyphens."
  }

  validation {
    condition     = length(var.identifier) >= 1 && length(var.identifier) <= 63
    error_message = "Identifier must be between 1 and 63 characters long."
  }
}

variable "source_db_instance_identifier" {
  description = "The identifier of the source RDS instance to replicate. Must have automated backups enabled (backup_retention_period > 0)."
  type        = string
}

variable "instance_class" {
  description = <<-EOT
    The instance type of the RDS replica instance. Examples:
    - db.t3.micro, db.t3.small: Burstable performance (dev/test)
    - db.t4g.micro, db.t4g.small: ARM-based burstable (cost-optimized)
    - db.m5.large, db.m5.xlarge: General purpose (production)
    - db.r5.large, db.r5.xlarge: Memory optimized (high-performance)
    See: https://aws.amazon.com/rds/instance-types/
  EOT
  type        = string
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------

variable "vpc_id" {
  description = "VPC ID where the replica will be created. Required if create_security_group is true."
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs to associate with the replica. If null and create_security_group is true, a security group will be created."
  type        = list(string)
  default     = null
}

variable "create_security_group" {
  description = "Whether to create a security group for the RDS replica."
  type        = bool
  default     = true
}

variable "allowed_security_groups" {
  description = "Map of security group IDs allowed to access the replica. Key is a description, value is the security group ID."
  type        = map(string)
  default     = {}
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the replica. Use sparingly for security reasons."
  type        = list(string)
  default     = []
}

variable "egress_cidr_blocks" {
  description = "List of CIDR blocks for egress traffic. Set to empty list to disable egress rules."
  type        = list(string)
  default     = []
}

variable "publicly_accessible" {
  description = "Whether the replica is publicly accessible. Set to false for production databases."
  type        = bool
  default     = false
}

variable "port" {
  description = "The port on which the replica accepts connections. Inherits from source if null."
  type        = number
  default     = null
}

variable "availability_zone" {
  description = "The AZ for the replica instance."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Storage Configuration
# -----------------------------------------------------------------------------

variable "allocated_storage" {
  description = "The allocated storage in GiB for the replica. Must be >= the source instance's storage. If null, inherits from source."
  type        = number
  default     = null

  validation {
    condition     = var.allocated_storage == null ? true : var.allocated_storage >= 5
    error_message = "Allocated storage must be at least 5 GiB."
  }
}

variable "max_allocated_storage" {
  description = "The upper limit of storage (GiB) for autoscaling. Set to 0 to disable storage autoscaling."
  type        = number
  default     = 0
}

variable "storage_type" {
  description = <<-EOT
    Storage type for the replica. Valid values:
    - gp2: General Purpose SSD
    - gp3: General Purpose SSD (baseline 3000 IOPS, configurable)
    - io1: Provisioned IOPS SSD
    - io2: Provisioned IOPS SSD (higher durability)
    - standard: Magnetic storage (legacy)
  EOT
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "standard"], var.storage_type)
    error_message = "Storage type must be one of: gp2, gp3, io1, io2, standard."
  }
}

variable "kms_key_id" {
  description = "ARN of the KMS key to use for replica encryption. If not specified, uses the default RDS KMS key."
  type        = string
  default     = null
}

variable "iops" {
  description = "The amount of provisioned IOPS. Required when storage_type is io1 or io2."
  type        = number
  default     = null
}

variable "storage_throughput" {
  description = "Storage throughput value for gp3 storage type in MB/s. Valid range: 125-1000."
  type        = number
  default     = null
}

# -----------------------------------------------------------------------------
# Monitoring & Logging
# -----------------------------------------------------------------------------

variable "monitoring_interval" {
  description = <<-EOT
    The interval in seconds between Enhanced Monitoring metric collection.
    Valid values: 0, 1, 5, 10, 15, 30, 60. Set to 0 to disable.
    Requires monitoring_role_arn when enabled.
  EOT
  type        = number
  default     = 0

  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "Monitoring interval must be one of: 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "monitoring_role_arn" {
  description = "ARN of the IAM role for Enhanced Monitoring. Required when monitoring_interval > 0."
  type        = string
  default     = null
}

variable "performance_insights_enabled" {
  description = "Whether to enable Performance Insights on the replica."
  type        = bool
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = "ARN of the KMS key to encrypt Performance Insights data."
  type        = string
  default     = null
}

variable "performance_insights_retention_period" {
  description = "Amount of time in days to retain Performance Insights data. Valid values: 7, 731 (2 years)."
  type        = number
  default     = 7

  validation {
    condition     = contains([7, 731], var.performance_insights_retention_period)
    error_message = "Performance Insights retention period must be either 7 or 731 days."
  }
}

# -----------------------------------------------------------------------------
# Maintenance & Upgrade Configuration
# -----------------------------------------------------------------------------

variable "auto_minor_version_upgrade" {
  description = "Whether to automatically upgrade minor engine versions during maintenance windows."
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Whether to apply changes immediately or during the next maintenance window."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Deletion Protection
# -----------------------------------------------------------------------------

variable "deletion_protection" {
  description = "Whether to enable deletion protection. Prevents accidental deletion of the replica."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot when the replica is deleted."
  type        = bool
  default     = false
}

variable "copy_tags_to_snapshot" {
  description = "Whether to copy all instance tags to snapshots."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
