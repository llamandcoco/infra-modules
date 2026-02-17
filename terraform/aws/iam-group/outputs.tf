output "group_name" {
  description = "Name of the IAM group"
  value       = aws_iam_group.this.name
}

output "group_id" {
  description = "ID of the IAM group"
  value       = aws_iam_group.this.id
}

output "group_arn" {
  description = "ARN of the IAM group"
  value       = aws_iam_group.this.arn
}

output "group_unique_id" {
  description = "Unique ID of the IAM group"
  value       = aws_iam_group.this.unique_id
}

output "attached_policy_arns" {
  description = "List of managed policy ARNs attached to the group"
  value       = var.managed_policy_arns
}

output "inline_policy_names" {
  description = "List of inline policy names attached to the group"
  value       = keys(var.inline_policies)
}

output "member_user_names" {
  description = "List of user names that are members of the group"
  value       = var.user_names
}
