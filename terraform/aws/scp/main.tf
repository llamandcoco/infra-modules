terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Service Control Policy to restrict resource creation to specific regions
resource "aws_organizations_policy" "region_restriction" {
  name        = var.policy_name
  description = var.description
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.region_restriction.json

  tags = var.tags
}

# Policy document that denies actions outside allowed regions
data "aws_iam_policy_document" "region_restriction" {
  statement {
    sid    = "DenyAllOutsideAllowedRegions"
    effect = "Deny"

    # Deny all actions
    actions = ["*"]

    # On all resources
    resources = ["*"]

    # Except when the requested region is in the allowed list
    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"
      values   = var.allowed_regions
    }
  }

  # Optional: Allow global services (IAM, CloudFront, etc.) which don't have regions
  dynamic "statement" {
    for_each = var.allow_global_services ? [1] : []

    content {
      sid    = "AllowGlobalServices"
      effect = "Allow"

      actions = [
        "iam:*",
        "organizations:*",
        "route53:*",
        "cloudfront:*",
        "globalaccelerator:*",
        "importexport:*",
        "support:*",
        "trustedadvisor:*",
      ]

      resources = ["*"]
    }
  }
}

# Optional: Attach policy to organizational units or accounts
resource "aws_organizations_policy_attachment" "region_restriction" {
  for_each = toset(var.target_ids)

  policy_id = aws_organizations_policy.region_restriction.id
  target_id = each.value
}
