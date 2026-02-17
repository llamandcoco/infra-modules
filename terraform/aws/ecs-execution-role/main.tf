# -----------------------------------------------------------------------------
# ECS Execution Role Module
# Creates the execution role used by ECS agent to:
# - Pull container images from ECR
# - Send logs to CloudWatch
# - Access SSM Parameter Store for secrets
#
# This is NOT the task role - that's used by your container code to access AWS APIs
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
# ECS Execution Role
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

# Core ECS task execution permissions
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Optional: ECR permissions (pull images)
resource "aws_iam_role_policy_attachment" "ecr" {
  count = var.enable_ecr ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Optional: SSM permissions (parameter store access)
resource "aws_iam_role_policy_attachment" "ssm" {
  count = var.enable_ssm ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

# -----------------------------------------------------------------------------
# Custom Policy for CloudWatch Logs (if enabled)
# -----------------------------------------------------------------------------

resource "aws_iam_role_policy" "cloudwatch_logs" {
  count = var.enable_cw_logs ? 1 : 0

  name   = "${var.name}-cloudwatch-logs"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.cloudwatch_logs[0].json
}

data "aws_iam_policy_document" "cloudwatch_logs" {
  count = var.enable_cw_logs ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

# -----------------------------------------------------------------------------
# Custom Policy for CloudWatch Agent (if enabled)
# -----------------------------------------------------------------------------

resource "aws_iam_role_policy" "cloudwatch_agent" {
  count = var.enable_cw_agent ? 1 : 0

  name   = "${var.name}-cloudwatch-agent"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.cloudwatch_agent[0].json
}

data "aws_iam_policy_document" "cloudwatch_agent" {
  count = var.enable_cw_agent ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "cloudwatch:PutMetricData",
      "ec2:DescribeVolumes",
      "ec2:DescribeTags",
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams"
    ]

    resources = ["*"]
  }
}

# -----------------------------------------------------------------------------
# Additional Custom Policies
# -----------------------------------------------------------------------------

resource "aws_iam_role_policy" "additional" {
  for_each = var.additional_policies

  name   = each.key
  role   = aws_iam_role.this.id
  policy = each.value
}
