# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "identifier" {
  description = "The name of the RDS instance. Must be unique within the AWS account and region."
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

variable "engine" {
  description = <<-EOT
    Database engine type. Common values:
    - mysql: MySQL Community Edition
    - postgres: PostgreSQL
    - mariadb: MariaDB
    - oracle-ee, oracle-se2: Oracle Database
    - sqlserver-ee, sqlserver-se, sqlserver-ex, sqlserver-web: SQL Server
    - aurora-mysql, aurora-postgresql: Aurora (use Aurora module instead for production)
  EOT
  type        = string

  validation {
    condition = contains([
      "mysql", "postgres", "mariadb",
      "oracle-ee", "oracle-se2", "oracle-se1", "oracle-se",
      "sqlserver-ee", "sqlserver-se", "sqlserver-ex", "sqlserver-web",
      "aurora-mysql", "aurora-postgresql", "aurora"
    ], var.engine)
    error_message = "Engine must be a valid RDS database engine type."
  }
}

variable "engine_version" {
  description = "Version number of the database engine to use. Refer to AWS documentation for available versions per engine."
  type        = string
}

variable "instance_class" {
  description = <<-EOT
    The instance type of the RDS instance. Examples:
    - db.t3.micro, db.t3.small: Burstable performance (dev/test)
    - db.t4g.micro, db.t4g.small: ARM-based burstable (cost-optimized)
    - db.m5.large, db.m5.xlarge: General purpose (production)
    - db.r5.large, db.r5.xlarge: Memory optimized (high-performance)
    See: https://aws.amazon.com/rds/instance-types/
  EOT
  type        = string
}

variable "allocated_storage" {
  description = <<-EOT
    The allocated storage in gibibytes (GiB).
    - General Purpose (gp2/gp3): 20 GiB to 64 TiB
    - Provisioned IOPS (io1): 100 GiB to 64 TiB
    - Magnetic: 5 GiB to 3 TiB
  EOT
  type        = number

  validation {
    condition     = var.allocated_storage >= 5
    error_message = "Allocated storage must be at least 5 GiB."
  }
}

variable "master_username" {
  description = "Username for the master DB user. Cannot be changed after creation."
  type        = string
  sensitive   = true
}

variable "master_password" {
  description = "Password for the master DB user. Required unless using snapshot_identifier. Must meet database engine requirements."
  type        = string
  sensitive   = true
  default     = null
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------

variable "subnet_ids" {
  description = "List of VPC subnet IDs for the DB subnet group. Required for Multi-AZ deployments."
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID where the RDS instance will be created. Required if create_security_group is true."
  type        = string
  default     = null
}

variable "db_subnet_group_name" {
  description = "Name of DB subnet group. If null and create_db_subnet_group is true, one will be created."
  type        = string
  default     = null
}

variable "create_db_subnet_group" {
  description = "Whether to create a DB subnet group. Set to false if using an existing subnet group."
  type        = bool
  default     = true
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs to associate with the instance. If null and create_security_group is true, a security group will be created."
  type        = list(string)
  default     = null
}

variable "create_security_group" {
  description = "Whether to create a security group for the RDS instance."
  type        = bool
  default     = true
}

variable "allowed_security_groups" {
  description = "Map of security group IDs allowed to access the database. Key is a description, value is the security group ID."
  type        = map(string)
  default     = {}
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the database. Use sparingly for security reasons."
  type        = list(string)
  default     = []
}

variable "publicly_accessible" {
  description = "Whether the DB instance is publicly accessible. Set to false for production databases."
  type        = bool
  default     = false
}

variable "port" {
  description = "The port on which the DB accepts connections. Default ports: MySQL=3306, PostgreSQL=5432, Oracle=1521, SQL Server=1433."
  type        = number
  default     = null
}

# -----------------------------------------------------------------------------
# Storage Configuration
# -----------------------------------------------------------------------------

variable "storage_type" {
  description = <<-EOT
    Storage type for the DB instance. Valid values:
    - gp2: General Purpose SSD (baseline 3 IOPS/GiB, burst to 3000 IOPS)
    - gp3: General Purpose SSD (baseline 3000 IOPS, configurable)
    - io1: Provisioned IOPS SSD (high performance, specify iops)
    - io2: Provisioned IOPS SSD (higher durability than io1)
    - standard: Magnetic storage (legacy, not recommended)
  EOT
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "standard"], var.storage_type)
    error_message = "Storage type must be one of: gp2, gp3, io1, io2, standard."
  }
}

