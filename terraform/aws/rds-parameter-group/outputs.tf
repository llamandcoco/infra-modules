output "id" {
  description = "The DB parameter group ID (same as name)."
  value       = aws_db_parameter_group.this.id
}

output "arn" {
  description = "The ARN of the DB parameter group."
  value       = aws_db_parameter_group.this.arn
}

output "name" {
  description = "The name of the DB parameter group."
  value       = aws_db_parameter_group.this.name
}

output "family" {
  description = "The DB parameter group family."
  value       = aws_db_parameter_group.this.family
}

output "description" {
  description = "The description of the DB parameter group."
  value       = aws_db_parameter_group.this.description
}
