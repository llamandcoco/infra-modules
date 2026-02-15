terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_ec2_managed_prefix_list" "this" {
  count = var.create ? 1 : 0

  name           = var.name
  address_family = var.address_family
  max_entries    = var.max_entries

  dynamic "entry" {
    for_each = var.entries
    content {
      cidr        = entry.value.cidr
      description = lookup(entry.value, "description", null)
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}
