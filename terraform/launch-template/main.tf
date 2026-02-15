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
# Image Selection
# -----------------------------------------------------------------------------
# CI-safe conditional SSM lookup for AL2023 AMI
data "aws_ssm_parameter" "al2023" {
  count = var.image_id == null && var.use_ssm_ami_lookup ? 1 : 0
  name  = var.ami_ssm_parameter_name
}

# -----------------------------------------------------------------------------
# Derived Locals
# -----------------------------------------------------------------------------
locals {
  image_id = var.image_id != null ? var.image_id : (
    var.use_ssm_ami_lookup && length(data.aws_ssm_parameter.al2023) > 0 ? data.aws_ssm_parameter.al2023[0].value : null
  )
}

# -----------------------------------------------------------------------------
# Launch Template
# -----------------------------------------------------------------------------
resource "aws_launch_template" "this" {
  name        = var.name
  description = var.description

  image_id      = local.image_id
  instance_type = var.instance_type
  key_name      = var.key_name

  # IAM Instance Profile
  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile_name != null ? [1] : []
    content {
      name = var.iam_instance_profile_name
    }
  }

  # Security Groups
  vpc_security_group_ids = var.vpc_security_group_ids

  # User Data
  user_data = var.user_data_base64 != null ? var.user_data_base64 : (
    var.user_data != null ? base64encode(var.user_data) : null
  )

  # Metadata Options (IMDSv2)
  metadata_options {
    http_endpoint               = var.metadata_options.http_endpoint
    http_tokens                 = var.metadata_options.http_tokens
    http_put_response_hop_limit = var.metadata_options.http_put_response_hop_limit
    instance_metadata_tags      = var.metadata_options.instance_metadata_tags
  }

  # Monitoring
  monitoring {
    enabled = var.enable_monitoring
  }

  # Network Interfaces
  dynamic "network_interfaces" {
    for_each = length(var.network_interfaces) > 0 ? var.network_interfaces : []
    content {
      associate_public_ip_address = network_interfaces.value.associate_public_ip_address
      delete_on_termination       = network_interfaces.value.delete_on_termination
      device_index                = network_interfaces.value.device_index
      security_groups             = network_interfaces.value.security_groups
      subnet_id                   = network_interfaces.value.subnet_id
    }
  }

  # Block Device Mappings
  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name  = block_device_mappings.value.device_name
      no_device    = block_device_mappings.value.no_device
      virtual_name = block_device_mappings.value.virtual_name

      dynamic "ebs" {
        for_each = block_device_mappings.value.ebs != null ? [block_device_mappings.value.ebs] : []
        content {
          delete_on_termination = ebs.value.delete_on_termination
          encrypted             = ebs.value.encrypted
          iops                  = ebs.value.iops
          kms_key_id            = ebs.value.kms_key_id
          snapshot_id           = ebs.value.snapshot_id
          throughput            = ebs.value.throughput
          volume_size           = ebs.value.volume_size
          volume_type           = ebs.value.volume_type
        }
      }
    }
  }

  # Credit Specification (for T3 instances)
  dynamic "credit_specification" {
    for_each = var.cpu_credits != null ? [1] : []
    content {
      cpu_credits = var.cpu_credits
    }
  }

  # Placement
  dynamic "placement" {
    for_each = var.placement != null ? [var.placement] : []
    content {
      availability_zone = placement.value.availability_zone
      group_name        = placement.value.group_name
      tenancy           = placement.value.tenancy
    }
  }

  # Tag Specifications
  dynamic "tag_specifications" {
    for_each = var.tag_specifications
    content {
      resource_type = tag_specifications.value.resource_type
      tags          = tag_specifications.value.tags
    }
  }

  # Disable API Termination
  disable_api_termination = var.disable_api_termination

  # EBS Optimized
  ebs_optimized = var.ebs_optimized

  # Instance Market Options (for Spot)
  dynamic "instance_market_options" {
    for_each = var.instance_market_options != null ? [var.instance_market_options] : []
    content {
      market_type = instance_market_options.value.market_type

      dynamic "spot_options" {
        for_each = instance_market_options.value.spot_options != null ? [instance_market_options.value.spot_options] : []
        content {
          block_duration_minutes         = spot_options.value.block_duration_minutes
          instance_interruption_behavior = spot_options.value.instance_interruption_behavior
          max_price                      = spot_options.value.max_price
          spot_instance_type             = spot_options.value.spot_instance_type
          valid_until                    = spot_options.value.valid_until
        }
      }
    }
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}
