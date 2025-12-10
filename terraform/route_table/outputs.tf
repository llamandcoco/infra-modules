output "public_route_table_id" {
  description = "ID of the public route table."
  value       = length(aws_route_table.public) > 0 ? aws_route_table.public[0].id : null
}

output "private_route_table_ids" {
  description = "IDs of private route tables."
  value       = { for k, rt in aws_route_table.private : k => rt.id }
}

output "database_route_table_id" {
  description = "ID of the database route table, if created."
  value       = length(aws_route_table.database) > 0 ? aws_route_table.database[0].id : null
}
