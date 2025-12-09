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
  ingress_rules = { for idx, rule in var.ingress_rules : idx => rule }
  egress_rules  = { for idx, rule in var.egress_rules : idx => rule }
}

resource "aws_security_group" "this" {
  name                   = var.name
  description            = var.description
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

resource "aws_security_group_rule" "ingress" {
  for_each = local.ingress_rules

  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = each.value.cidr_blocks
  ipv6_cidr_blocks         = each.value.ipv6_cidr_blocks
  security_group_id        = aws_security_group.this.id
  source_security_group_id = try(each.value.source_security_group_id, null)
  description              = try(each.value.description, null)
}

resource "aws_security_group_rule" "egress" {
  for_each = local.egress_rules

  type                     = "egress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = each.value.cidr_blocks
  ipv6_cidr_blocks         = each.value.ipv6_cidr_blocks
  security_group_id        = aws_security_group.this.id
  source_security_group_id = try(each.value.source_security_group_id, null)
  description              = try(each.value.description, null)
}
