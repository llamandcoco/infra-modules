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
  value       = aws_s3_bucket.pipeline_artifacts.id
}

output "artifact_bucket_id" {
  description = "The ID of the S3 bucket for pipeline artifacts."
  value       = aws_s3_bucket.pipeline_artifacts.id
}

output "artifact_bucket_arn" {
  description = "The ARN of the S3 bucket for pipeline artifacts."
  value       = aws_s3_bucket.pipeline_artifacts.arn
}

output "artifact_bucket_region" {
  description = "The AWS region of the S3 bucket."
  value       = aws_s3_bucket.pipeline_artifacts.region
}

# -----------------------------------------------------------------------------
# IAM Role Outputs
# -----------------------------------------------------------------------------

output "pipeline_role_name" {
  description = "The name of the CodePipeline IAM role."
  value       = aws_iam_role.pipeline.name
}

output "pipeline_role_id" {
  description = "The ID of the CodePipeline IAM role."
  value       = aws_iam_role.pipeline.id
}

output "pipeline_role_arn" {
  description = "The ARN of the CodePipeline IAM role."
  value       = aws_iam_role.pipeline.arn
}
