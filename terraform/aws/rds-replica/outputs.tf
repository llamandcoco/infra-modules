# -----------------------------------------------------------------------------
# Replica Instance Identification Outputs
# -----------------------------------------------------------------------------

output "db_instance_id" {
  description = "The RDS replica instance identifier."
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "The ARN of the RDS replica instance."
  value       = aws_db_instance.this.arn
}

output "db_instance_resource_id" {
  description = "The unique resource ID of the replica. Used for CloudWatch metrics and Performance Insights."
  value       = aws_db_instance.this.resource_id
}

# -----------------------------------------------------------------------------
# Connection Information Outputs
# -----------------------------------------------------------------------------

output "db_instance_endpoint" {
  description = "The connection endpoint for the replica in address:port format."
  value       = aws_db_instance.this.endpoint
}

output "db_instance_address" {
  description = "The hostname of the replica. Use this as the host in database connection strings."
  value       = aws_db_instance.this.address
}

output "db_instance_port" {
  description = "The port number on which the replica accepts connections."
  value       = aws_db_instance.this.port
}

output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the replica (for Route53 alias records)."
  value       = aws_db_instance.this.hosted_zone_id
}

# -----------------------------------------------------------------------------
# Configuration Outputs
# -----------------------------------------------------------------------------

output "db_instance_engine" {
  description = "The database engine type of the replica."
  value       = aws_db_instance.this.engine
}

output "db_instance_engine_version" {
  description = "The running version of the database engine."
  value       = aws_db_instance.this.engine_version_actual
}

output "db_instance_availability_zone" {
  description = "The availability zone of the replica."
  value       = aws_db_instance.this.availability_zone
}

# -----------------------------------------------------------------------------
# Storage Outputs
# -----------------------------------------------------------------------------

output "db_instance_storage_encrypted" {
  description = "Whether the replica storage is encrypted."
  value       = aws_db_instance.this.storage_encrypted
}

output "db_instance_storage_type" {
  description = "The storage type of the replica."
  value       = aws_db_instance.this.storage_type
}

output "db_instance_allocated_storage" {
  description = "The allocated storage in GiB for the replica."
  value       = aws_db_instance.this.allocated_storage
}

# -----------------------------------------------------------------------------
# Monitoring Outputs
# -----------------------------------------------------------------------------

output "db_instance_monitoring_interval" {
  description = "The Enhanced Monitoring collection interval in seconds."
  value       = aws_db_instance.this.monitoring_interval
}

output "db_instance_performance_insights_enabled" {
  description = "Whether Performance Insights is enabled on the replica."
  value       = aws_db_instance.this.performance_insights_enabled
}

# -----------------------------------------------------------------------------
# Network Outputs
# -----------------------------------------------------------------------------

output "security_group_id" {
  description = "The ID of the security group created for the replica (if create_security_group was true)."
  value       = var.create_security_group ? aws_security_group.this[0].id : null
}

output "security_group_arn" {
  description = "The ARN of the security group created for the replica (if create_security_group was true)."
  value       = var.create_security_group ? aws_security_group.this[0].arn : null
}

# -----------------------------------------------------------------------------
# Additional Metadata Outputs
# -----------------------------------------------------------------------------

output "db_instance_status" {
  description = "The current status of the RDS replica instance."
  value       = aws_db_instance.this.status
}

output "db_instance_ca_cert_identifier" {
  description = "The identifier of the CA certificate for the replica."
  value       = aws_db_instance.this.ca_cert_identifier
}

output "tags" {
  description = "All tags applied to the replica."
  value       = aws_db_instance.this.tags_all
}
