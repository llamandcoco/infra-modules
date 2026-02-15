terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# DB Subnet Group
# Creates a subnet group for the RDS instance to enable Multi-AZ deployment
resource "aws_db_subnet_group" "this" {
  count = var.create_db_subnet_group && var.db_subnet_group_name == null ? 1 : 0

  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-subnet-group"
    }
  )
}

# Security Group for RDS
# Controls inbound and outbound traffic to the database instance
resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name_prefix = "${var.identifier}-rds-"
  description = "Security group for RDS instance ${var.identifier}"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-rds-sg"
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
      Name = "${var.identifier}-ingress-${each.key}"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "cidr" {
  for_each = var.create_security_group && length(var.allowed_cidr_blocks) > 0 ? toset(var.allowed_cidr_blocks) : []

  security_group_id = aws_security_group.this[0].id

  cidr_ipv4   = each.value
  from_port   = var.port
  to_port     = var.port
  ip_protocol = "tcp"

  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-ingress-cidr-${replace(each.value, "/", "-")}"
    }
  )
}

resource "aws_vpc_security_group_egress_rule" "this" {
  count = var.create_security_group ? 1 : 0

  security_group_id = aws_security_group.this[0].id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-egress-all"
    }
  )
}

# RDS Instance
# Creates the main database instance with configurable engine, storage, and backup settings
resource "aws_db_instance" "this" {
  identifier = var.identifier

  # Engine Configuration
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  db_name              = var.database_name
  username             = var.master_username
  password             = var.master_password
  parameter_group_name = var.parameter_group_name
  option_group_name    = var.option_group_name

  # Storage Configuration
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id
  iops                  = var.iops
  storage_throughput    = var.storage_throughput

  # Network Configuration
  db_subnet_group_name   = var.db_subnet_group_name != null ? var.db_subnet_group_name : (var.create_db_subnet_group ? aws_db_subnet_group.this[0].name : null)
  vpc_security_group_ids = var.vpc_security_group_ids != null ? var.vpc_security_group_ids : (var.create_security_group ? [aws_security_group.this[0].id] : [])
  publicly_accessible    = var.publicly_accessible
  port                   = var.port

  # Availability & Reliability
  multi_az          = var.multi_az
  availability_zone = var.multi_az ? null : var.availability_zone

  # Backup Configuration
  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window
  maintenance_window        = var.maintenance_window
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.identifier}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Monitoring & Logging
  enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_role_arn
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id
  performance_insights_retention_period = var.performance_insights_retention_period

  # Additional Settings
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately           = var.apply_immediately
  deletion_protection         = var.deletion_protection
  delete_automated_backups    = var.delete_automated_backups

  # Snapshot restore
  snapshot_identifier = var.snapshot_identifier

  # Point in time recovery restore
  dynamic "restore_to_point_in_time" {
    for_each = var.restore_to_point_in_time != null ? [var.restore_to_point_in_time] : []

    content {
      source_db_instance_identifier = try(restore_to_point_in_time.value.source_db_instance_identifier, null)
      restore_time                  = try(restore_to_point_in_time.value.restore_time, null)
      use_latest_restorable_time    = try(restore_to_point_in_time.value.use_latest_restorable_time, false)
    }
  }

  # IAM Authentication
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  # License model (for commercial databases)
  license_model = var.license_model

  # Character set (Oracle only)
  character_set_name = var.character_set_name

  # Timezone (SQL Server only)
  timezone = var.timezone

  tags = merge(
    var.tags,
    {
      Name = var.identifier
    }
  )

  lifecycle {
    ignore_changes = [
      final_snapshot_identifier,
      password,
    ]
  }
}

# Read Replica
# Creates optional read replica(s) for scaling read operations
resource "aws_db_instance" "replica" {
  for_each = var.read_replicas

  identifier = "${var.identifier}-replica-${each.key}"

  # Replica Configuration
  replicate_source_db = aws_db_instance.this.identifier
  instance_class      = try(each.value.instance_class, var.instance_class)

  # Storage Configuration (inherited from source but can be modified)
  allocated_storage     = try(each.value.allocated_storage, null)
  max_allocated_storage = try(each.value.max_allocated_storage, var.max_allocated_storage)
  storage_type          = try(each.value.storage_type, var.storage_type)
  iops                  = try(each.value.iops, var.iops)
  storage_throughput    = try(each.value.storage_throughput, var.storage_throughput)

  # Network Configuration
  vpc_security_group_ids = var.vpc_security_group_ids != null ? var.vpc_security_group_ids : (var.create_security_group ? [aws_security_group.this[0].id] : [])
  publicly_accessible    = try(each.value.publicly_accessible, var.publicly_accessible)
  availability_zone      = try(each.value.availability_zone, null)

  # Monitoring
  monitoring_interval                   = try(each.value.monitoring_interval, var.monitoring_interval)
  monitoring_role_arn                   = try(each.value.monitoring_role_arn, var.monitoring_role_arn)
  performance_insights_enabled          = try(each.value.performance_insights_enabled, var.performance_insights_enabled)
  performance_insights_kms_key_id       = try(each.value.performance_insights_kms_key_id, var.performance_insights_kms_key_id)
  performance_insights_retention_period = try(each.value.performance_insights_retention_period, var.performance_insights_retention_period)

  # Additional Settings
  auto_minor_version_upgrade = try(each.value.auto_minor_version_upgrade, var.auto_minor_version_upgrade)
  apply_immediately          = try(each.value.apply_immediately, var.apply_immediately)
  skip_final_snapshot        = var.skip_final_snapshot

  tags = merge(
    var.tags,
    try(each.value.tags, {}),
    {
      Name = "${var.identifier}-replica-${each.key}"
    }
  )

  lifecycle {
    ignore_changes = [
      password,
    ]
  }
}
