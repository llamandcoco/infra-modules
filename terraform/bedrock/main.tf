terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

# Only fetch account ID and region from AWS if not provided via variables
# This allows CI/CD testing without AWS credentials
data "aws_caller_identity" "current" {
  count = var.aws_account_id == null ? 1 : 0
}

data "aws_region" "current" {
  count = var.aws_region == null ? 1 : 0
}

# -----------------------------------------------------------------------------
# Local Variables
# -----------------------------------------------------------------------------

locals {
  # Use provided values if available, otherwise use data sources
  account_id = var.aws_account_id != null ? var.aws_account_id : data.aws_caller_identity.current[0].account_id
  region     = var.aws_region != null ? var.aws_region : data.aws_region.current[0].name

  # Determine if we're creating a service role for external services to use Bedrock
  create_service_role = var.create_service_role

  # Common tags to apply to all resources
  common_tags = merge(
    var.tags,
    {
      ManagedBy = "Terraform"
      Module    = "bedrock"
    }
  )
}

# -----------------------------------------------------------------------------
# CloudWatch Log Group for Bedrock Model Invocation Logging
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "bedrock" {
  count = var.enable_model_invocation_logging ? 1 : 0

  name              = var.log_group_name != null ? var.log_group_name : "/aws/bedrock/modelinvocations"
  retention_in_days = var.log_retention_days

  tags = merge(
    local.common_tags,
    {
      Name = var.log_group_name != null ? var.log_group_name : "/aws/bedrock/modelinvocations"
    }
  )
}

# -----------------------------------------------------------------------------
# IAM Role for CloudWatch Logging
# Bedrock service needs this role to write logs to CloudWatch
# -----------------------------------------------------------------------------
resource "aws_iam_role" "bedrock_logging" {
  count = var.enable_model_invocation_logging ? 1 : 0

  name        = var.logging_role_name != null ? var.logging_role_name : "bedrock-model-invocation-logging-role"
  description = "IAM role for Bedrock model invocation logging to CloudWatch"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:bedrock:${local.region}:${local.account_id}:*"
          }
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = var.logging_role_name != null ? var.logging_role_name : "bedrock-model-invocation-logging-role"
    }
  )
}

# -----------------------------------------------------------------------------
# IAM Policy for CloudWatch Logging
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy" "bedrock_logging" {
  count = var.enable_model_invocation_logging ? 1 : 0

  name = "bedrock-cloudwatch-logs-policy"
  role = aws_iam_role.bedrock_logging[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.bedrock[0].arn}:*"
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# Bedrock Model Invocation Logging Configuration
# -----------------------------------------------------------------------------
resource "aws_bedrock_model_invocation_logging_configuration" "this" {
  count = var.enable_model_invocation_logging ? 1 : 0

  logging_config {
    embedding_data_delivery_enabled = var.log_embedding_data
    image_data_delivery_enabled     = var.log_image_data
    text_data_delivery_enabled      = var.log_text_data

    cloudwatch_config {
      log_group_name = aws_cloudwatch_log_group.bedrock[0].name
      role_arn       = aws_iam_role.bedrock_logging[0].arn
    }

    dynamic "s3_config" {
      for_each = var.s3_logging_bucket != null ? [1] : []

      content {
        bucket_name = var.s3_logging_bucket
        key_prefix  = var.s3_logging_key_prefix
      }
    }
  }

  depends_on = [
    aws_iam_role_policy.bedrock_logging
  ]
}

# -----------------------------------------------------------------------------
# Service IAM Role (Optional)
# For Lambda, EC2, ECS, or other AWS services to invoke Bedrock models
# -----------------------------------------------------------------------------
resource "aws_iam_role" "service" {
  count = local.create_service_role ? 1 : 0

  name        = var.service_role_name
  description = "IAM role for AWS services to invoke Bedrock models"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = var.service_principals
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = var.service_role_name
    }
  )
}

# -----------------------------------------------------------------------------
# Service IAM Policy for Bedrock Model Invocation
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy" "bedrock_invoke" {
  count = local.create_service_role ? 1 : 0

  name = "bedrock-model-invocation-policy"
  role = aws_iam_role.service[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = var.allowed_model_arns
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# Additional IAM Policy Attachments for Service Role
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "service_additional" {
  for_each = local.create_service_role ? toset(var.additional_service_policy_arns) : []

  role       = aws_iam_role.service[0].name
  policy_arn = each.value
}
