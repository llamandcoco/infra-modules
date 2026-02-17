terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  effective_parameter_group_family = var.parameter_group_family != null ? var.parameter_group_family : (
    var.engine == "redis" ? "redis7" : "memcached1.6"
  )
}

# ElastiCache Subnet Group
# Defines the subnets where ElastiCache nodes will be launched
resource "aws_elasticache_subnet_group" "this" {
  count = var.subnet_group_name != null ? 0 : 1

  name        = "${var.cluster_id}-subnet-group"
  description = "Subnet group for ${var.cluster_id} ElastiCache cluster"
  subnet_ids  = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_id}-subnet-group"
    }
  )

  lifecycle {
    precondition {
      condition     = length(var.subnet_ids) > 0
      error_message = "subnet_ids must not be empty when subnet_group_name is not provided."
    }
  }
}

# ElastiCache Parameter Group
# Defines engine-specific parameters and configurations
resource "aws_elasticache_parameter_group" "this" {
  count = var.parameter_group_name != null ? 0 : 1

  name        = "${var.cluster_id}-params"
  family      = local.effective_parameter_group_family
  description = "Parameter group for ${var.cluster_id} ElastiCache cluster"

  dynamic "parameter" {
    for_each = var.parameters

    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_id}-params"
    }
  )

  lifecycle {
    precondition {
      condition = (
        (var.engine == "redis" && can(regex("^redis", local.effective_parameter_group_family))) ||
        (var.engine == "memcached" && can(regex("^memcached", local.effective_parameter_group_family)))
      )
      error_message = "parameter_group_family must match engine family: redis* for Redis, memcached* for Memcached."
    }
  }
}

# ElastiCache Replication Group (Redis)
# Creates a Redis cluster with optional multi-AZ and automatic failover
resource "aws_elasticache_replication_group" "this" {
  count = var.engine == "redis" ? 1 : 0

  replication_group_id = var.cluster_id
  description          = var.description
  engine               = "redis"
  engine_version       = var.engine_version
  node_type            = var.node_type
  port                 = var.port
  parameter_group_name = var.parameter_group_name != null ? var.parameter_group_name : aws_elasticache_parameter_group.this[0].name
  subnet_group_name    = var.subnet_group_name != null ? var.subnet_group_name : aws_elasticache_subnet_group.this[0].name
  security_group_ids   = var.security_group_ids

  # High availability configuration
  num_cache_clusters         = var.num_cache_nodes
  automatic_failover_enabled = var.automatic_failover_enabled
  multi_az_enabled           = var.multi_az_enabled

  # Backup configuration
  snapshot_retention_limit  = var.snapshot_retention_limit
  snapshot_window           = var.snapshot_window
  final_snapshot_identifier = var.final_snapshot_identifier

  # Maintenance configuration
  maintenance_window         = var.maintenance_window
  notification_topic_arn     = var.notification_topic_arn
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  # Security configuration
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled
  auth_token                 = var.auth_token
  kms_key_id                 = var.kms_key_id

  # Logging
  dynamic "log_delivery_configuration" {
    for_each = var.log_delivery_configuration

    content {
      destination      = log_delivery_configuration.value.destination
      destination_type = log_delivery_configuration.value.destination_type
      log_format       = log_delivery_configuration.value.log_format
      log_type         = log_delivery_configuration.value.log_type
    }
  }

  # Apply changes immediately or during maintenance window
  apply_immediately = var.apply_immediately

  tags = merge(
    var.tags,
    {
      Name = var.cluster_id
    }
  )

  lifecycle {
    ignore_changes = [
      engine_version
    ]

    precondition {
      condition     = !var.automatic_failover_enabled || var.num_cache_nodes >= 2
      error_message = "automatic_failover_enabled requires num_cache_nodes >= 2."
    }

    precondition {
      condition     = !var.automatic_failover_enabled || var.multi_az_enabled
      error_message = "automatic_failover_enabled requires multi_az_enabled = true."
    }

    precondition {
      condition     = !var.multi_az_enabled || var.automatic_failover_enabled
      error_message = "multi_az_enabled requires automatic_failover_enabled = true."
    }

    precondition {
      condition     = var.auth_token == null || var.transit_encryption_enabled
      error_message = "auth_token can only be set when transit_encryption_enabled = true."
    }
  }
}

# ElastiCache Cluster (Memcached)
# Creates a Memcached cluster
resource "aws_elasticache_cluster" "this" {
  count = var.engine == "memcached" ? 1 : 0

  cluster_id           = var.cluster_id
  engine               = "memcached"
  engine_version       = var.engine_version
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  port                 = var.port
  parameter_group_name = var.parameter_group_name != null ? var.parameter_group_name : aws_elasticache_parameter_group.this[0].name
  subnet_group_name    = var.subnet_group_name != null ? var.subnet_group_name : aws_elasticache_subnet_group.this[0].name
  security_group_ids   = var.security_group_ids

  # AZ mode for Memcached
  az_mode                      = var.num_cache_nodes > 1 ? "cross-az" : "single-az"
  preferred_availability_zones = var.num_cache_nodes > 1 && length(var.availability_zones) > 0 ? var.availability_zones : null

  # Maintenance configuration
  maintenance_window         = var.maintenance_window
  notification_topic_arn     = var.notification_topic_arn
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  # Snapshot configuration (Memcached doesn't support backups)
  snapshot_window = null

  # Apply changes immediately or during maintenance window
  apply_immediately = var.apply_immediately

  tags = merge(
    var.tags,
    {
      Name = var.cluster_id
    }
  )

  lifecycle {
    ignore_changes = [
      engine_version
    ]

    precondition {
      condition     = length(var.availability_zones) == 0 || length(var.availability_zones) == var.num_cache_nodes
      error_message = "availability_zones must be empty or contain exactly num_cache_nodes entries for Memcached."
    }
  }
}
