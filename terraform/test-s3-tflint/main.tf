terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# S3 Bucket - intentionally has tflint issues
resource "aws_s3_bucket" "main" {
  bucket = var.bucketName  # Wrong: camelCase instead of snake_case

  tags = var.Tags  # Wrong: capitalized instead of snake_case
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = var.enableVersioning ? "Enabled" : "Disabled"  # Wrong: camelCase
  }
}
