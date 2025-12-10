output "trail_id" {
  description = "ID of the CloudTrail trail."
  value       = module.cloudtrail.trail_id
}

output "trail_arn" {
  description = "ARN of the CloudTrail trail."
  value       = module.cloudtrail.trail_arn
}

output "trail_home_region" {
  description = "Region in which the CloudTrail trail was created."
  value       = module.cloudtrail.trail_home_region
}

output "s3_bucket_id" {
  description = "ID of the S3 bucket storing CloudTrail logs."
  value       = module.s3.bucket_id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket storing CloudTrail logs."
  value       = module.s3.bucket_arn
}

output "s3_bucket_region" {
  description = "Region of the S3 bucket storing CloudTrail logs."
  value       = module.s3.bucket_region
}

output "cloudwatch_logs_role_arn" {
  description = "ARN of the IAM role for CloudWatch Logs integration (null if disabled)."
  value       = module.cloudtrail.cloudwatch_logs_role_arn
}

output "is_multi_region_trail" {
  description = "Whether the trail captures events from all regions."
  value       = module.cloudtrail.is_multi_region_trail
}
