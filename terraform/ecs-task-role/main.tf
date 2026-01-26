# -----------------------------------------------------------------------------
# ECS Task Role Module
# Creates the task role used by your container code to access AWS services.
# This is NOT the execution role - that's used by ECS agent for image pulls/logs
#
# Use this role to grant your application permissions to:
# - Read/write to S3 buckets
# - Query DynamoDB tables
# - Send messages to SQS queues
# - Invoke Lambda functions
# - Any other AWS API calls your container makes
# -----------------------------------------------------------------------------

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
# ECS Task Role
# -----------------------------------------------------------------------------

resource "aws_iam_role" "this" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

# Trust policy for ECS tasks
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# -----------------------------------------------------------------------------
# AWS Managed Policy Attachments
# -----------------------------------------------------------------------------

# Attach AWS managed policies
resource "aws_iam_role_policy_attachment" "managed_policies" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# -----------------------------------------------------------------------------
# Custom Inline Policies
# -----------------------------------------------------------------------------

resource "aws_iam_role_policy" "inline_policies" {
  for_each = var.inline_policies

  name   = each.key
  role   = aws_iam_role.this.id
  policy = each.value
}

# -----------------------------------------------------------------------------
# Optional: Common Service Permissions
# -----------------------------------------------------------------------------

# S3 access (if enabled)
resource "aws_iam_role_policy" "s3" {
  count = var.enable_s3_access && length(var.s3_bucket_arns) > 0 ? 1 : 0

  name   = "${var.name}-s3-access"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.s3[0].json
}

data "aws_iam_policy_document" "s3" {
  count = var.enable_s3_access && length(var.s3_bucket_arns) > 0 ? 1 : 0

  statement {
    effect = "Allow"

    actions = var.s3_actions

    resources = concat(
      var.s3_bucket_arns,
      [for arn in var.s3_bucket_arns : "${arn}/*"]
    )
  }
}

# DynamoDB access (if enabled)
resource "aws_iam_role_policy" "dynamodb" {
  count = var.enable_dynamodb_access && length(var.dynamodb_table_arns) > 0 ? 1 : 0

  name   = "${var.name}-dynamodb-access"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.dynamodb[0].json
}

data "aws_iam_policy_document" "dynamodb" {
  count = var.enable_dynamodb_access && length(var.dynamodb_table_arns) > 0 ? 1 : 0

  statement {
    effect = "Allow"

    actions = var.dynamodb_actions

    resources = concat(
      var.dynamodb_table_arns,
      [for arn in var.dynamodb_table_arns : "${arn}/index/*"]
    )
  }
}

# SQS access (if enabled)
resource "aws_iam_role_policy" "sqs" {
  count = var.enable_sqs_access && length(var.sqs_queue_arns) > 0 ? 1 : 0

  name   = "${var.name}-sqs-access"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.sqs[0].json
}

data "aws_iam_policy_document" "sqs" {
  count = var.enable_sqs_access && length(var.sqs_queue_arns) > 0 ? 1 : 0

  statement {
    effect = "Allow"

    actions = var.sqs_actions

    resources = var.sqs_queue_arns
  }
}

# Secrets Manager access (if enabled)
resource "aws_iam_role_policy" "secrets_manager" {
  count = var.enable_secrets_manager && length(var.secret_arns) > 0 ? 1 : 0

  name   = "${var.name}-secrets-manager"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.secrets_manager[0].json
}

data "aws_iam_policy_document" "secrets_manager" {
  count = var.enable_secrets_manager && length(var.secret_arns) > 0 ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    resources = var.secret_arns
  }
}
