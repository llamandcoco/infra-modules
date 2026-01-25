terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# Data source to get the TLS certificate thumbprint
data "tls_certificate" "oidc" {
  url = "https://${var.provider_url}"
}

# OIDC Provider
# Creates an OpenID Connect provider for authenticating external services
resource "aws_iam_openid_connect_provider" "this" {
  url             = "https://${var.provider_url}"
  client_id_list  = var.client_id_list
  thumbprint_list = var.thumbprint_list != null ? var.thumbprint_list : [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]

  tags = merge(
    var.tags,
    {
      Name = "oidc-${replace(var.provider_url, ".", "-")}"
    }
  )
}

# Locals for building trust policy conditions
locals {
  # GitHub Actions OIDC subjects
  github_subjects = var.github_org != null && var.github_repo != null ? [
    "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${var.github_branch}"
  ] : []

  # Combine GitHub and custom OIDC subjects
  all_subjects = concat(local.github_subjects, var.oidc_subjects)

  # Build trust policy condition
  trust_condition = length(local.all_subjects) > 0 ? {
    StringLike = {
      "${var.provider_url}:sub" = local.all_subjects
    }
  } : {}
}

# IAM Role for OIDC Authentication
# Allows the OIDC provider to assume this role with configured permissions
resource "aws_iam_role" "this" {
  name                 = var.role_name
  description          = var.role_description
  max_session_duration = var.max_session_duration

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.this.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = merge(
          {
            StringEquals = {
              "${var.provider_url}:aud" = var.client_id_list[0]
            }
          },
          local.trust_condition
        )
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = var.role_name
    }
  )
}

# Attach managed policies to the role
resource "aws_iam_role_policy_attachment" "this" {
  for_each = toset(var.policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# Create inline policies for the role
resource "aws_iam_role_policy" "this" {
  count = length(var.inline_policy_statements) > 0 ? 1 : 0

  name = "${var.role_name}-inline-policy"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for statement in var.inline_policy_statements : merge(
        {
          Sid      = statement.sid
          Effect   = statement.effect
          Action   = statement.actions
          Resource = statement.resources
        },
        statement.condition != null ? {
          Condition = {
            for cond in statement.condition :
            cond.test => {
              (cond.variable) = cond.values
            }
          }
        } : {}
      )
    ]
  })
}
