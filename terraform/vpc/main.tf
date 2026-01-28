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
      Name = "${var.name}-vpc"
    }
  )
}

# VPC Flow Logs for network monitoring and security
resource "aws_flow_log" "this" {
  count = var.enable_flow_logs ? 1 : 0

  vpc_id          = aws_vpc.this.id
  traffic_type    = var.flow_logs_traffic_type
  iam_role_arn    = var.flow_logs_iam_role_arn
  log_destination = var.flow_logs_destination_arn

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-flow-logs"
    }
  )
}

# Manage default security group to restrict access
resource "aws_default_security_group" "this" {
  count = var.manage_default_security_group ? 1 : 0

  vpc_id = aws_vpc.this.id

  # No ingress or egress rules - deny all by default
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-default-sg-locked"
    }
  )
}

# Manage default network ACL
resource "aws_default_network_acl" "this" {
  count = var.manage_default_nacl && !var.ignore_default_nacl_subnet_ids ? 1 : 0

  default_network_acl_id = aws_vpc.this.default_network_acl_id

  # Allow all traffic by default (common practice)
  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-default-nacl"
    }
  )
}

resource "aws_default_network_acl" "this_ignore" {
  count = var.manage_default_nacl && var.ignore_default_nacl_subnet_ids ? 1 : 0

  default_network_acl_id = aws_vpc.this.default_network_acl_id

  # Allow all traffic by default (common practice)
  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-default-nacl"
    }
  )

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}
