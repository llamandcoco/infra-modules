# -----------------------------------------------------------------------------
# AWS Load Balancer Controller IAM Role Module
# Creates IRSA role for AWS Load Balancer Controller
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
# IRSA Role for AWS Load Balancer Controller
# -----------------------------------------------------------------------------

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
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
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

# AWS Load Balancer Controller IAM policy
resource "aws_iam_policy" "this" {
  name        = "${var.role_name}-policy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/aws-lb-controller-policy.json")

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
