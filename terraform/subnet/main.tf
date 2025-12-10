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
  public_subnets = {
    for idx, cidr in var.public_subnet_cidrs :
    idx => {
      cidr = cidr
      az   = var.azs[idx]
    }
  }

  private_subnets = {
    for idx, cidr in var.private_subnet_cidrs :
    idx => {
      cidr = cidr
      az   = var.azs[idx]
    }
  }

  database_subnets = {
    for idx, cidr in var.database_subnet_cidrs :
    idx => {
      cidr = cidr
      az   = var.azs[idx]
    }
  }
}

# trivy:ignore:AVD-AWS-0164
resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                          = var.vpc_id
  cidr_block                      = each.value.cidr
  availability_zone               = each.value.az
  map_public_ip_on_launch         = var.map_public_ip_on_launch
  assign_ipv6_address_on_creation = var.enable_ipv6

  tags = merge(
    var.tags,
    var.public_subnet_tags,
    {
      Name = "${var.name_prefix}-public-${each.value.az}"
      Tier = "public"
    }
  )
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.tags,
    var.private_subnet_tags,
    {
      Name = "${var.name_prefix}-private-${each.value.az}"
      Tier = "private"
    }
  )
}

resource "aws_subnet" "database" {
  for_each = local.database_subnets

  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.tags,
    var.database_subnet_tags,
    {
      Name = "${var.name_prefix}-database-${each.value.az}"
      Tier = "database"
    }
  )
}
