# -----------------------------------------------------------------------------
# IAM Policy Module
# Creates a customer-managed IAM policy that can be attached to roles, users, or groups
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
# IAM Policy
# -----------------------------------------------------------------------------

resource "aws_iam_policy" "this" {
  name        = var.name
  description = var.description
  policy      = var.policy

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}
