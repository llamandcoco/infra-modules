terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "inline" {
  for_each = { for idx, statement in var.custom_policy_statements : idx => statement }

  statement {
    sid       = each.value.sid != null ? each.value.sid : "CustomPolicy${each.key}"
    effect    = each.value.effect
    actions   = each.value.actions
    resources = each.value.resources
  }
}

# -----------------------------------------------------------------------------
# IAM User
# -----------------------------------------------------------------------------

resource "aws_iam_user" "this" {
  name          = var.name
  path          = var.path
  force_destroy = var.force_destroy
  tags          = merge(var.tags, { Name = var.name })
}

# -----------------------------------------------------------------------------
# Access Keys
# -----------------------------------------------------------------------------

resource "aws_iam_access_key" "this" {
  count = var.create_access_key ? 1 : 0

  user   = aws_iam_user.this.name
  status = var.access_key_status
}

# -----------------------------------------------------------------------------
# Login Profile (Console Access)
# -----------------------------------------------------------------------------

resource "aws_iam_user_login_profile" "this" {
  count = var.create_login_profile ? 1 : 0

  user                    = aws_iam_user.this.name
  pgp_key                 = var.pgp_key
  password_reset_required = var.password_reset_required

  lifecycle {
    precondition {
      condition     = var.pgp_key != null
      error_message = "pgp_key is required when create_login_profile is true."
    }
  }
}

# -----------------------------------------------------------------------------
# Inline Policies
# -----------------------------------------------------------------------------

resource "aws_iam_user_policy" "inline" {
  for_each = { for idx, statement in var.custom_policy_statements : idx => statement }

  name   = each.value.sid != null ? "${each.value.sid}-${each.key}" : "${var.name}-custom-${each.key}"
  user   = aws_iam_user.this.name
  policy = data.aws_iam_policy_document.inline[each.key].json
}

# -----------------------------------------------------------------------------
# Managed Policy Attachments
# -----------------------------------------------------------------------------

resource "aws_iam_user_policy_attachment" "managed" {
  for_each = toset(var.policy_arns)

  user       = aws_iam_user.this.name
  policy_arn = each.value
}

# -----------------------------------------------------------------------------
# Group Memberships
# -----------------------------------------------------------------------------

resource "aws_iam_user_group_membership" "this" {
  count = length(var.group_names) > 0 ? 1 : 0

  user   = aws_iam_user.this.name
  groups = var.group_names
}
