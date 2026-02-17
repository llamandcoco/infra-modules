output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "ARN of the VPC."
  value       = aws_vpc.this.arn
}

output "cidr_block" {
  description = "IPv4 CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "ipv6_cidr_block" {
  description = "Amazon provided IPv6 CIDR block of the VPC."
  value       = aws_vpc.this.ipv6_cidr_block
}

output "tags" {
  description = "Tags applied to the VPC."
  value       = aws_vpc.this.tags_all
}

output "default_security_group_id" {
  description = "ID of the default security group."
  value       = aws_vpc.this.default_security_group_id
}

output "default_network_acl_id" {
  description = "ID of the default network ACL."
  value       = aws_vpc.this.default_network_acl_id
}

output "default_route_table_id" {
  description = "ID of the default route table."
  value       = aws_vpc.this.default_route_table_id
}

output "flow_log_id" {
  description = "ID of the VPC Flow Log (if enabled)."
  value       = var.enable_flow_logs ? aws_flow_log.this[0].id : null
}

output "ipv6_association_id" {
  description = "Association ID for the IPv6 CIDR block."
  value       = aws_vpc.this.ipv6_association_id
}
