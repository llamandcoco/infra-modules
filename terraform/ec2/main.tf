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
# Data Sources
# -----------------------------------------------------------------------------

# Get the availability zone of the subnet (optional for tests)
data "aws_subnet" "selected" {
  count = var.lookup_subnet_data ? 1 : 0
  id    = var.subnet_id
}

# Used to fetch instance state for spot requests after fulfillment
data "aws_instance" "spot" {
  count = var.enable_spot_instance ? 1 : 0

  instance_id = aws_spot_instance_request.this[0].spot_instance_id
}

locals {
  subnet_availability_zone = var.lookup_subnet_data ? data.aws_subnet.selected[0].availability_zone : var.fallback_availability_zone
}

# -----------------------------------------------------------------------------
# Security Group (Optional)
# -----------------------------------------------------------------------------

resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name        = var.security_group_name
  description = var.security_group_description
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = var.security_group_name
    }
  )
}

resource "aws_security_group_rule" "this" {
  for_each = var.create_security_group ? {
    for idx, rule in var.security_group_rules :
    "${rule.type}-${rule.protocol}-${rule.from_port}-${rule.to_port}-${idx}" => rule
  } : {}

  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  description       = each.value.description
  security_group_id = aws_security_group.this[0].id
}

# -----------------------------------------------------------------------------
# IAM Role and Instance Profile (Optional)
# -----------------------------------------------------------------------------

