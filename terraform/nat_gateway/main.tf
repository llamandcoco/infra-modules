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
  selected_public_subnets = var.create_per_az ? var.public_subnet_ids : (length(var.public_subnet_ids) > 0 ? [var.public_subnet_ids[0]] : [])
  nat_subnets             = { for idx, subnet_id in local.selected_public_subnets : idx => subnet_id }
  az_suffixes = {
    for idx, subnet_id in local.selected_public_subnets :
    idx => (
      length(var.availability_zones) > idx ?
      regex("[a-z]$", var.availability_zones[idx]) :
      tostring(idx)
    )
  }
  nat_names = { for idx, _ in local.nat_subnets : idx => "${var.name_prefix}-nat-${local.az_suffixes[idx]}" }
  eip_names = { for idx, _ in local.nat_subnets : idx => "${var.name_prefix}-nat-eip-${local.az_suffixes[idx]}" }
}

resource "aws_eip" "nat" {
  for_each = local.nat_subnets

  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = local.eip_names[each.key]
    }
  )
}

resource "aws_nat_gateway" "this" {
  for_each = local.nat_subnets

  allocation_id     = aws_eip.nat[each.key].id
  subnet_id         = each.value
  connectivity_type = "public"

  tags = merge(
    var.tags,
    {
      Name = local.nat_names[each.key]
    }
  )
}
