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
# IAM Group
# -----------------------------------------------------------------------------

resource "aws_iam_group" "this" {
  name = var.name
  path = var.path
}

# -----------------------------------------------------------------------------
# Managed Policy Attachments
# -----------------------------------------------------------------------------

resource "aws_iam_group_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  group      = aws_iam_group.this.name
  policy_arn = each.value
}

# -----------------------------------------------------------------------------
# Inline Policies
# -----------------------------------------------------------------------------

resource "aws_iam_group_policy" "inline" {
  for_each = var.inline_policies

  name   = each.key
  group  = aws_iam_group.this.name
  policy = each.value
}

# -----------------------------------------------------------------------------
# Group Membership
# -----------------------------------------------------------------------------

resource "aws_iam_user_group_membership" "members" {
  for_each = toset(var.user_names)

  user = each.value

  groups = [
    aws_iam_group.this.name
  ]
}
