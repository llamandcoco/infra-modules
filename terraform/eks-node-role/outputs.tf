# -----------------------------------------------------------------------------
# EKS Node IAM Role Outputs
# -----------------------------------------------------------------------------

output "role_arn" {
  description = "ARN of the EKS node IAM role"
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Name of the EKS node IAM role"
  value       = aws_iam_role.this.name
}

output "role_id" {
  description = "ID of the EKS node IAM role"
  value       = aws_iam_role.this.id
}
