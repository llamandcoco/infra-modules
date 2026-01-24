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
  # Common port definitions for predefined rules
  common_ports = {
    http       = { port = 80, protocol = "tcp", description = "HTTP" }
    https      = { port = 443, protocol = "tcp", description = "HTTPS" }
    ssh        = { port = 22, protocol = "tcp", description = "SSH" }
    rdp        = { port = 3389, protocol = "tcp", description = "RDP" }
    mysql      = { port = 3306, protocol = "tcp", description = "MySQL" }
    postgres   = { port = 5432, protocol = "tcp", description = "PostgreSQL" }
    redis      = { port = 6379, protocol = "tcp", description = "Redis" }
    mongodb    = { port = 27017, protocol = "tcp", description = "MongoDB" }
    dns_tcp    = { port = 53, protocol = "tcp", description = "DNS TCP" }
    dns_udp    = { port = 53, protocol = "udp", description = "DNS UDP" }
    ntp        = { port = 123, protocol = "udp", description = "NTP" }
    smtp       = { port = 25, protocol = "tcp", description = "SMTP" }
    smtps      = { port = 465, protocol = "tcp", description = "SMTPS" }
    submission = { port = 587, protocol = "tcp", description = "SMTP Submission" }
  }

  # Process predefined ingress rules
  predefined_ingress = {
    for name in var.predefined_ingress_rules : name => merge(
      local.common_ports[name],
      {
        cidr_blocks      = var.predefined_rule_cidr_blocks
        ipv6_cidr_blocks = var.predefined_rule_ipv6_cidr_blocks
      }
    )
  }

  # Merge custom and predefined ingress rules
  all_ingress_rules = merge(
    { for idx, rule in var.ingress_rules : "custom-${idx}" => rule },
    { for name, rule in local.predefined_ingress : "predefined-${name}" => {
      description              = rule.description
      from_port                = rule.port
      to_port                  = rule.port
      protocol                 = rule.protocol
      cidr_blocks              = rule.cidr_blocks
      ipv6_cidr_blocks         = rule.ipv6_cidr_blocks
      source_security_group_id = null
      prefix_list_ids          = []
    } }
  )

  # Custom egress rules
  egress_rules = { for idx, rule in var.egress_rules : idx => rule }

  # Default egress rule (allow all) if requested
  default_egress = var.enable_default_egress_rule ? {
    "default-egress" = {
      description              = "Allow all outbound traffic"
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      cidr_blocks              = ["0.0.0.0/0"]
      ipv6_cidr_blocks         = ["::/0"]
      source_security_group_id = null
      prefix_list_ids          = []
    }
  } : {}

  all_egress_rules = merge(local.egress_rules, local.default_egress)
}

resource "aws_security_group" "this" {
  name                   = var.name
  description            = var.description
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [egress] # Ignore default egress rule AWS creates
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

resource "aws_security_group_rule" "ingress" {
  for_each = local.all_ingress_rules

  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = try(each.value.source_security_group_id, null) == null ? try(each.value.cidr_blocks, []) : null
  ipv6_cidr_blocks         = try(each.value.source_security_group_id, null) == null ? try(each.value.ipv6_cidr_blocks, []) : null
  prefix_list_ids          = try(each.value.prefix_list_ids, [])
  security_group_id        = aws_security_group.this.id
  source_security_group_id = try(each.value.source_security_group_id, null)
  description              = try(each.value.description, "${var.name} ingress rule")
}

# trivy:ignore:AVD-AWS-0104
resource "aws_security_group_rule" "egress" {
  for_each = local.all_egress_rules

  type                     = "egress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = try(each.value.source_security_group_id, null) == null ? try(each.value.cidr_blocks, []) : null
  ipv6_cidr_blocks         = try(each.value.source_security_group_id, null) == null ? try(each.value.ipv6_cidr_blocks, []) : null
  prefix_list_ids          = try(each.value.prefix_list_ids, [])
  security_group_id        = aws_security_group.this.id
  source_security_group_id = try(each.value.source_security_group_id, null)
  description              = try(each.value.description, "${var.name} egress rule")
}
