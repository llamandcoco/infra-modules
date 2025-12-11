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
# Local Variables and Validations
# -----------------------------------------------------------------------------

locals {
  # Determine which deployment method is being used
  using_s3    = var.s3_bucket != null && var.s3_key != null
  using_local = var.filename != null

  # Ensure exactly one deployment method is specified
  deployment_methods_count = (local.using_s3 ? 1 : 0) + (local.using_local ? 1 : 0)

  # Validate deployment method configuration
  validate_deployment = local.deployment_methods_count == 1 ? true : tobool("Exactly one deployment method must be specified: either (s3_bucket AND s3_key) OR filename")
}

# -----------------------------------------------------------------------------
# IAM Role
# Creates the execution role for the Lambda function with assume role policy
# -----------------------------------------------------------------------------
resource "aws_iam_role" "this" {
  name        = "${var.function_name}-lambda-role"
  description = "Execution role for Lambda function ${var.function_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.function_name}-lambda-role"
    }
  )
}

# -----------------------------------------------------------------------------
# CloudWatch Logs IAM Policy
# Creates an inline policy for CloudWatch Logs access if enabled
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy" "cloudwatch_logs" {
  count = var.create_cloudwatch_log_policy ? 1 : 0

  name = "${var.function_name}-cloudwatch-logs"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "${aws_cloudwatch_log_group.this.arn}:*"
        ]
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# Additional IAM Policy Attachments
# Attaches custom policies for additional permissions
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "additional" {
  for_each = toset(var.additional_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# -----------------------------------------------------------------------------
# CloudWatch Log Group
# Creates a log group for Lambda function logs with retention policy
# tfsec:ignore:aws-cloudwatch-log-group-customer-key - KMS encryption is optional and can be added in Phase 2
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Name = "/aws/lambda/${var.function_name}"
    }
  )
}

# -----------------------------------------------------------------------------
# Lambda Function
# Creates the Lambda function with specified configuration
# tfsec:ignore:aws-lambda-enable-tracing - X-Ray tracing is optional and will be added in Phase 2
# -----------------------------------------------------------------------------
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  description   = var.description
  role          = aws_iam_role.this.arn

  # Runtime configuration
  runtime = var.runtime
  handler = var.handler

  # Performance configuration
  timeout                        = var.timeout
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions

  # Deployment configuration - S3
  s3_bucket         = local.using_s3 ? var.s3_bucket : null
  s3_key            = local.using_s3 ? var.s3_key : null
  s3_object_version = local.using_s3 ? var.s3_object_version : null

  # Deployment configuration - Local
  filename         = local.using_local ? var.filename : null
  source_code_hash = local.using_local ? var.source_code_hash : null

  # Environment variables
  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []

    content {
      variables = var.environment_variables
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.function_name
    }
  )

  # Ensure log group is created before function
  depends_on = [
    aws_cloudwatch_log_group.this,
    aws_iam_role_policy.cloudwatch_logs
  ]
}
