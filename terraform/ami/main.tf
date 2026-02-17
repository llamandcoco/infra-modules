terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AMI lookup data source.
data "aws_ami" "this" {
  count = var.ami_id == null ? 1 : 0

  most_recent = var.most_recent
  owners      = var.owners

  dynamic "filter" {
    for_each = var.filters
    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }

  tags = var.filter_tags

  lifecycle {
    precondition {
      condition     = length(var.owners) > 0
      error_message = "owners must not be empty when ami_id is not provided."
    }
  }
}
