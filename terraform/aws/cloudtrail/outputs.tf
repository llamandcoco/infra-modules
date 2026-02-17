output "trail_id" {
  description = "ID of the CloudTrail trail."
  value       = aws_cloudtrail.this.id
}

output "trail_arn" {
  description = "ARN of the CloudTrail trail."
  value       = aws_cloudtrail.this.arn
}

output "trail_home_region" {
  description = "Region in which the CloudTrail trail was created."
  value       = aws_cloudtrail.this.home_region
}

output "cloudwatch_logs_role_arn" {
  description = "ARN of the IAM role for CloudWatch Logs integration (null if disabled)."
  value       = var.cloudwatch_logs_group_arn != null ? aws_iam_role.cloudwatch_logs[0].arn : null
}

output "is_multi_region_trail" {
  description = "Whether the trail captures events from all regions."
  value       = aws_cloudtrail.this.is_multi_region_trail
}
