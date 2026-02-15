output "group_name" {
  description = "Name of the IAM group"
  value       = aws_iam_group_policy_attachment.this.group
}

output "policy_arn" {
  description = "ARN of the attached IAM policy"
  value       = aws_iam_group_policy_attachment.this.policy_arn
}

output "id" {
  description = "ID of the policy attachment"
  value       = aws_iam_group_policy_attachment.this.id
}
