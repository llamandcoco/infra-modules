terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# RDS Read Replica
# Manages a read replica with explicit identifier for importing existing replicas.
resource "aws_db_instance" "this" {
  identifier          = var.identifier
  replicate_source_db = var.source_db_identifier
  instance_class      = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage > 0 ? var.max_allocated_storage : null
  storage_type          = var.storage_type
  iops                  = var.iops
  storage_throughput    = var.storage_throughput
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id

  vpc_security_group_ids = var.vpc_security_group_ids
  publicly_accessible    = var.publicly_accessible
  availability_zone      = var.availability_zone

  parameter_group_name = var.parameter_group_name

  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_role_arn
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id
  performance_insights_retention_period = var.performance_insights_retention_period

  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately
  deletion_protection        = var.deletion_protection
  copy_tags_to_snapshot      = var.copy_tags_to_snapshot
  skip_final_snapshot        = var.skip_final_snapshot

  tags = merge(
    var.tags,
    {
      Name = var.identifier
    }
  )

  lifecycle {
    precondition {
      condition     = var.monitoring_interval == 0 || var.monitoring_role_arn != null
      error_message = "monitoring_role_arn is required when monitoring_interval is greater than 0."
    }

    ignore_changes = [
      password,
    ]
  }
}
