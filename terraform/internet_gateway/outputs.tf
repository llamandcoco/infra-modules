output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = length(aws_internet_gateway.this) > 0 ? aws_internet_gateway.this[0].id : null
}

output "internet_gateway_arn" {
  description = "ARN of the Internet Gateway."
  value       = length(aws_internet_gateway.this) > 0 ? aws_internet_gateway.this[0].arn : null
}
