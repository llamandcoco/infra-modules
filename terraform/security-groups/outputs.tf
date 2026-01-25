# -----------------------------------------------------------------------------
# Security Group Outputs
# -----------------------------------------------------------------------------

output "security_group_ids" {
  description = "Map of security group IDs keyed by the provided security_groups map keys."
  value       = local.sg_ids
}

output "security_group_arns" {
  description = "Map of security group ARNs keyed by the provided security_groups map keys."
  value       = { for key, sg in aws_security_group.sg : key => sg.arn }
}

output "security_group_names" {
  description = "Map of security group names keyed by the provided security_groups map keys."
  value       = { for key, sg in aws_security_group.sg : key => sg.name }
}
