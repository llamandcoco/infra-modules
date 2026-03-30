# -----------------------------------------------------------------------------
# KEDA IAM Role Outputs
# -----------------------------------------------------------------------------

output "role_arn" {
  description = "ARN of the KEDA IAM role"
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Name of the KEDA IAM role"
  value       = aws_iam_role.this.name
}

output "policy_arn" {
  description = "ARN of the KEDA IAM policy"
  value       = aws_iam_policy.this.arn
}
