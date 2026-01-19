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
  role_name    = "${var.name}-role"
  profile_name = "${var.name}-profile"

  # Built-in policy configurations
  inline_policy_config = {
    ecr = {
      enabled = var.enable_ecr
      name    = "${var.name}-ecr"
      statements = [
        {
          sid = "ECRPullPermissions"
          actions = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchGetImage",
            "ecr:GetDownloadUrlForLayer",
            "ecr:DescribeRepositories",
            "ecr:DescribeImages"
          ]
          resources = ["*"]
        }
      ]
    }
    ssm = {
      enabled = var.enable_ssm
      name    = "${var.name}-ssm"
      statements = [
        {
          sid       = "SSMParameterAccess"
          actions   = ["ssm:GetParameter", "ssm:GetParameters"]
          resources = ["*"]
        }
      ]
    }
    ssm_session_manager = {
      enabled = var.enable_ssm_session_manager
      name    = "${var.name}-ssm-session"
      statements = [
        {
          sid = "SSMSessionManager"
          actions = [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
          ]
          resources = ["*"]
        },
        {
          sid = "EC2InstanceConnect"
          actions = [
            "ec2messages:AcknowledgeMessage",
            "ec2messages:GetEndpoint",
            "ec2messages:GetMessages",
            "ec2messages:SendReply"
          ]
          resources = ["*"]
        }
      ]
    }
    cw_logs = {
      enabled = var.enable_cw_logs
      name    = "${var.name}-cw-logs"
      statements = [
        {
          sid = "CloudWatchLogsAccess"
          actions = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams"
          ]
          resources = ["*"]
        }
      ]
    }
    cw_agent = {
      enabled = var.enable_cw_agent
      name    = "${var.name}-cw-agent"
      statements = [
        {
          sid = "CloudWatchAgentMetrics"
          actions = [
            "cloudwatch:PutMetricData",
            "ec2:DescribeVolumes",
            "ec2:DescribeTags",
            "logs:PutLogEvents",
            "logs:CreateLogStream",
            "logs:CreateLogGroup",
            "logs:DescribeLogStreams"
          ]
          resources = ["*"]
        },
        {
          sid       = "CloudWatchAgentConfig"
          actions   = ["ssm:GetParameter"]
          resources = ["arn:aws:ssm:*:*:parameter/CloudWatch-Config/*"]
        }
      ]
    }
    s3_logs = {
      enabled = length(var.s3_log_buckets) > 0
      name    = "${var.name}-s3-logs"
      statements = [
        {
          sid       = "S3LogStorage"
          actions   = ["s3:PutObject", "s3:PutObjectAcl", "s3:GetEncryptionConfiguration"]
          resources = [for bucket_arn in var.s3_log_buckets : "${bucket_arn}/*"]
        },
        {
          sid       = "S3BucketAccess"
          actions   = ["s3:GetBucketLocation", "s3:ListBucket"]
          resources = var.s3_log_buckets
        }
      ]
    }
    kms = {
      enabled = length(var.kms_key_arns) > 0
      name    = "${var.name}-kms"
      statements = [
        {
          sid       = "KMSDecryption"
          actions   = ["kms:Decrypt", "kms:DescribeKey", "kms:GenerateDataKey"]
          resources = var.kms_key_arns
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

data "aws_iam_policy_document" "assume_ec2" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

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
# IAM Role
# -----------------------------------------------------------------------------

resource "aws_iam_role" "this" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_ec2.json
  tags               = merge(var.tags, { Name = local.role_name })
}

# -----------------------------------------------------------------------------
# Inline Policies
# -----------------------------------------------------------------------------

resource "aws_iam_role_policy" "inline" {
  for_each = local.all_inline_policies

  name   = each.value.name
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.inline[each.key].json
}

# -----------------------------------------------------------------------------
# Additional Managed Policy Attachments
# -----------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = toset(var.additional_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# -----------------------------------------------------------------------------
# Instance Profile
# -----------------------------------------------------------------------------

resource "aws_iam_instance_profile" "this" {
  name = local.profile_name
  role = aws_iam_role.this.name
  tags = merge(var.tags, { Name = local.profile_name })
}
