# -----------------------------------------------------------------------------
# IAM User Group Membership Module
# Manages IAM user memberships in one or more IAM groups.
#
# This module simplifies adding IAM users to groups by managing the
# aws_iam_user_group_membership resource, which ensures a user's group
# memberships are managed exclusively by Terraform.
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
# IAM User Group Membership
# -----------------------------------------------------------------------------

resource "aws_iam_user_group_membership" "this" {
  user = var.user_name

  groups = var.group_names
}
