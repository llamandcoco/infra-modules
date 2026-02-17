# -----------------------------------------------------------------------------
# Redis Replication Group Outputs
# -----------------------------------------------------------------------------

output "replication_group_id" {
  description = "ID of the ElastiCache Redis replication group. Use this for resource references and configuration."
  value       = var.engine == "redis" ? aws_elasticache_replication_group.this[0].id : null
}

output "replication_group_arn" {
  description = "ARN of the ElastiCache Redis replication group. Use this for IAM policies and cross-account access."
  value       = var.engine == "redis" ? aws_elasticache_replication_group.this[0].arn : null
}

output "redis_primary_endpoint_address" {
  description = "Primary endpoint address for Redis cluster. Use this for write operations."
  value       = var.engine == "redis" ? aws_elasticache_replication_group.this[0].primary_endpoint_address : null
}

output "redis_reader_endpoint_address" {
  description = "Reader endpoint address for Redis cluster. Use this for read operations to distribute load across replicas."
  value       = var.engine == "redis" ? aws_elasticache_replication_group.this[0].reader_endpoint_address : null
}

output "redis_configuration_endpoint_address" {
  description = "Configuration endpoint address for Redis cluster mode enabled clusters."
  value       = var.engine == "redis" ? aws_elasticache_replication_group.this[0].configuration_endpoint_address : null
}

output "redis_member_clusters" {
  description = "List of cluster IDs that are part of this Redis replication group."
  value       = var.engine == "redis" ? aws_elasticache_replication_group.this[0].member_clusters : null
}

# -----------------------------------------------------------------------------
# Memcached Cluster Outputs
# -----------------------------------------------------------------------------

output "memcached_cluster_id" {
  description = "ID of the ElastiCache Memcached cluster. Use this for resource references and configuration."
  value       = var.engine == "memcached" ? aws_elasticache_cluster.this[0].id : null
}

output "memcached_cluster_arn" {
  description = "ARN of the ElastiCache Memcached cluster. Use this for IAM policies and cross-account access."
  value       = var.engine == "memcached" ? aws_elasticache_cluster.this[0].arn : null
}

output "memcached_cluster_address" {
  description = "DNS name of the Memcached cluster configuration endpoint."
  value       = var.engine == "memcached" ? aws_elasticache_cluster.this[0].cluster_address : null
}

output "memcached_configuration_endpoint" {
  description = "Configuration endpoint address for Memcached cluster."
  value       = var.engine == "memcached" ? aws_elasticache_cluster.this[0].configuration_endpoint : null
}

output "memcached_cache_nodes" {
  description = "List of cache node addresses for the Memcached cluster."
  value       = var.engine == "memcached" ? aws_elasticache_cluster.this[0].cache_nodes : null
}

# -----------------------------------------------------------------------------
# Common Outputs
# -----------------------------------------------------------------------------

output "cluster_id" {
  description = "ID of the ElastiCache cluster (Redis or Memcached)."
  value       = var.cluster_id
}

output "engine" {
  description = "Cache engine being used (redis or memcached)."
  value       = var.engine
}

output "engine_version" {
  description = "Version of the cache engine."
  value       = var.engine_version
}

output "node_type" {
  description = "Instance type of the cache nodes."
  value       = var.node_type
}

output "port" {
  description = "Port number on which the cache accepts connections."
  value       = var.port != null ? var.port : (var.engine == "redis" ? 6379 : 11211)
}

output "num_cache_nodes" {
  description = "Number of cache nodes in the cluster."
  value       = var.num_cache_nodes
}

# -----------------------------------------------------------------------------
# Subnet Group Outputs
# -----------------------------------------------------------------------------

output "subnet_group_name" {
  description = "Name of the ElastiCache subnet group."
  value       = var.subnet_group_name != null ? var.subnet_group_name : (length(aws_elasticache_subnet_group.this) > 0 ? aws_elasticache_subnet_group.this[0].name : null)
}

output "subnet_group_id" {
  description = "ID of the ElastiCache subnet group."
  value       = length(aws_elasticache_subnet_group.this) > 0 ? aws_elasticache_subnet_group.this[0].id : null
}

# -----------------------------------------------------------------------------
# Parameter Group Outputs
# -----------------------------------------------------------------------------

output "parameter_group_name" {
  description = "Name of the ElastiCache parameter group."
  value       = var.parameter_group_name != null ? var.parameter_group_name : (length(aws_elasticache_parameter_group.this) > 0 ? aws_elasticache_parameter_group.this[0].name : null)
}

output "parameter_group_id" {
  description = "ID of the ElastiCache parameter group."
  value       = length(aws_elasticache_parameter_group.this) > 0 ? aws_elasticache_parameter_group.this[0].id : null
}

# -----------------------------------------------------------------------------
# Security Outputs
# -----------------------------------------------------------------------------

output "at_rest_encryption_enabled" {
  description = "Whether at-rest encryption is enabled (Redis only)."
  value       = var.engine == "redis" ? var.at_rest_encryption_enabled : null
}

output "transit_encryption_enabled" {
  description = "Whether in-transit encryption is enabled (Redis only)."
  value       = var.engine == "redis" ? var.transit_encryption_enabled : null
}

output "kms_key_id" {
  description = "ARN of the KMS key used for at-rest encryption."
  value       = var.kms_key_id
}

# -----------------------------------------------------------------------------
# High Availability Outputs
# -----------------------------------------------------------------------------

output "automatic_failover_enabled" {
  description = "Whether automatic failover is enabled (Redis only)."
  value       = var.engine == "redis" ? var.automatic_failover_enabled : null
}

output "multi_az_enabled" {
  description = "Whether Multi-AZ is enabled (Redis only)."
  value       = var.engine == "redis" ? var.multi_az_enabled : null
}

# -----------------------------------------------------------------------------
# Backup Outputs
# -----------------------------------------------------------------------------

output "snapshot_retention_limit" {
  description = "Number of days to retain automatic snapshots (Redis only)."
  value       = var.engine == "redis" ? var.snapshot_retention_limit : null
}

output "snapshot_window" {
  description = "Daily time range for automated snapshots (Redis only)."
  value       = var.engine == "redis" ? var.snapshot_window : null
}

# -----------------------------------------------------------------------------
# Maintenance Outputs
# -----------------------------------------------------------------------------

output "maintenance_window" {
  description = "Weekly time range for system maintenance."
  value       = var.maintenance_window
}

output "auto_minor_version_upgrade" {
  description = "Whether automatic minor version upgrades are enabled."
  value       = var.auto_minor_version_upgrade
}

# -----------------------------------------------------------------------------
# Resource Reference Outputs
# -----------------------------------------------------------------------------

output "tags" {
  description = "All tags applied to the cluster resources."
  value       = var.tags
}
