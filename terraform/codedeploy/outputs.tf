# -----------------------------------------------------------------------------
# Application Outputs
# -----------------------------------------------------------------------------

output "application_id" {
  description = "The ID of the CodeDeploy application."
  value       = aws_codedeploy_app.this.id
}

output "application_name" {
  description = "The name of the CodeDeploy application."
  value       = aws_codedeploy_app.this.name
}

output "application_arn" {
  description = "The ARN of the CodeDeploy application."
  value       = aws_codedeploy_app.this.arn
}

output "compute_platform" {
  description = "The compute platform of the CodeDeploy application."
  value       = aws_codedeploy_app.this.compute_platform
}

# -----------------------------------------------------------------------------
# Deployment Group Outputs
# -----------------------------------------------------------------------------

output "deployment_group_id" {
  description = "The ID of the deployment group."
  value       = aws_codedeploy_deployment_group.this.id
}

output "deployment_group_name" {
  description = "The name of the deployment group."
  value       = aws_codedeploy_deployment_group.this.deployment_group_name
}

output "deployment_group_arn" {
  description = "The ARN of the deployment group."
  value       = aws_codedeploy_deployment_group.this.arn
}

# -----------------------------------------------------------------------------
# IAM Role Outputs
# -----------------------------------------------------------------------------

output "role_name" {
  description = "The name of the IAM role used by CodeDeploy (if created)."
  value       = var.create_service_role ? aws_iam_role.this[0].name : null
}

output "role_arn" {
  description = "The ARN of the IAM role used by CodeDeploy."
  value       = var.create_service_role ? aws_iam_role.this[0].arn : var.service_role_arn
}

output "role_id" {
  description = "The ID of the IAM role used by CodeDeploy (if created)."
  value       = var.create_service_role ? aws_iam_role.this[0].id : null
}
