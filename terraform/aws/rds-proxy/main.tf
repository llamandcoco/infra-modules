terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Security Group for RDS Proxy
# Controls inbound and outbound traffic to the proxy
resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name_prefix = "${var.name}-proxy-"
  description = "Security group for RDS Proxy ${var.name}"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-proxy-sg"
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
      Name = "${var.name}-ingress-${each.key}"
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
      Name = "${var.name}-ingress-cidr-${replace(each.value, "/", "-")}"
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
      Name = "${var.name}-egress-${replace(each.value, "/", "-")}"
    }
  )
}

# RDS Proxy
# Manages database connections on behalf of application clients
resource "aws_db_proxy" "this" {
  name                   = var.name
  debug_logging          = var.debug_logging
  engine_family          = var.engine_family
  idle_client_timeout    = var.idle_client_timeout
  require_tls            = var.require_tls
  role_arn               = var.role_arn
  vpc_security_group_ids = var.vpc_security_group_ids != null ? var.vpc_security_group_ids : (var.create_security_group ? [aws_security_group.this[0].id] : null)
  vpc_subnet_ids         = var.vpc_subnet_ids

  dynamic "auth" {
    for_each = var.auth

    content {
      auth_scheme               = try(auth.value.auth_scheme, "SECRETS")
      client_password_auth_type = try(auth.value.client_password_auth_type, null)
      description               = try(auth.value.description, null)
      iam_auth                  = try(auth.value.iam_auth, "DISABLED")
      secret_arn                = try(auth.value.secret_arn, null)
      username                  = try(auth.value.username, null)
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )

  lifecycle {
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
      condition     = !(var.create_security_group && (length(var.allowed_security_groups) > 0 || length(var.allowed_cidr_blocks) > 0) && var.port == null)
      error_message = "port is required when create_security_group is true and ingress sources are provided."
    }
  }
}

# RDS Proxy Default Target Group
# Configures connection pool settings for the proxy
resource "aws_db_proxy_default_target_group" "this" {
  db_proxy_name = aws_db_proxy.this.name

  connection_pool_config {
    connection_borrow_timeout    = var.connection_borrow_timeout
    init_query                   = var.init_query
    max_connections_percent      = var.max_connections_percent
    max_idle_connections_percent = var.max_idle_connections_percent
    session_pinning_filters      = var.session_pinning_filters
  }
}

# RDS Proxy Target
# Associates the proxy with an RDS instance or Aurora cluster
resource "aws_db_proxy_target" "this" {
  db_proxy_name          = aws_db_proxy.this.name
  target_group_name      = aws_db_proxy_default_target_group.this.name
  db_instance_identifier = var.target_db_instance_identifier
  db_cluster_identifier  = var.target_db_cluster_identifier

  lifecycle {
    precondition {
      condition     = (var.target_db_instance_identifier == null) != (var.target_db_cluster_identifier == null)
      error_message = "Set exactly one of target_db_instance_identifier or target_db_cluster_identifier."
    }
  }
}
