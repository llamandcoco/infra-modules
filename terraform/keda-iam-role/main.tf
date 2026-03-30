# -----------------------------------------------------------------------------
# KEDA IAM Role Module (IRSA)
# Creates an IAM role for KEDA to read CloudWatch metrics
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

# Trust policy for OIDC provider
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider}:sub"
      values   = ["system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge(
    var.tags,
    {
      Name = var.role_name
    }
  )
}

# CloudWatch read permissions for KEDA scaler
data "aws_iam_policy_document" "cloudwatch" {
  statement {
    effect    = "Allow"
    actions   = var.cloudwatch_actions
    resources = var.cloudwatch_resources
  }
}

resource "aws_iam_policy" "this" {
  name        = "${var.role_name}-policy"
  description = "IAM policy for KEDA CloudWatch scaler"
  policy      = data.aws_iam_policy_document.cloudwatch.json

  tags = merge(
    var.tags,
    {
      Name = "${var.role_name}-policy"
    }
  )
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
