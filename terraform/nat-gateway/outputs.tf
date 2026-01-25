output "nat_gateway_ids" {
  description = "Map of NAT Gateway IDs keyed by index."
  value       = { for k, nat in aws_nat_gateway.this : k => nat.id }
}

output "elastic_ip_ids" {
  description = "Map of Elastic IP allocation IDs keyed by index."
  value       = { for k, eip in aws_eip.nat : k => eip.id }
}

output "nat_gateway_names" {
  description = "Map of NAT Gateway Name tags keyed by index."
  value       = local.nat_names
}

output "elastic_ip_names" {
  description = "Map of Elastic IP Name tags keyed by index."
  value       = local.eip_names
}
