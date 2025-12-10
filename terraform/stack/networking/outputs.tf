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

output "security_groups" {
  description = "Security groups created by the stack."
  value = {
    default = module.security_group.security_group_id
  }
}
