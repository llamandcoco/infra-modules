output "public_subnet_ids" {
  description = "IDs of public subnets."
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "IDs of private subnets."
  value       = [for s in aws_subnet.private : s.id]
}

output "database_subnet_ids" {
  description = "IDs of database subnets."
  value       = [for s in aws_subnet.database : s.id]
}

output "availability_zones" {
  description = "Availability zones used for subnets."
  value       = var.azs
}
