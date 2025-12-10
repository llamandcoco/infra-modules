terraform {
  required_version = ">= 1.0"
}

locals {
  # Auto-calculate subnet CIDRs from VPC CIDR if not provided
  num_azs = length(var.azs)

  # Calculate /20 subnets (4096 IPs each) from VPC CIDR
  # Assumes /16 VPC CIDR (common pattern)
  auto_public_cidrs = [
    for idx in range(local.num_azs) :
    cidrsubnet(var.cidr_block, 4, idx) # /16 -> /20, starting at index 0
  ]

  auto_private_cidrs = [
    for idx in range(local.num_azs) :
    cidrsubnet(var.cidr_block, 4, idx + local.num_azs) # Next range
  ]

  auto_database_cidrs = [
    for idx in range(local.num_azs) :
    cidrsubnet(var.cidr_block, 4, idx + local.num_azs * 2) # Third range
  ]

  # Use provided values or auto-calculated
  public_subnet_cidrs   = var.public_subnet_cidrs != null ? var.public_subnet_cidrs : local.auto_public_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs != null ? var.private_subnet_cidrs : local.auto_private_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs != null ? var.database_subnet_cidrs : local.auto_database_cidrs

  # NAT gateway mode (support deprecated nat_per_az for backwards compatibility)
  nat_mode   = var.nat_per_az != null ? (var.nat_per_az ? "per_az" : "single") : var.nat_gateway_mode
  create_nat = local.nat_mode != "none" && length(local.public_subnet_cidrs) > 0
  nat_per_az = local.nat_mode == "per_az"

  # IGW enabled if explicitly set and public subnets exist
  create_igw = var.internet_gateway_enabled && length(local.public_subnet_cidrs) > 0

  common_tags = merge(
    {
      Component = "networking"
    },
    var.tags
  )
}

module "vpc" {
  source = "../../vpc"

  name        = var.name
  cidr_block  = var.cidr_block
  enable_ipv6 = var.enable_ipv6

  enable_dns_support                   = var.enable_dns_support
  enable_dns_hostnames                 = var.enable_dns_hostnames
  enable_network_address_usage_metrics = var.enable_network_address_usage_metrics
  instance_tenancy                     = var.instance_tenancy
  tags                                 = local.common_tags
}

module "internet_gateway" {
  count  = local.create_igw ? 1 : 0
  source = "../../internet_gateway"

  name   = "${var.name}-igw"
  vpc_id = module.vpc.vpc_id
  tags   = local.common_tags
}

module "subnets" {
  source = "../../subnet"

  vpc_id                  = module.vpc.vpc_id
  azs                     = var.azs
  public_subnet_cidrs     = local.public_subnet_cidrs
  private_subnet_cidrs    = local.private_subnet_cidrs
  database_subnet_cidrs   = local.database_subnet_cidrs
  map_public_ip_on_launch = var.map_public_ip_on_launch
  enable_ipv6             = var.enable_ipv6
  name_prefix             = var.name
  tags                    = local.common_tags
}

module "nat_gateway" {
  count  = local.create_nat ? 1 : 0
  source = "../../nat_gateway"

  public_subnet_ids = module.subnets.public_subnet_ids
  create_per_az     = local.nat_per_az
  name_prefix       = var.name
  tags              = local.common_tags
}

module "route_tables" {
  source = "../../route_table"

  vpc_id                 = module.vpc.vpc_id
  internet_gateway_id    = local.create_igw ? module.internet_gateway[0].internet_gateway_id : null
  nat_gateway_ids        = local.create_nat ? module.nat_gateway[0].nat_gateway_ids : {}
  public_subnet_ids      = module.subnets.public_subnet_ids
  private_subnet_ids     = module.subnets.private_subnet_ids
  database_subnet_ids    = module.subnets.database_subnet_ids
  database_route_via_nat = var.database_route_via_nat
  name_prefix            = var.name
  tags                   = local.common_tags
}

module "security_group" {
  source = "../../security_group"

  name          = "${var.name}-default-sg"
  description   = "Default workload security group"
  vpc_id        = module.vpc.vpc_id
  ingress_rules = var.workload_security_group_ingress
  egress_rules  = var.workload_security_group_egress
  tags          = local.common_tags
}
