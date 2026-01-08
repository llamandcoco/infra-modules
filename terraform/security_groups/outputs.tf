output "security_group_ids" {
  description = "Map of security group IDs keyed by the provided security_groups map keys"
  value       = local.sg_ids
}
