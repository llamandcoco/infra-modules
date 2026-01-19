output "role_name" {
  description = "IAM role name"
  value       = aws_iam_role.this.name
}

output "role_arn" {
  description = "IAM role ARN"
  value       = aws_iam_role.this.arn
}

output "instance_profile_name" {
  description = "Instance profile name"
  value       = aws_iam_instance_profile.this.name
}

output "instance_profile_arn" {
  description = "Instance profile ARN"
  value       = aws_iam_instance_profile.this.arn
}

output "attached_policy_arns" {
  description = "List of additional managed policy ARNs attached to the role"
  value       = var.additional_policy_arns
}

output "inline_policy_names" {
  description = "Map of inline policy names attached to the role"
  value = {
    for key, policy in local.all_inline_policies :
    key => policy.name
  }
}