variable "max_allocated_storage" {
  description = <<-EOT
    The upper limit of storage (GiB) to which RDS can automatically scale.
    Set to 0 to disable storage autoscaling (disabled by default).
    For production databases with growing data, set this to a value higher than allocated_storage to enable autoscaling.
  EOT
  type        = number
  default     = 0
}

variable "storage_encrypted" {
  description = "Whether to enable storage encryption. Highly recommended for production databases."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "ARN of the KMS key to use for encryption. If not specified, uses the default RDS KMS key."
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
# Database Configuration
# -----------------------------------------------------------------------------

variable "database_name" {
  description = "The name of the database to create when the DB instance is created. If null, no initial database is created."
  type        = string
  default     = null
}

variable "parameter_group_name" {
  description = "Name of the DB parameter group to associate with this instance. If not specified, uses the default parameter group for the engine version."
  type        = string
  default     = null
}

variable "option_group_name" {
  description = "Name of the DB option group to associate with this instance. Only applicable for Oracle and SQL Server."
  type        = string
  default     = null
}

variable "character_set_name" {
  description = "The character set name for Oracle DB instances. Not applicable to other engines."
  type        = string
  default     = null
}

variable "timezone" {
  description = "Time zone of the DB instance. Only applicable for SQL Server."
  type        = string
  default     = null
}

variable "license_model" {
  description = <<-EOT
    License model for commercial databases. Values:
    - license-included: License is included (SQL Server)
    - bring-your-own-license: BYOL (Oracle, SQL Server)
    - general-public-license: Open source databases
  EOT
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Availability & Reliability
# -----------------------------------------------------------------------------

variable "multi_az" {
  description = "Whether to enable Multi-AZ deployment for high availability. Recommended for production databases."
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "The AZ for the RDS instance. Only used when multi_az is false."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Backup Configuration
# -----------------------------------------------------------------------------

variable "backup_retention_period" {
  description = "The days to retain automated backups. Valid range: 0-35. Set to 0 to disable automated backups."
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

variable "backup_window" {
  description = "The daily time range during which automated backups are created (UTC). Format: hh24:mi-hh24:mi. Must not overlap with maintenance_window."
  type        = string
  default     = null
}

variable "maintenance_window" {
  description = "The window to perform maintenance (UTC). Format: ddd:hh24:mi-ddd:hh24:mi. Must not overlap with backup_window."
  type        = string
  default     = null
}

variable "copy_tags_to_snapshot" {
  description = "Whether to copy all instance tags to snapshots."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot when the DB instance is deleted. Set to false for production databases."
  type        = bool
  default     = false
}

variable "final_snapshot_identifier" {
  description = "The name of the final snapshot when the DB instance is deleted. If not provided and skip_final_snapshot is false, a name will be auto-generated."
  type        = string
  default     = null
}

variable "snapshot_identifier" {
  description = "Identifier of a DB snapshot to restore from. Used to create a new DB instance from a snapshot."
  type        = string
  default     = null
}

variable "restore_to_point_in_time" {
  description = <<-EOT
    Configuration block for restoring to a point in time. Used to create a new DB instance from an automated backup.
    Attributes:
    - source_db_instance_identifier: Identifier of the source DB instance
    - restore_time: The date and time to restore from (RFC3339 format)
    - use_latest_restorable_time: Whether to restore to the latest restorable time (default: false)
  EOT
  type = object({
    source_db_instance_identifier = optional(string)
    restore_time                  = optional(string)
    use_latest_restorable_time    = optional(bool)
  })
  default = null
}

# -----------------------------------------------------------------------------
# Monitoring & Logging
# -----------------------------------------------------------------------------

variable "enabled_cloudwatch_logs_exports" {
  description = <<-EOT
    List of log types to export to CloudWatch. Valid values depend on engine:
    - MySQL/MariaDB: audit, error, general, slowquery
    - PostgreSQL: postgresql, upgrade
    - Oracle: alert, audit, trace, listener
    - SQL Server: agent, error
  EOT
  type        = list(string)
  default     = []
}

variable "monitoring_interval" {
  description = <<-EOT
    The interval, in seconds, between points when Enhanced Monitoring metrics are collected.
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
  description = "ARN of the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch. Required when monitoring_interval > 0."
  type        = string
  default     = null
}

variable "performance_insights_enabled" {
  description = "Whether to enable Performance Insights. Provides advanced database performance monitoring."
  type        = bool
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = "ARN of the KMS key to encrypt Performance Insights data. If not specified, uses the default RDS KMS key."
  type        = string
  default     = null
}

variable "performance_insights_retention_period" {
  description = "Amount of time in days to retain Performance Insights data. Valid values: 7, 731 (2 years). Default is 7."
  type        = number
  default     = 7

  validation {
    condition     = contains([7, 731], var.performance_insights_retention_period)
    error_message = "Performance Insights retention period must be either 7 or 731 days."
  }
}

# -----------------------------------------------------------------------------
# Upgrade & Maintenance Configuration
# -----------------------------------------------------------------------------

variable "auto_minor_version_upgrade" {
  description = "Whether to automatically upgrade minor engine versions during maintenance windows."
  type        = bool
  default     = true
}

variable "allow_major_version_upgrade" {
  description = "Whether to allow major version upgrades. Use with caution as this may cause downtime."
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Whether to apply changes immediately or during the next maintenance window. Use with caution in production."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Deletion Protection
# -----------------------------------------------------------------------------

variable "deletion_protection" {
  description = "Whether to enable deletion protection. Prevents accidental deletion of the database."
  type        = bool
  default     = false
}

variable "delete_automated_backups" {
  description = "Whether to remove automated backups immediately after the DB instance is deleted."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# IAM Authentication
# -----------------------------------------------------------------------------

variable "iam_database_authentication_enabled" {
  description = "Whether to enable IAM database authentication. Allows authentication using AWS IAM credentials."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Read Replicas
# -----------------------------------------------------------------------------

variable "read_replicas" {
  description = <<-EOT
    Map of read replica configurations. Key is a unique identifier for the replica.
    Each replica can override the following settings from the primary instance:
    - instance_class: Instance type for the replica
    - allocated_storage: Storage size (must be >= primary)
    - max_allocated_storage: Max storage autoscaling limit
    - storage_type: Storage type (gp2, gp3, io1, io2)
    - iops: Provisioned IOPS
    - storage_throughput: Storage throughput for gp3
    - publicly_accessible: Whether replica is publicly accessible
    - availability_zone: AZ for the replica
    - monitoring_interval: Enhanced monitoring interval
    - monitoring_role_arn: IAM role for enhanced monitoring
    - performance_insights_enabled: Enable Performance Insights
    - performance_insights_kms_key_id: KMS key for PI encryption
    - performance_insights_retention_period: PI data retention period
    - auto_minor_version_upgrade: Auto upgrade minor versions
    - apply_immediately: Apply changes immediately
    - tags: Additional tags for the replica
  EOT
  type = map(object({
    instance_class                        = optional(string)
    allocated_storage                     = optional(number)
    max_allocated_storage                 = optional(number)
    storage_type                          = optional(string)
    iops                                  = optional(number)
    storage_throughput                    = optional(number)
    publicly_accessible                   = optional(bool)
    availability_zone                     = optional(string)
    monitoring_interval                   = optional(number)
    monitoring_role_arn                   = optional(string)
    performance_insights_enabled          = optional(bool)
    performance_insights_kms_key_id       = optional(string)
    performance_insights_retention_period = optional(number)
    auto_minor_version_upgrade            = optional(bool)
    apply_immediately                     = optional(bool)
    tags                                  = optional(map(string))
  }))
  default = {}
}

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
