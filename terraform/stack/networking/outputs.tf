output "vpc_id" {
  description = "ID of the created VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets."
  value       = module.subnets.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets."
  value       = module.subnets.private_subnet_ids
}

output "database_subnet_ids" {
  description = "IDs of database subnets."
  value       = module.subnets.database_subnet_ids
}

output "route_tables" {
  description = "Route table identifiers."
  value = {
    public   = module.route_tables.public_route_table_id
    private  = module.route_tables.private_route_table_ids
    database = module.route_tables.database_route_table_id
  }
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway (null if not created)."
  value       = local.create_igw ? module.internet_gateway[0].internet_gateway_id : null
}

output "nat_gateway_ids" {
  description = "IDs of NAT Gateways (empty map if not created)."
  value       = local.create_nat ? module.nat_gateway[0].nat_gateway_ids : {}
}

output "security_groups" {
  description = "Security groups created by the stack."
  value = {
    default = module.security_group.security_group_id
  }
}

output "computed_subnet_cidrs" {
  description = "Computed or provided subnet CIDRs."
  value = {
    public   = local.public_subnet_cidrs
    private  = local.private_subnet_cidrs
    database = local.database_subnet_cidrs
  }
}
