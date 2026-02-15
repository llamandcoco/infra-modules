terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  # Built-in policy configurations
  inline_policy_config = {
    s3_read = {
      enabled = var.enable_s3_read
      name    = "${var.name}-s3-read"
      statements = [
        {
          sid = "S3ReadAccess"
          actions = [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:ListBucket",
            "s3:GetBucketLocation"
          ]
          resources = ["*"]
        }
      ]
    }
    s3_write = {
      enabled = var.enable_s3_write
      name    = "${var.name}-s3-write"
      statements = [
        {
          sid = "S3WriteAccess"
          actions = [
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:DeleteObject"
          ]
          resources = ["*"]
        }
      ]
    }
    ec2_read = {
      enabled = var.enable_ec2_read
      name    = "${var.name}-ec2-read"
      statements = [
        {
          sid = "EC2ReadAccess"
          actions = [
            "ec2:Describe*",
            "ec2:Get*",
            "ec2:List*"
          ]
          resources = ["*"]
        }
      ]
    }
    dynamodb_read = {
      enabled = var.enable_dynamodb_read
      name    = "${var.name}-dynamodb-read"
      statements = [
        {
          sid = "DynamoDBReadAccess"
          actions = [
            "dynamodb:GetItem",
            "dynamodb:BatchGetItem",
            "dynamodb:Query",
            "dynamodb:Scan",
            "dynamodb:DescribeTable"
          ]
          resources = ["*"]
        }
      ]
    }
    dynamodb_write = {
      enabled = var.enable_dynamodb_write
      name    = "${var.name}-dynamodb-write"
      statements = [
        {
          sid = "DynamoDBWriteAccess"
          actions = [
            "dynamodb:PutItem",
            "dynamodb:UpdateItem",
            "dynamodb:DeleteItem",
            "dynamodb:BatchWriteItem"
          ]
          resources = ["*"]
        }
      ]
    }
    logs_read = {
      enabled = var.enable_logs_read
      name    = "${var.name}-logs-read"
      statements = [
        {
          sid = "CloudWatchLogsReadAccess"
          actions = [
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:GetLogEvents",
            "logs:FilterLogEvents"
          ]
          resources = ["*"]
        }
      ]
    }
    ssm_read = {
      enabled = var.enable_ssm_read
      name    = "${var.name}-ssm-read"
      statements = [
        {
          sid = "SSMParameterReadAccess"
          actions = [
            "ssm:GetParameter",
            "ssm:GetParameters",
            "ssm:GetParametersByPath",
            "ssm:DescribeParameters"
          ]
          resources = ["*"]
        }
      ]
    }
  }

  # Filter enabled built-in policies
  enabled_inline_policies = {
    for key, policy in local.inline_policy_config : key => policy if policy.enabled
  }

  # Add custom policies with generated names
  custom_inline_policies = {
    for idx, statement in var.custom_policy_statements :
    "custom-${idx}" => {
      name = "${var.name}-custom-${idx}"
      statements = [
        {
          sid       = statement.sid != null ? statement.sid : "CustomPolicy${idx}"
          actions   = statement.actions
          resources = statement.resources
          effect    = statement.effect
        }
      ]
    }
  }

  # Merge built-in and custom policies
  all_inline_policies = merge(local.enabled_inline_policies, local.custom_inline_policies)
}

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "inline" {
  for_each = local.all_inline_policies

  dynamic "statement" {
    for_each = each.value.statements

    content {
      sid       = lookup(statement.value, "sid", null)
      effect    = lookup(statement.value, "effect", "Allow")
      actions   = statement.value.actions
      resources = statement.value.resources
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
# Inline Policies
# -----------------------------------------------------------------------------

resource "aws_iam_group_policy" "inline" {
  for_each = local.all_inline_policies

  name   = each.value.name
  group  = aws_iam_group.this.name
  policy = data.aws_iam_policy_document.inline[each.key].json
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
# Group Membership
# -----------------------------------------------------------------------------

resource "aws_iam_group_membership" "members" {
  count = length(var.users) > 0 ? 1 : 0

  name  = "${var.name}-membership"
  group = aws_iam_group.this.name
  users = var.users
}
