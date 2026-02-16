terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Data source to find an existing AMI
# Retrieves AMI metadata based on filters like name, owner, architecture, etc.
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
}

# Optional: Copy AMI to another region
# Creates a copy of an AMI in the current region from a source region
resource "aws_ami_copy" "this" {
  count = var.copy_ami_config != null ? 1 : 0

  name              = var.copy_ami_config.name
  description       = var.copy_ami_config.description
  source_ami_id     = var.copy_ami_config.source_ami_id
  source_ami_region = var.copy_ami_config.source_ami_region
  encrypted         = var.copy_ami_config.encrypted
  kms_key_id        = var.copy_ami_config.kms_key_id

  tags = merge(
    var.tags,
    {
      Name = var.copy_ami_config.name
    }
  )
}
