# Wrong: missing descriptions

output "bucket_id" {
  # Missing description
  value = aws_s3_bucket.main.id
}

output "bucketArn" {  # Wrong: camelCase
  # Missing description
  value = aws_s3_bucket.main.arn
}
