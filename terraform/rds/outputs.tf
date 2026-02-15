# -----------------------------------------------------------------------------
# RDS Instance Identification Outputs
# -----------------------------------------------------------------------------

output "db_instance_id" {
  description = "The RDS instance identifier. Use this for resource references and CLI operations."
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance. Use this for IAM policies and cross-account access configurations."
  value       = aws_db_instance.this.arn
}

output "db_instance_resource_id" {
  description = "The unique resource ID of the RDS instance. Used for CloudWatch metrics and performance insights."
  value       = aws_db_instance.this.resource_id
}

# -----------------------------------------------------------------------------
# Connection Information Outputs
# -----------------------------------------------------------------------------

output "db_instance_endpoint" {
  description = "The connection endpoint for the RDS instance in address:port format. Use this to connect applications to the database."
  value       = aws_db_instance.this.endpoint
}

output "db_instance_address" {
  description = "The hostname of the RDS instance. Use this as the host parameter in database connection strings."
  value       = aws_db_instance.this.address
}

output "db_instance_port" {
  description = "The port number on which the database accepts connections."
  value       = aws_db_instance.this.port
}

output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (for Route53 alias records)."
  value       = aws_db_instance.this.hosted_zone_id
}

# -----------------------------------------------------------------------------
# Database Configuration Outputs
# -----------------------------------------------------------------------------

output "db_instance_name" {
  description = "The database name (if one was created when the instance was created)."
  value       = aws_db_instance.this.db_name
}

output "db_instance_username" {
  description = "The master username for the database."
  value       = aws_db_instance.this.username
  sensitive   = true
}

output "db_instance_engine" {
  description = "The database engine type (e.g., mysql, postgres, mariadb)."
  value       = aws_db_instance.this.engine
}

output "db_instance_engine_version" {
  description = "The running version of the database engine."
  value       = aws_db_instance.this.engine_version_actual
}

# -----------------------------------------------------------------------------
# Storage Configuration Outputs
# -----------------------------------------------------------------------------

output "db_instance_allocated_storage" {
  description = "The amount of allocated storage in gibibytes."
  value       = aws_db_instance.this.allocated_storage
}

output "db_instance_storage_encrypted" {
  description = "Whether the DB instance is encrypted."
  value       = aws_db_instance.this.storage_encrypted
}

output "db_instance_storage_type" {
  description = "The storage type associated with the DB instance."
  value       = aws_db_instance.this.storage_type
}

# -----------------------------------------------------------------------------
# Network Configuration Outputs
# -----------------------------------------------------------------------------

output "db_instance_availability_zone" {
  description = "The availability zone of the RDS instance."
  value       = aws_db_instance.this.availability_zone
}

output "db_instance_multi_az" {
  description = "Whether the RDS instance is multi-AZ."
  value       = aws_db_instance.this.multi_az
}

output "db_subnet_group_id" {
  description = "The DB subnet group name."
  value       = var.create_db_subnet_group && var.db_subnet_group_name == null ? aws_db_subnet_group.this[0].id : var.db_subnet_group_name
}

output "db_subnet_group_arn" {
  description = "The ARN of the DB subnet group."
  value       = var.create_db_subnet_group && var.db_subnet_group_name == null ? aws_db_subnet_group.this[0].arn : null
}

output "security_group_id" {
  description = "The ID of the security group created for the RDS instance (if create_security_group was true)."
  value       = var.create_security_group ? aws_security_group.this[0].id : null
}

output "security_group_arn" {
  description = "The ARN of the security group created for the RDS instance (if create_security_group was true)."
  value       = var.create_security_group ? aws_security_group.this[0].arn : null
}

# -----------------------------------------------------------------------------
# Backup & Maintenance Outputs
# -----------------------------------------------------------------------------

output "db_instance_backup_retention_period" {
  description = "The backup retention period in days."
  value       = aws_db_instance.this.backup_retention_period
}

output "db_instance_backup_window" {
  description = "The daily time range during which automated backups are created."
  value       = aws_db_instance.this.backup_window
}

output "db_instance_maintenance_window" {
  description = "The window of time for system maintenance."
  value       = aws_db_instance.this.maintenance_window
}

output "db_instance_latest_restorable_time" {
  description = "The latest time to which a database can be restored with point-in-time restore."
  value       = aws_db_instance.this.latest_restorable_time
}

# -----------------------------------------------------------------------------
# Monitoring Outputs
# -----------------------------------------------------------------------------

output "db_instance_monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected."
  value       = aws_db_instance.this.monitoring_interval
}

output "db_instance_performance_insights_enabled" {
  description = "Whether Performance Insights is enabled."
  value       = aws_db_instance.this.performance_insights_enabled
}

output "db_instance_cloudwatch_log_groups" {
  description = "List of CloudWatch log groups for the RDS instance."
  value       = aws_db_instance.this.enabled_cloudwatch_logs_exports
}

# -----------------------------------------------------------------------------
# Read Replica Outputs
# -----------------------------------------------------------------------------

output "read_replica_ids" {
  description = "Map of read replica identifiers."
  value = {
    for key, replica in aws_db_instance.replica :
    key => replica.id
  }
}

output "read_replica_endpoints" {
  description = "Map of read replica endpoints in address:port format."
  value = {
    for key, replica in aws_db_instance.replica :
    key => replica.endpoint
  }
}

output "read_replica_addresses" {
  description = "Map of read replica hostnames."
  value = {
    for key, replica in aws_db_instance.replica :
    key => replica.address
  }
}

output "read_replica_arns" {
  description = "Map of read replica ARNs."
  value = {
    for key, replica in aws_db_instance.replica :
    key => replica.arn
  }
}

# -----------------------------------------------------------------------------
# Additional Metadata Outputs
# -----------------------------------------------------------------------------

output "db_instance_status" {
  description = "The RDS instance status."
  value       = aws_db_instance.this.status
}

output "db_instance_ca_cert_identifier" {
  description = "The identifier of the CA certificate for the DB instance."
  value       = aws_db_instance.this.ca_cert_identifier
}

output "tags" {
  description = "All tags applied to the RDS instance."
  value       = aws_db_instance.this.tags_all
}
