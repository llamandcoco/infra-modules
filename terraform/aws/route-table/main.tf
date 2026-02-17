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
  private_subnet_map  = { for idx, subnet_id in var.private_subnet_ids : tostring(idx) => subnet_id }
  public_subnet_map   = { for idx, subnet_id in var.public_subnet_ids : idx => subnet_id }
  database_subnet_map = { for idx, subnet_id in var.database_subnet_ids : idx => subnet_id }
  nat_gateway_default = try(var.nat_gateway_ids[try(keys(var.nat_gateway_ids)[0], "")], null)
  az_suffixes         = { for idx, az in var.availability_zones : tostring(idx) => regex("[a-z]$", az) }
}

resource "aws_route_table" "public" {
  count  = length(var.public_subnet_ids) > 0 ? 1 : 0
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-rt-public"
      Tier = "public"
    }
  )
}

resource "aws_route" "public_internet" {
  count                  = length(var.public_subnet_ids) > 0 && var.enable_public_internet_route ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id
}

resource "aws_route_table_association" "public_subnets" {
  for_each       = length(aws_route_table.public) > 0 ? local.public_subnet_map : {}
  route_table_id = aws_route_table.public[0].id
  subnet_id      = each.value
}

resource "aws_route_table" "private" {
  for_each = local.private_subnet_map
  vpc_id   = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-rt-private-${coalesce(try(local.az_suffixes[each.key], null), each.key)}"
      Tier = "private"
    }
  )
}

resource "aws_route" "private_nat" {
  for_each = var.enable_private_default_route && length(var.nat_gateway_ids) > 0 ? local.private_subnet_map : {}

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = coalesce(try(var.nat_gateway_ids[each.key], null), local.nat_gateway_default)
}

resource "aws_route_table_association" "private" {
  for_each = local.private_subnet_map

  route_table_id = aws_route_table.private[each.key].id
  subnet_id      = each.value
}

resource "aws_route_table" "database" {
  count  = length(var.database_subnet_ids) > 0 ? 1 : 0
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-rt-database"
      Tier = "database"
    }
  )
}

resource "aws_route" "database_nat" {
  count                  = length(aws_route_table.database) > 0 && var.database_route_via_nat && length(var.nat_gateway_ids) > 0 ? 1 : 0
  route_table_id         = aws_route_table.database[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = local.nat_gateway_default
}

resource "aws_route_table_association" "database" {
  for_each       = length(aws_route_table.database) > 0 ? local.database_subnet_map : {}
  route_table_id = aws_route_table.database[0].id
  subnet_id      = each.value
}
