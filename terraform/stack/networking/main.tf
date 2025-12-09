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
  source = "../../internet_gateway"

  name   = "${var.name}-igw"
  vpc_id = module.vpc.vpc_id
  tags   = local.common_tags
}

module "subnets" {
  source = "../../subnet"

  vpc_id                  = module.vpc.vpc_id
  azs                     = var.azs
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidrs    = var.private_subnet_cidrs
  database_subnet_cidrs   = var.database_subnet_cidrs
  map_public_ip_on_launch = var.map_public_ip_on_launch
  enable_ipv6             = var.enable_ipv6
  name_prefix             = var.name
  tags                    = local.common_tags
}

module "nat_gateway" {
  source = "../../nat_gateway"

  public_subnet_ids = module.subnets.public_subnet_ids
  create_per_az     = var.nat_per_az
  name_prefix       = var.name
  tags              = local.common_tags
}

module "route_tables" {
  source = "../../route_table"

  vpc_id                 = module.vpc.vpc_id
  internet_gateway_id    = module.internet_gateway.internet_gateway_id
  nat_gateway_ids        = module.nat_gateway.nat_gateway_ids
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
