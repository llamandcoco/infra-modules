terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Local Variables
# -----------------------------------------------------------------------------
locals {
  # Create a map of target groups by name for easy lookup
  target_group_map = {
    for tg in var.target_groups : tg.name => tg
  }

  # Flatten target group attachments for easy iteration
  target_attachments = flatten([
    for tg in var.target_groups : [
      for target in tg.targets : {
        tg_name           = tg.name
        target_id         = target.target_id
        port              = target.port
        availability_zone = target.availability_zone
      }
    ] if length(tg.targets) > 0
  ])

  # Create a map for listener rules with unique keys
  listener_rules_map = {
    for idx, rule in var.listener_rules :
    "${rule.listener_port}-${rule.priority}" => rule
  }

  # Map listeners by port for easy lookup
  listener_port_map = {
    for listener in var.listeners : listener.port => listener
  }

  # Combine security groups
  security_groups = var.create_security_group ? concat([aws_security_group.this[0].id], var.security_group_ids) : var.security_group_ids
}

# -----------------------------------------------------------------------------
# Security Group (Optional)
# Creates a security group for the ALB if create_security_group is true
# tfsec:ignore:aws-ec2-no-public-egress-sgr - Egress rules are configurable via variables
# -----------------------------------------------------------------------------
resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name        = var.security_group_name
  description = var.security_group_description
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = var.security_group_name
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = var.create_security_group ? {
    for idx, rule in var.security_group_ingress_rules :
    "${rule.from_port}-${rule.to_port}-${rule.protocol}" => rule
  } : {}

  security_group_id = aws_security_group.this[0].id

  from_port   = each.value.from_port
  to_port     = each.value.to_port
  ip_protocol = each.value.protocol
  cidr_ipv4   = join(",", each.value.cidr_blocks)
  description = each.value.description

  tags = var.tags
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = var.create_security_group ? {
    for idx, rule in var.security_group_egress_rules :
    "${rule.from_port}-${rule.to_port}-${rule.protocol}" => rule
  } : {}

  security_group_id = aws_security_group.this[0].id

  from_port   = each.value.from_port
  to_port     = each.value.to_port
  ip_protocol = each.value.protocol
  cidr_ipv4   = join(",", each.value.cidr_blocks)
  description = each.value.description

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Application Load Balancer
# Main ALB resource
# tfsec:ignore:aws-elb-alb-not-public - Public/internal is controlled by var.internal
# tfsec:ignore:aws-elbv2-alb-not-public - Public/internal is controlled by var.internal
# -----------------------------------------------------------------------------
resource "aws_lb" "this" {
  name               = var.alb_name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = local.security_groups
  subnets            = var.subnets

  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_http2                     = var.enable_http2
  enable_waf_fail_open             = var.enable_waf_fail_open
  ip_address_type                  = var.ip_address_type
  desync_mitigation_mode           = var.desync_mitigation_mode
  drop_invalid_header_fields       = var.drop_invalid_header_fields
  preserve_host_header             = var.preserve_host_header
  xff_header_processing_mode       = var.xff_header_processing_mode
  idle_timeout                     = var.idle_timeout

  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [1] : []

    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = true
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.alb_name
    }
  )
}

# -----------------------------------------------------------------------------
# WAF Web ACL Association (Optional)
# Associates a WAF Web ACL with the ALB for application-layer protection
# -----------------------------------------------------------------------------
resource "aws_wafv2_web_acl_association" "this" {
  count = var.web_acl_arn != null ? 1 : 0

  resource_arn = aws_lb.this.arn
  web_acl_arn  = var.web_acl_arn
}

# -----------------------------------------------------------------------------
# Target Groups
# Creates target groups for routing traffic to registered targets
# -----------------------------------------------------------------------------
resource "aws_lb_target_group" "this" {
  for_each = local.target_group_map

  name                 = each.value.name
  port                 = each.value.port
  protocol             = each.value.protocol
  vpc_id               = var.vpc_id
  target_type          = each.value.target_type
  deregistration_delay = each.value.deregistration_delay
  slow_start           = each.value.slow_start

  health_check {
    enabled             = each.value.health_check.enabled
    healthy_threshold   = each.value.health_check.healthy_threshold
    unhealthy_threshold = each.value.health_check.unhealthy_threshold
    timeout             = each.value.health_check.timeout
    interval            = each.value.health_check.interval
    path                = each.value.health_check.path
    port                = each.value.health_check.port
    protocol            = each.value.health_check.protocol
    matcher             = each.value.health_check.matcher
  }

  dynamic "stickiness" {
    for_each = each.value.stickiness != null && each.value.stickiness.enabled ? [1] : []

    content {
      type            = each.value.stickiness.type
      cookie_duration = each.value.stickiness.cookie_duration
      cookie_name     = each.value.stickiness.cookie_name
      enabled         = true
    }
  }

  tags = merge(
    var.tags,
    var.target_group_tags,
    {
      Name = each.value.name
    }
  )
}

