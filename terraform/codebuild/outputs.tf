# -----------------------------------------------------------------------------
# CodeBuild Project Outputs
# -----------------------------------------------------------------------------

output "project_name" {
  description = "The name of the CodeBuild project."
  value       = aws_codebuild_project.this.name
}

output "project_id" {
  description = "The ID of the CodeBuild project."
  value       = aws_codebuild_project.this.id
}

output "project_arn" {
  description = "The ARN of the CodeBuild project."
  value       = aws_codebuild_project.this.arn
}

output "badge_url" {
  description = "The URL of the build badge when badge_enabled is true."
  value       = try(aws_codebuild_project.this.badge_url, null)
}

# -----------------------------------------------------------------------------
# GitHub Webhook Outputs
# -----------------------------------------------------------------------------

output "webhook_url" {
  description = "The GitHub webhook payload URL (if webhook is enabled)."
  value       = try(aws_codebuild_webhook.github[0].payload_url, null)
}

output "webhook_secret" {
  description = "The GitHub webhook secret (if webhook is enabled)."
  value       = try(aws_codebuild_webhook.github[0].secret, null)
  sensitive   = true
}

# -----------------------------------------------------------------------------
# IAM Outputs
# -----------------------------------------------------------------------------

output "role_name" {
  description = "The name of the IAM role used by CodeBuild."
  value       = aws_iam_role.this.name
}

output "role_arn" {
  description = "The ARN of the IAM role used by CodeBuild."
  value       = aws_iam_role.this.arn
}

output "role_id" {
  description = "The ID of the IAM role used by CodeBuild."
  value       = aws_iam_role.this.id
}

# -----------------------------------------------------------------------------
# CloudWatch Logs Outputs
# -----------------------------------------------------------------------------

output "log_group_name" {
  description = "The name of the CloudWatch Log Group for build logs."
  value       = aws_cloudwatch_log_group.logs.name
}

output "log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for build logs."
  value       = aws_cloudwatch_log_group.logs.arn
}

# -----------------------------------------------------------------------------
# Source Credential Outputs
# -----------------------------------------------------------------------------

output "source_credential_arn" {
  description = "The ARN of the GitHub source credential (if created)."
  value       = try(aws_codebuild_source_credential.github[0].arn, null)
}
