output "policy_id" {
  description = "The ID of the Service Control Policy"
  value       = aws_organizations_policy.region_restriction.id
}

output "policy_arn" {
  description = "The ARN of the Service Control Policy"
  value       = aws_organizations_policy.region_restriction.arn
}

output "policy_name" {
  description = "The name of the Service Control Policy"
  value       = aws_organizations_policy.region_restriction.name
}

output "policy_content" {
  description = "The JSON content of the Service Control Policy"
  value       = aws_organizations_policy.region_restriction.content
}

output "allowed_regions" {
  description = "List of allowed AWS regions"
  value       = var.allowed_regions
}

output "attachment_ids" {
  description = "Map of target IDs to their policy attachment IDs"
  value = {
    for k, v in aws_organizations_policy_attachment.region_restriction : k => v.id
  }
}
