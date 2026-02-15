terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AmazonMQ Broker
# Creates a managed message broker for ActiveMQ or RabbitMQ
# Note: Due to AWS provider schema limitations, some nested blocks cannot use
# dynamic iteration and must be included statically with conditional values.
resource "aws_mq_broker" "this" {
  broker_name = var.broker_name

  # Engine configuration
  engine_type        = var.engine_type
  engine_version     = var.engine_version
  host_instance_type = var.host_instance_type
  deployment_mode    = var.deployment_mode

  # Security
  security_groups     = var.security_groups
  subnet_ids          = var.deployment_mode == "SINGLE_INSTANCE" ? [var.subnet_ids[0]] : var.subnet_ids
  publicly_accessible = var.publicly_accessible

  # Authentication
  authentication_strategy = var.authentication_strategy

  # Storage
  storage_type = var.storage_type

  # Auto minor version upgrade
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  # Encryption
  encryption_options {
    use_aws_owned_key = var.kms_key_id == null ? true : false
    kms_key_id        = var.kms_key_id
  }

  # Logging
  logs {
    general = var.enable_general_log
    audit   = var.enable_audit_log
  }

  # Maintenance window (conditional inclusion based on variable)
  maintenance_window_start_time {
    day_of_week = var.maintenance_day_of_week != null ? var.maintenance_day_of_week : "SUNDAY"
    time_of_day = var.maintenance_time_of_day
    time_zone   = var.maintenance_time_zone
  }

  # Primary user (always included)
  user {
    username         = var.users[0].username
    password         = var.users[0].password
    console_access   = try(var.users[0].console_access, false)
    groups           = try(var.users[0].groups, [])
    replication_user = try(var.users[0].replication_user, false)
  }

  tags = merge(
    var.tags,
    {
      Name = var.broker_name
    }
  )
}

# Configuration (optional)
# Creates a broker configuration for custom settings
resource "aws_mq_configuration" "this" {
  count = var.create_configuration ? 1 : 0

  name           = var.configuration_name != null ? var.configuration_name : "${var.broker_name}-config"
  description    = var.configuration_description
  engine_type    = var.engine_type
  engine_version = var.engine_version
  data           = var.configuration_data

  tags = merge(
    var.tags,
    {
      Name = var.configuration_name != null ? var.configuration_name : "${var.broker_name}-config"
    }
  )
}
