# -----------------------------------------------------------------------------
# IAM Role Module
# Creates an IAM role with assume role policy and optional inline/managed policies
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
# IAM Role
# -----------------------------------------------------------------------------

resource "aws_iam_role" "this" {
  name               = var.name
  description        = var.description
  assume_role_policy = var.assume_role_policy

  max_session_duration  = var.max_session_duration
  path                  = var.path
  permissions_boundary  = var.permissions_boundary
  force_detach_policies = var.force_detach_policies

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

# -----------------------------------------------------------------------------
# Managed Policy Attachments
# -----------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# -----------------------------------------------------------------------------
# Inline Policies
# -----------------------------------------------------------------------------

resource "aws_iam_role_policy" "inline" {
  for_each = var.inline_policies

  name   = each.key
  role   = aws_iam_role.this.id
  policy = each.value
}
