# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "identifier" {
  description = "Replica identifier. Must match the existing DB instance identifier when importing."
  type        = string
}

variable "source_db_identifier" {
  description = "Identifier of the primary DB instance to replicate from."
  type        = string
}

variable "instance_class" {
  description = "DB instance class for the read replica."
  type        = string
}

# -----------------------------------------------------------------------------
# Storage Configuration
# -----------------------------------------------------------------------------

variable "allocated_storage" {
  description = "Allocated storage (GiB). Optional for replicas; set to null to inherit from primary."
  type        = number
  default     = null
}

variable "max_allocated_storage" {
  description = "Max allocated storage for autoscaling (0 = disabled)."
  type        = number
  default     = 0
}

variable "storage_type" {
  description = "Storage type (gp2, gp3, io1, io2, standard)."
  type        = string
  default     = "gp3"
}

variable "iops" {
  description = "Provisioned IOPS (required for io1/io2)."
  type        = number
  default     = null
}

variable "storage_throughput" {
  description = "Storage throughput (MB/s) for gp3."
  type        = number
  default     = null
}

variable "storage_encrypted" {
  description = "Whether storage is encrypted."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ARN for encryption."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------

variable "vpc_security_group_ids" {
  description = "Security group IDs for the replica."
  type        = list(string)
  default     = null
}

variable "publicly_accessible" {
  description = "Whether the replica is publicly accessible."
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "Availability zone for the replica."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Parameter Group
# -----------------------------------------------------------------------------

variable "parameter_group_name" {
  description = "Parameter group name for the replica."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Monitoring & Logging
# -----------------------------------------------------------------------------

variable "monitoring_interval" {
  description = "Enhanced monitoring interval (0, 1, 5, 10, 15, 30, 60)."
  type        = number
  default     = 0
}

variable "monitoring_role_arn" {
  description = "IAM role ARN for enhanced monitoring."
  type        = string
  default     = null
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights."
  type        = bool
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = "KMS key ARN for Performance Insights."
  type        = string
  default     = null
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention period (7 or 731)."
  type        = number
  default     = 7
}

# -----------------------------------------------------------------------------
# Maintenance & Protection
# -----------------------------------------------------------------------------

variable "auto_minor_version_upgrade" {
  description = "Auto minor version upgrades."
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Apply changes immediately or during maintenance window."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection."
  type        = bool
  default     = true
}

variable "copy_tags_to_snapshot" {
  description = "Copy tags to snapshots."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on destroy."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "tags" {
  description = "Tags to apply to the replica."
  type        = map(string)
  default     = {}
}
