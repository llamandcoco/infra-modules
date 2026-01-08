terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_security_group" "sg" {
  for_each = var.security_groups

  name        = each.value.name
  description = coalesce(try(each.value.description, null), "Managed security group")
  vpc_id      = var.vpc_id

  tags = merge(
    try(each.value.tags, {}),
    {
      Name = each.value.name
    }
  )
}

locals {
  sg_ids = { for key, sg in aws_security_group.sg : key => sg.id }

  ingress_rules = flatten([
    for sg_key, sg in var.security_groups : [
      for idx, rule in try(sg.ingress_rules, []) : {
        sg_key = sg_key
        idx    = idx
        rule   = rule
      }
    ]
  ])

  egress_rules = flatten([
    for sg_key, sg in var.security_groups : [
      for idx, rule in try(sg.egress_rules, []) : {
        sg_key = sg_key
        idx    = idx
        rule   = rule
      }
    ]
  ])
}

resource "aws_security_group_rule" "ingress" {
  for_each = {
    for item in local.ingress_rules :
    "${item.sg_key}-${item.idx}" => item
  }

  type              = "ingress"
  security_group_id = aws_security_group.sg[each.value.sg_key].id
  from_port         = each.value.rule.from_port
  to_port           = each.value.rule.to_port
  protocol          = each.value.rule.protocol
  cidr_blocks       = try(each.value.rule.cidr_blocks, null)
  ipv6_cidr_blocks  = try(each.value.rule.ipv6_cidr_blocks, null)
  prefix_list_ids   = try(each.value.rule.prefix_list_ids, null)
  source_security_group_id = try(
    local.sg_ids[each.value.rule.source_sg_key],
    null
  )
  self        = try(each.value.rule.self, false)
  description = try(each.value.rule.description, null)
}

resource "aws_security_group_rule" "egress" {
  for_each = {
    for item in local.egress_rules :
    "${item.sg_key}-${item.idx}" => item
  }

  type              = "egress"
  security_group_id = aws_security_group.sg[each.value.sg_key].id
  from_port         = each.value.rule.from_port
  to_port           = each.value.rule.to_port
  protocol          = each.value.rule.protocol
  cidr_blocks       = try(each.value.rule.cidr_blocks, null)
  ipv6_cidr_blocks  = try(each.value.rule.ipv6_cidr_blocks, null)
  prefix_list_ids   = try(each.value.rule.prefix_list_ids, null)
  source_security_group_id = try(
    local.sg_ids[each.value.rule.source_sg_key],
    null
  )
  self        = try(each.value.rule.self, false)
  description = try(each.value.rule.description, null)
}
