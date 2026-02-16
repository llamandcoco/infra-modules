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
resource "aws_mq_broker" "this" {
  broker_name = var.broker_name

  # Engine configuration
  engine_type        = var.engine_type
  engine_version     = var.engine_version
  host_instance_type = var.host_instance_type
  deployment_mode    = var.deployment_mode

  # Security
  security_groups     = var.security_groups
  subnet_ids          = var.subnet_ids
  publicly_accessible = var.publicly_accessible

  # Authentication
  authentication_strategy = var.authentication_strategy

  dynamic "configuration" {
    for_each = var.configuration_id != null ? [1] : []
    content {
      id       = var.configuration_id
      revision = var.configuration_revision
    }
  }

  dynamic "ldap_server_metadata" {
    for_each = var.authentication_strategy == "LDAP" && var.ldap_server_metadata != null ? [var.ldap_server_metadata] : []
    content {
      hosts                    = ldap_server_metadata.value.hosts
      role_base                = ldap_server_metadata.value.role_base
      role_search_matching     = ldap_server_metadata.value.role_search_matching
      service_account_password = ldap_server_metadata.value.service_account_password
      service_account_username = ldap_server_metadata.value.service_account_username
      user_base                = ldap_server_metadata.value.user_base
      user_search_matching     = ldap_server_metadata.value.user_search_matching
      role_name                = try(ldap_server_metadata.value.role_name, null)
      role_search_subtree      = try(ldap_server_metadata.value.role_search_subtree, null)
      user_role_name           = try(ldap_server_metadata.value.user_role_name, null)
      user_search_subtree      = try(ldap_server_metadata.value.user_search_subtree, null)
    }
  }

  # Storage
  storage_type = var.storage_type

  # Auto minor version upgrade
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  lifecycle {
    precondition {
      condition = (
        (var.engine_type == "ActiveMQ" && contains(["SINGLE_INSTANCE", "ACTIVE_STANDBY_MULTI_AZ"], var.deployment_mode)) ||
        (var.engine_type == "RabbitMQ" && contains(["SINGLE_INSTANCE", "CLUSTER_MULTI_AZ"], var.deployment_mode))
      )
      error_message = "deployment_mode is invalid for engine_type. ActiveMQ supports SINGLE_INSTANCE/ACTIVE_STANDBY_MULTI_AZ, RabbitMQ supports SINGLE_INSTANCE/CLUSTER_MULTI_AZ."
    }

    precondition {
      condition = (
        (var.deployment_mode == "SINGLE_INSTANCE" && length(var.subnet_ids) == 1) ||
        (var.deployment_mode == "ACTIVE_STANDBY_MULTI_AZ" && length(var.subnet_ids) == 2) ||
        (var.deployment_mode == "CLUSTER_MULTI_AZ" && length(var.subnet_ids) == 3)
      )
      error_message = "subnet_ids must include exactly 1 subnet for SINGLE_INSTANCE, 2 for ACTIVE_STANDBY_MULTI_AZ, or 3 for CLUSTER_MULTI_AZ."
    }

    precondition {
      condition     = var.engine_type == "ActiveMQ" || var.storage_type == "EBS"
      error_message = "RabbitMQ only supports storage_type = EBS."
    }

    precondition {
      condition     = var.engine_type == "ActiveMQ" || var.authentication_strategy == "SIMPLE"
      error_message = "RabbitMQ only supports authentication_strategy = SIMPLE."
    }

    precondition {
      condition     = var.authentication_strategy != "LDAP" || var.ldap_server_metadata != null
      error_message = "ldap_server_metadata must be provided when authentication_strategy is LDAP."
    }

    precondition {
      condition = (
        (var.configuration_id == null && var.configuration_revision == null) ||
        (var.configuration_id != null && var.configuration_revision != null)
      )
      error_message = "configuration_id and configuration_revision must both be set together or both be null."
    }

    precondition {
      condition     = var.engine_type == "ActiveMQ" || var.enable_audit_log == false
      error_message = "enable_audit_log is only supported for ActiveMQ brokers."
    }
  }

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
    day_of_week = var.maintenance_day_of_week
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
