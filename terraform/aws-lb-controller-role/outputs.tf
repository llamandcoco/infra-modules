# -----------------------------------------------------------------------------
# AWS Load Balancer Controller IAM Role Outputs
# -----------------------------------------------------------------------------

output "role_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM role"
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Name of the AWS Load Balancer Controller IAM role"
  value       = aws_iam_role.this.name
}

output "policy_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM policy"
  value       = aws_iam_policy.this.arn
}
