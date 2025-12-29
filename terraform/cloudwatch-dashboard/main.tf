# -----------------------------------------------------------------------------
# CloudWatch Dashboard Module
# -----------------------------------------------------------------------------
# Creates a CloudWatch Dashboard for monitoring AWS resources
#
# Features:
# - Flexible widget configuration
# - Support for metric, log, and alarm widgets
# - Automatic dashboard naming
# - Tags support
# -----------------------------------------------------------------------------

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
# CloudWatch Dashboard
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = var.dashboard_name

  dashboard_body = jsonencode({
    widgets = var.widgets
  })
}
