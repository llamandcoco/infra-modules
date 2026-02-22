terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Security Group for RDS Replica
# Controls inbound and outbound traffic to the replica instance
resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name_prefix = "${var.identifier}-rds-replica-"
  description = "Security group for RDS replica instance ${var.identifier}"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-rds-replica-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group Rules
resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = var.create_security_group ? var.allowed_security_groups : {}

  security_group_id = aws_security_group.this[0].id

  referenced_security_group_id = each.value
  from_port                    = var.port
  to_port                      = var.port
  ip_protocol                  = "tcp"

  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-replica-ingress-${each.key}"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "cidr" {
  for_each = var.create_security_group && length(var.allowed_cidr_blocks) > 0 ? toset(var.allowed_cidr_blocks) : toset([])

  security_group_id = aws_security_group.this[0].id

  cidr_ipv4   = each.value
  from_port   = var.port
  to_port     = var.port
  ip_protocol = "tcp"

  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-replica-ingress-cidr-${replace(each.value, "/", "-")}"
    }
  )
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = var.create_security_group && length(var.egress_cidr_blocks) > 0 ? toset(var.egress_cidr_blocks) : toset([])

  security_group_id = aws_security_group.this[0].id

  cidr_ipv4   = each.value
  ip_protocol = "-1"

  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-replica-egress-${replace(each.value, "/", "-")}"
    }
  )
}

# RDS Read Replica Instance
# Creates a read replica of an existing RDS instance for scaling read workloads
resource "aws_db_instance" "this" {
  identifier = var.identifier

  # Replica source
  replicate_source_db = var.source_db_instance_identifier

  # Compute
  instance_class = var.instance_class

  # Storage Configuration
  allocated_storage  = var.allocated_storage
  storage_type       = var.storage_type
  storage_encrypted  = var.storage_encrypted
  kms_key_id         = var.kms_key_id
  iops               = var.iops
  storage_throughput = var.storage_throughput

  max_allocated_storage = var.max_allocated_storage

  # Network Configuration
  vpc_security_group_ids = var.vpc_security_group_ids != null ? var.vpc_security_group_ids : (var.create_security_group ? [aws_security_group.this[0].id] : null)
  publicly_accessible    = var.publicly_accessible
  port                   = var.port
  availability_zone      = var.availability_zone

  # Monitoring & Logging
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_role_arn
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id
  performance_insights_retention_period = var.performance_insights_retention_period

  # Additional Settings
  backup_retention_period    = var.backup_retention_period
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately
  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = var.skip_final_snapshot
  final_snapshot_identifier  = var.skip_final_snapshot ? null : coalesce(var.final_snapshot_identifier, "${var.identifier}-final-snapshot")
  copy_tags_to_snapshot      = var.copy_tags_to_snapshot

  tags = merge(
    var.tags,
    {
      Name = var.identifier
    }
  )

  lifecycle {
    precondition {
      condition     = var.max_allocated_storage == 0 || var.allocated_storage == null ? true : var.max_allocated_storage >= var.allocated_storage
      error_message = "max_allocated_storage must be 0 or greater than or equal to allocated_storage."
    }

    precondition {
      condition     = var.monitoring_interval == 0 || var.monitoring_role_arn != null
      error_message = "monitoring_role_arn is required when monitoring_interval is greater than 0."
    }

    precondition {
      condition     = var.create_security_group || try(length(var.vpc_security_group_ids), 0) > 0
      error_message = "Set create_security_group=true or provide at least one vpc_security_group_ids entry."
    }

    precondition {
      condition     = var.vpc_security_group_ids == null || try(length(var.vpc_security_group_ids), 0) > 0
      error_message = "If vpc_security_group_ids is provided, it must contain at least one security group ID."
    }

    precondition {
      condition     = !var.create_security_group || var.vpc_id != null
      error_message = "vpc_id is required when create_security_group is true."
    }

    precondition {
      condition     = !var.create_security_group || (length(var.allowed_security_groups) == 0 && length(var.allowed_cidr_blocks) == 0) || var.port != null
      error_message = "port must be set when create_security_group is true and allowed_security_groups or allowed_cidr_blocks are configured."
    }

    ignore_changes = [
      password,
    ]
  }
}
