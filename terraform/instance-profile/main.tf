terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  role_name    = "${var.name}-role"
  profile_name = "${var.name}-profile"
}

data "aws_iam_policy_document" "assume_ec2" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_ec2.json
  tags               = var.tags
}

data "aws_iam_policy_document" "ecr" {
  count = var.enable_ecr ? 1 : 0
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:DescribeRepositories",
      "ecr:DescribeImages"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecr" {
  count  = var.enable_ecr ? 1 : 0
  name   = "${var.name}-ecr"
  policy = data.aws_iam_policy_document.ecr[0].json
}

resource "aws_iam_role_policy_attachment" "ecr" {
  count      = var.enable_ecr ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.ecr[0].arn
}

data "aws_iam_policy_document" "ssm" {
  count = var.enable_ssm ? 1 : 0
  statement {
    actions   = ["ssm:GetParameter", "ssm:GetParameters"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ssm" {
  count  = var.enable_ssm ? 1 : 0
  name   = "${var.name}-ssm"
  policy = data.aws_iam_policy_document.ssm[0].json
}

resource "aws_iam_role_policy_attachment" "ssm" {
  count      = var.enable_ssm ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.ssm[0].arn
}

data "aws_iam_policy_document" "cw_logs" {
  count = var.enable_cw_logs ? 1 : 0
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cw_logs" {
  count  = var.enable_cw_logs ? 1 : 0
  name   = "${var.name}-cw-logs"
  policy = data.aws_iam_policy_document.cw_logs[0].json
}

resource "aws_iam_role_policy_attachment" "cw_logs" {
  count      = var.enable_cw_logs ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.cw_logs[0].arn
}

data "aws_iam_policy_document" "cw_agent" {
  count = var.enable_cw_agent ? 1 : 0
  statement {
    actions = [
      "cloudwatch:PutMetricData",
      "ec2:DescribeVolumes",
      "ec2:DescribeTags",
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "ssm:GetParameter"
    ]
    resources = ["arn:aws:ssm:*:*:parameter/CloudWatch-Config/*"]
  }
}

resource "aws_iam_policy" "cw_agent" {
  count  = var.enable_cw_agent ? 1 : 0
  name   = "${var.name}-cw-agent"
  policy = data.aws_iam_policy_document.cw_agent[0].json
}

resource "aws_iam_role_policy_attachment" "cw_agent" {
  count      = var.enable_cw_agent ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.cw_agent[0].arn
}

resource "aws_iam_instance_profile" "this" {
  name = local.profile_name
  role = aws_iam_role.this.name
  tags = var.tags
}
