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

  lifecycle {
    precondition {
      condition     = var.max_entries >= length(var.entries)
      error_message = "max_entries must be greater than or equal to the number of provided entries."
    }

    precondition {
      condition = alltrue([
        for entry in var.entries : var.address_family == "IPv4"
        ? can(cidrnetmask(entry.cidr)) && !strcontains(entry.cidr, ":")
        : can(cidrnetmask(entry.cidr)) && strcontains(entry.cidr, ":")
      ])
      error_message = "Each entries[*].cidr value must be a valid CIDR that matches address_family."
    }
  }

  dynamic "entry" {
    for_each = var.entries
    content {
      cidr        = entry.value.cidr
      description = entry.value.description
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}
