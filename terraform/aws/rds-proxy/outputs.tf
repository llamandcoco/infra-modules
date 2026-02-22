output "proxy_id" {
  description = "The Amazon Resource Name (ARN) for the proxy."
  value       = aws_db_proxy.this.id
}

output "proxy_arn" {
  description = "The ARN of the RDS Proxy."
  value       = aws_db_proxy.this.arn
}

output "proxy_name" {
  description = "The identifier of the RDS Proxy."
  value       = aws_db_proxy.this.name
}

output "proxy_endpoint" {
  description = "The endpoint that you can use to connect to the proxy. Includes the port."
  value       = aws_db_proxy.this.endpoint
}

output "proxy_engine_family" {
  description = "The engine family of the RDS Proxy."
  value       = aws_db_proxy.this.engine_family
}

output "proxy_require_tls" {
  description = "Whether the proxy requires TLS encryption."
  value       = aws_db_proxy.this.require_tls
}

output "target_group_arn" {
  description = "The ARN of the default target group."
  value       = aws_db_proxy_default_target_group.this.arn
}

output "target_group_name" {
  description = "The name of the default target group."
  value       = aws_db_proxy_default_target_group.this.name
}

output "security_group_id" {
  description = "The ID of the security group created for the RDS Proxy (if create_security_group was true)."
  value       = var.create_security_group ? aws_security_group.this[0].id : null
}

output "security_group_arn" {
  description = "The ARN of the security group created for the RDS Proxy (if create_security_group was true)."
  value       = var.create_security_group ? aws_security_group.this[0].arn : null
}

output "tags" {
  description = "All tags applied to the RDS Proxy."
  value       = aws_db_proxy.this.tags_all
}
