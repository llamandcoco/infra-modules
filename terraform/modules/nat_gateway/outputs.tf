output "nat_gateway_ids" {
  description = "Map of NAT Gateway IDs keyed by index."
  value       = { for k, nat in aws_nat_gateway.this : k => nat.id }
}

output "elastic_ip_ids" {
  description = "Map of Elastic IP allocation IDs keyed by index."
  value       = { for k, eip in aws_eip.nat : k => eip.id }
}
