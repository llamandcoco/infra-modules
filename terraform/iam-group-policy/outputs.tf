output "group_name" {
  description = "IAM group name"
  value       = aws_iam_group.this.name
}

output "group_arn" {
  description = "IAM group ARN"
  value       = aws_iam_group.this.arn
}

output "group_id" {
  description = "IAM group ID"
  value       = aws_iam_group.this.id
}

output "managed_policy_arns" {
  description = "List of managed policy ARNs attached to the group"
  value       = var.managed_policy_arns
}

output "inline_policy_names" {
  description = "Map of inline policy names attached to the group"
  value = {
    for key, policy in local.all_inline_policies :
    key => policy.name
  }
}

output "users" {
  description = "List of users in the group"
  value       = var.users
}
