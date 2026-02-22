# -----------------------------------------------------------------------------
# Replica Outputs
# -----------------------------------------------------------------------------

output "id" {
  description = "ID of the replica instance."
  value       = aws_db_instance.this.id
}

output "arn" {
  description = "ARN of the replica instance."
  value       = aws_db_instance.this.arn
}

output "identifier" {
  description = "Identifier of the replica instance."
  value       = aws_db_instance.this.identifier
}

output "endpoint" {
  description = "Endpoint of the replica instance."
  value       = aws_db_instance.this.endpoint
}

output "address" {
  description = "Address of the replica instance."
  value       = aws_db_instance.this.address
}

output "hosted_zone_id" {
  description = "Hosted zone ID of the replica endpoint."
  value       = aws_db_instance.this.hosted_zone_id
}

output "resource_id" {
  description = "Resource ID of the replica instance."
  value       = aws_db_instance.this.resource_id
}

output "status" {
  description = "Status of the replica instance."
  value       = aws_db_instance.this.status
}

output "tags" {
  description = "Tags assigned to the replica."
  value       = aws_db_instance.this.tags
}

output "tags_all" {
  description = "All tags assigned to the replica."
  value       = aws_db_instance.this.tags_all
}