# -----------------------------------------------------------------------------
# Target Group Attachments (Optional)
# Registers targets with their target groups
# -----------------------------------------------------------------------------
resource "aws_lb_target_group_attachment" "this" {
  for_each = {
    for idx, attachment in local.target_attachments :
    "${attachment.tg_name}-${attachment.target_id}" => attachment
  }

  target_group_arn  = aws_lb_target_group.this[each.value.tg_name].arn
  target_id         = each.value.target_id
  port              = each.value.port
  availability_zone = each.value.availability_zone
}

# -----------------------------------------------------------------------------
# Listeners
# Creates listeners that check for connection requests
# -----------------------------------------------------------------------------
resource "aws_lb_listener" "this" {
  for_each = {
    for listener in var.listeners : listener.port => listener
  }

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = each.value.ssl_policy
  certificate_arn   = each.value.certificate_arn

  dynamic "default_action" {
    for_each = [each.value.default_action]

    content {
      type             = default_action.value.type
      target_group_arn = default_action.value.type == "forward" ? aws_lb_target_group.this[default_action.value.target_group_name].arn : null

      dynamic "redirect" {
        for_each = default_action.value.type == "redirect" ? [default_action.value.redirect] : []

        content {
          protocol    = redirect.value.protocol
          port        = redirect.value.port
          host        = redirect.value.host
          path        = redirect.value.path
          query       = redirect.value.query
          status_code = redirect.value.status_code
        }
      }

      dynamic "fixed_response" {
        for_each = default_action.value.type == "fixed-response" ? [default_action.value.fixed_response] : []

        content {
          content_type = fixed_response.value.content_type
          message_body = fixed_response.value.message_body
          status_code  = fixed_response.value.status_code
        }
      }
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.alb_name}-${each.value.protocol}-${each.value.port}"
    }
  )
}

# -----------------------------------------------------------------------------
# Additional Listener Certificates (SNI)
# Adds additional SSL certificates to HTTPS listeners for SNI support
# -----------------------------------------------------------------------------
resource "aws_lb_listener_certificate" "this" {
  for_each = merge([
    for listener in var.listeners : {
      for idx, cert_arn in listener.additional_certificate_arns :
      "${listener.port}-${idx}" => {
        listener_port = listener.port
        certificate_arn = cert_arn
      }
    } if listener.protocol == "HTTPS" && length(listener.additional_certificate_arns) > 0
  ]...)

  listener_arn    = aws_lb_listener.this[each.value.listener_port].arn
  certificate_arn = each.value.certificate_arn
}

# -----------------------------------------------------------------------------
# Listener Rules
# Creates rules for routing based on conditions (path, host, etc.)
# -----------------------------------------------------------------------------
resource "aws_lb_listener_rule" "this" {
  for_each = local.listener_rules_map

  listener_arn = aws_lb_listener.this[each.value.listener_port].arn
  priority     = each.value.priority

  action {
    type             = each.value.action.type
    target_group_arn = each.value.action.type == "forward" ? aws_lb_target_group.this[each.value.action.target_group_name].arn : null

    dynamic "redirect" {
      for_each = each.value.action.type == "redirect" ? [each.value.action.redirect] : []

      content {
        protocol    = redirect.value.protocol
        port        = redirect.value.port
        host        = redirect.value.host
        path        = redirect.value.path
        query       = redirect.value.query
        status_code = redirect.value.status_code
      }
    }

    dynamic "fixed_response" {
      for_each = each.value.action.type == "fixed-response" ? [each.value.action.fixed_response] : []

      content {
        content_type = fixed_response.value.content_type
        message_body = fixed_response.value.message_body
        status_code  = fixed_response.value.status_code
      }
    }
  }

  dynamic "condition" {
    for_each = each.value.conditions

    content {
      dynamic "path_pattern" {
        for_each = condition.value.path_pattern != null ? [condition.value.path_pattern] : []

        content {
          values = path_pattern.value.values
        }
      }

      dynamic "host_header" {
        for_each = condition.value.host_header != null ? [condition.value.host_header] : []

        content {
          values = host_header.value.values
        }
      }

      dynamic "http_header" {
        for_each = condition.value.http_header != null ? [condition.value.http_header] : []

        content {
          http_header_name = http_header.value.http_header_name
          values           = http_header.value.values
        }
      }

      dynamic "http_request_method" {
        for_each = condition.value.http_request_method != null ? [condition.value.http_request_method] : []

        content {
          values = http_request_method.value.values
        }
      }

      dynamic "query_string" {
        for_each = condition.value.query_string != null ? [condition.value.query_string] : []

        content {
          key   = query_string.value.key
          value = query_string.value.value
        }
      }

      dynamic "source_ip" {
        for_each = condition.value.source_ip != null ? [condition.value.source_ip] : []

        content {
          values = source_ip.value.values
        }
      }
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.alb_name}-rule-${each.value.priority}"
    }
  )
}
