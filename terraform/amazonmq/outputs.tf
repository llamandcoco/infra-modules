# -----------------------------------------------------------------------------
# Broker Identification Outputs
# -----------------------------------------------------------------------------

output "broker_id" {
  description = "Unique ID of the AmazonMQ broker."
  value       = aws_mq_broker.this.id
}

output "broker_arn" {
  description = "ARN of the AmazonMQ broker. Use this for IAM policies and resource-based policies."
  value       = aws_mq_broker.this.arn
}

output "broker_name" {
  description = "Name of the AmazonMQ broker."
  value       = aws_mq_broker.this.broker_name
}

# -----------------------------------------------------------------------------
# Broker Configuration Outputs
# -----------------------------------------------------------------------------

output "engine_type" {
  description = "Type of broker engine (ActiveMQ or RabbitMQ)."
  value       = aws_mq_broker.this.engine_type
}

output "engine_version" {
  description = "Version of the broker engine."
  value       = aws_mq_broker.this.engine_version
}

output "host_instance_type" {
  description = "Instance type of the broker."
  value       = aws_mq_broker.this.host_instance_type
}

output "deployment_mode" {
  description = "Deployment mode of the broker (SINGLE_INSTANCE, ACTIVE_STANDBY_MULTI_AZ, or CLUSTER_MULTI_AZ)."
  value       = aws_mq_broker.this.deployment_mode
}

output "storage_type" {
  description = "Storage type used by the broker (EBS or EFS)."
  value       = aws_mq_broker.this.storage_type
}

# -----------------------------------------------------------------------------
# Connectivity Outputs
# -----------------------------------------------------------------------------

output "instances" {
  description = "List of broker instances with endpoint information."
  value       = aws_mq_broker.this.instances
}

output "console_url" {
  description = "URL of the broker's web console. Returns null if console is not enabled."
  value       = length(aws_mq_broker.this.instances) > 0 ? aws_mq_broker.this.instances[0].console_url : null
}

output "endpoints" {
  description = "List of broker endpoints for client connections. Returns null if not available."
  value       = length(aws_mq_broker.this.instances) > 0 ? aws_mq_broker.this.instances[0].endpoints : null
}

output "ip_address" {
  description = "IP address of the broker instance. Returns null for multi-AZ deployments."
  value       = length(aws_mq_broker.this.instances) > 0 ? aws_mq_broker.this.instances[0].ip_address : null
}

# -----------------------------------------------------------------------------
# Network Configuration Outputs
# -----------------------------------------------------------------------------

output "security_groups" {
  description = "List of security group IDs attached to the broker."
  value       = aws_mq_broker.this.security_groups
}

output "subnet_ids" {
  description = "List of subnet IDs where the broker is deployed."
  value       = aws_mq_broker.this.subnet_ids
}

output "publicly_accessible" {
  description = "Whether the broker is publicly accessible."
  value       = aws_mq_broker.this.publicly_accessible
}

# -----------------------------------------------------------------------------
# Authentication Configuration Outputs
# -----------------------------------------------------------------------------

output "authentication_strategy" {
  description = "Authentication strategy used by the broker (SIMPLE or LDAP)."
  value       = aws_mq_broker.this.authentication_strategy
}

# -----------------------------------------------------------------------------
# Security Outputs
# -----------------------------------------------------------------------------

output "kms_key_id" {
  description = "ARN of the KMS key used for encryption. Returns null if using AWS-owned key."
  value       = var.kms_key_id
}

output "encryption_use_aws_owned_key" {
  description = "Whether the broker uses AWS-owned encryption key."
  value       = var.kms_key_id == null
}

# -----------------------------------------------------------------------------
# Monitoring Outputs
# -----------------------------------------------------------------------------

output "logs_general_enabled" {
  description = "Whether general logging is enabled."
  value       = var.enable_general_log
}

output "logs_audit_enabled" {
  description = "Whether audit logging is enabled (ActiveMQ only)."
  value       = var.enable_audit_log
}

# -----------------------------------------------------------------------------
# Maintenance Outputs
# -----------------------------------------------------------------------------

output "auto_minor_version_upgrade" {
  description = "Whether automatic minor version upgrades are enabled."
  value       = aws_mq_broker.this.auto_minor_version_upgrade
}

output "maintenance_window_start_time" {
  description = "Configured maintenance window start time."
  value       = aws_mq_broker.this.maintenance_window_start_time
}

# -----------------------------------------------------------------------------
# Resource Reference Outputs
# -----------------------------------------------------------------------------

output "tags" {
  description = "All tags applied to the broker, including default and custom tags."
  value       = aws_mq_broker.this.tags_all
}