resource "aws_iam_role" "this" {
  count = var.create_iam_instance_profile ? 1 : 0

  name = var.iam_role_name != null ? var.iam_role_name : "${var.instance_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = var.iam_role_name != null ? var.iam_role_name : "${var.instance_name}-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.create_iam_instance_profile ? toset(var.iam_policy_arns) : []

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "inline" {
  for_each = var.create_iam_instance_profile ? {
    for idx, policy in var.iam_inline_policies :
    policy.name => policy
  } : {}

  name   = each.value.name
  role   = aws_iam_role.this[0].id
  policy = each.value.policy
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_iam_instance_profile ? 1 : 0

  name = "${var.instance_name}-profile"
  role = aws_iam_role.this[0].name

  tags = merge(
    var.tags,
    {
      Name = "${var.instance_name}-profile"
    }
  )
}

# -----------------------------------------------------------------------------
# EC2 Instance (On-Demand)
# -----------------------------------------------------------------------------

resource "aws_instance" "this" {
  count = var.enable_spot_instance ? 0 : 1

  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  # Security groups
  vpc_security_group_ids = var.create_security_group ? concat(
    var.vpc_security_group_ids,
    [aws_security_group.this[0].id]
  ) : var.vpc_security_group_ids

  # IAM
  iam_instance_profile = var.create_iam_instance_profile ? aws_iam_instance_profile.this[0].name : var.iam_instance_profile_name

  # Network
  associate_public_ip_address = var.associate_public_ip_address
  private_ip                  = var.private_ip
  source_dest_check           = var.source_dest_check

  # Key pair
  key_name = var.key_name

  # Monitoring
  monitoring = var.monitoring

  # User data
  user_data                   = var.user_data
  user_data_base64            = var.user_data_base64
  user_data_replace_on_change = var.user_data_replace_on_change

  # Lifecycle
  disable_api_termination              = var.disable_api_termination
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  # Tenancy
  tenancy = var.tenancy

  # Hibernation
  hibernation = var.hibernation

  # CPU credits (for T3 instances)
  credit_specification {
    cpu_credits = var.cpu_credits
  }

  # Metadata options (IMDSv2)
  metadata_options {
    http_endpoint               = var.metadata_options.http_endpoint
    http_tokens                 = var.metadata_options.http_tokens
    http_put_response_hop_limit = var.metadata_options.http_put_response_hop_limit
    instance_metadata_tags      = var.metadata_options.instance_metadata_tags
  }

  # Root block device
  root_block_device {
    volume_size           = var.root_block_device.volume_size
    volume_type           = var.root_block_device.volume_type
    iops                  = var.root_block_device.iops
    throughput            = var.root_block_device.throughput
    encrypted             = var.root_block_device.encrypted
    kms_key_id            = var.root_block_device.kms_key_id
    delete_on_termination = var.root_block_device.delete_on_termination
  }

  tags = merge(
    var.tags,
    {
      Name = var.instance_name
    }
  )

  volume_tags = merge(
    var.tags,
    var.volume_tags,
    {
      Name = "${var.instance_name}-volume"
    }
  )
}

# -----------------------------------------------------------------------------
# EC2 Spot Instance
# -----------------------------------------------------------------------------

resource "aws_spot_instance_request" "this" {
  count = var.enable_spot_instance ? 1 : 0

  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  # Spot configuration
  spot_price                     = var.spot_price
  wait_for_fulfillment           = true
  instance_interruption_behavior = var.spot_instance_interruption_behavior
  spot_type                      = var.spot_instance_type

  # Security groups
  vpc_security_group_ids = var.create_security_group ? concat(
    var.vpc_security_group_ids,
    [aws_security_group.this[0].id]
  ) : var.vpc_security_group_ids

  # IAM
  iam_instance_profile = var.create_iam_instance_profile ? aws_iam_instance_profile.this[0].name : var.iam_instance_profile_name

  # Network
  associate_public_ip_address = var.associate_public_ip_address
  private_ip                  = var.private_ip
  source_dest_check           = var.source_dest_check

  # Key pair
  key_name = var.key_name

  # Monitoring
  monitoring = var.monitoring

  # User data
  user_data                   = var.user_data
  user_data_base64            = var.user_data_base64
  user_data_replace_on_change = var.user_data_replace_on_change

  # Lifecycle
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  # Tenancy
  tenancy = var.tenancy

  # Hibernation
  hibernation = var.hibernation

  # CPU credits (for T3 instances)
  credit_specification {
    cpu_credits = var.cpu_credits
  }

  # Metadata options (IMDSv2)
  metadata_options {
    http_endpoint               = var.metadata_options.http_endpoint
    http_tokens                 = var.metadata_options.http_tokens
    http_put_response_hop_limit = var.metadata_options.http_put_response_hop_limit
    instance_metadata_tags      = var.metadata_options.instance_metadata_tags
  }

  # Root block device
  root_block_device {
    volume_size           = var.root_block_device.volume_size
    volume_type           = var.root_block_device.volume_type
    iops                  = var.root_block_device.iops
    throughput            = var.root_block_device.throughput
    encrypted             = var.root_block_device.encrypted
    kms_key_id            = var.root_block_device.kms_key_id
    delete_on_termination = var.root_block_device.delete_on_termination
  }

  tags = merge(
    var.tags,
    {
      Name = var.instance_name
    }
  )

  volume_tags = merge(
    var.tags,
    var.volume_tags,
    {
      Name = "${var.instance_name}-volume"
    }
  )
}

# -----------------------------------------------------------------------------
# Additional EBS Volumes (Optional)
# -----------------------------------------------------------------------------

resource "aws_ebs_volume" "this" {
  for_each = {
    for idx, vol in var.ebs_volumes :
    vol.device_name => vol
  }

  availability_zone = each.value.availability_zone != null ? each.value.availability_zone : local.subnet_availability_zone
  size              = each.value.volume_size
  type              = each.value.volume_type
  iops              = each.value.iops
  throughput        = each.value.throughput
  encrypted         = each.value.encrypted
  kms_key_id        = each.value.kms_key_id

  tags = merge(
    var.tags,
    var.volume_tags,
    {
      Name = "${var.instance_name}-${each.key}"
    }
  )
}

resource "aws_volume_attachment" "this" {
  for_each = {
    for idx, vol in var.ebs_volumes :
    vol.device_name => vol
  }

  device_name = each.key
  volume_id   = aws_ebs_volume.this[each.key].id
  instance_id = var.enable_spot_instance ? aws_spot_instance_request.this[0].spot_instance_id : aws_instance.this[0].id

  force_detach = each.value.delete_on_termination
}

# -----------------------------------------------------------------------------
# Elastic IP (Optional)
# -----------------------------------------------------------------------------

resource "aws_eip" "this" {
  count = var.create_eip ? 1 : 0

  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.instance_name}-eip"
    }
  )
}

resource "aws_eip_association" "this" {
  count = var.create_eip ? 1 : 0

  instance_id   = var.enable_spot_instance ? aws_spot_instance_request.this[0].spot_instance_id : aws_instance.this[0].id
  allocation_id = aws_eip.this[0].id
}
