# -----------------------------------------------------------------------------
# CodePipeline Outputs
# -----------------------------------------------------------------------------

output "pipeline_name" {
  description = "The name of the CodePipeline."
  value       = aws_codepipeline.this.name
}

output "pipeline_id" {
  description = "The ID of the CodePipeline."
  value       = aws_codepipeline.this.id
}

output "pipeline_arn" {
  description = "The ARN of the CodePipeline."
  value       = aws_codepipeline.this.arn
}

# -----------------------------------------------------------------------------
# S3 Artifact Bucket Outputs
# -----------------------------------------------------------------------------

output "artifact_bucket_name" {
  description = "The name of the S3 bucket for pipeline artifacts."
  value       = local.artifact_bucket
}

output "artifact_bucket_id" {
  description = "The ID of the S3 bucket for pipeline artifacts."
  value       = local.artifact_bucket
}

output "artifact_bucket_arn" {
  description = "The ARN of the S3 bucket for pipeline artifacts."
  value       = var.create_artifact_bucket ? aws_s3_bucket.pipeline_artifacts[0].arn : "arn:aws:s3:::${var.artifact_bucket_name}"
}

output "artifact_bucket_region" {
  description = "The AWS region of the S3 bucket."
  value       = var.create_artifact_bucket ? aws_s3_bucket.pipeline_artifacts[0].region : local.region
}

# -----------------------------------------------------------------------------
# IAM Role Outputs
# -----------------------------------------------------------------------------

output "pipeline_role_name" {
  description = "The name of the CodePipeline IAM role."
  value       = var.create_service_role ? aws_iam_role.pipeline[0].name : null
}

output "pipeline_role_id" {
  description = "The ID of the CodePipeline IAM role."
  value       = var.create_service_role ? aws_iam_role.pipeline[0].id : null
}

output "pipeline_role_arn" {
  description = "The ARN of the CodePipeline IAM role."
  value       = local.pipeline_role_arn
}
