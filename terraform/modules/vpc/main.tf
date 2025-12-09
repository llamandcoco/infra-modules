terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_vpc" "this" {
  cidr_block                           = var.cidr_block
  enable_dns_support                   = var.enable_dns_support
  enable_dns_hostnames                 = var.enable_dns_hostnames
  assign_generated_ipv6_cidr_block     = var.enable_ipv6
  instance_tenancy                     = var.instance_tenancy
  enable_network_address_usage_metrics = var.enable_network_address_usage_metrics

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}
