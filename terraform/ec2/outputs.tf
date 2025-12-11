# -----------------------------------------------------------------------------
# EC2 Instance Outputs
# -----------------------------------------------------------------------------

output "instance_id" {
  description = "The ID of the EC2 instance (or spot instance ID if using spot)."
  value       = var.enable_spot_instance ? (length(aws_spot_instance_request.this) > 0 ? aws_spot_instance_request.this[0].spot_instance_id : null) : (length(aws_instance.this) > 0 ? aws_instance.this[0].id : null)
}

output "instance_arn" {
  description = "The ARN of the EC2 instance."
  value       = var.enable_spot_instance ? null : (length(aws_instance.this) > 0 ? aws_instance.this[0].arn : null)
}

output "instance_state" {
  description = "The state of the instance (running, stopped, etc.)."
  value       = var.enable_spot_instance ? (length(aws_spot_instance_request.this) > 0 ? aws_spot_instance_request.this[0].spot_instance_state : null) : (length(aws_instance.this) > 0 ? aws_instance.this[0].instance_state : null)
}

output "private_ip" {
  description = "The private IP address assigned to the instance."
  value       = var.enable_spot_instance ? (length(aws_spot_instance_request.this) > 0 ? aws_spot_instance_request.this[0].private_ip : null) : (length(aws_instance.this) > 0 ? aws_instance.this[0].private_ip : null)
}

output "public_ip" {
  description = "The public IP address assigned to the instance, if applicable."
  value       = var.enable_spot_instance ? (length(aws_spot_instance_request.this) > 0 ? aws_spot_instance_request.this[0].public_ip : null) : (length(aws_instance.this) > 0 ? aws_instance.this[0].public_ip : null)
}

output "public_dns" {
  description = "The public DNS name assigned to the instance."
  value       = var.enable_spot_instance ? (length(aws_spot_instance_request.this) > 0 ? aws_spot_instance_request.this[0].public_dns : null) : (length(aws_instance.this) > 0 ? aws_instance.this[0].public_dns : null)
}

output "private_dns" {
  description = "The private DNS name assigned to the instance."
  value       = var.enable_spot_instance ? (length(aws_spot_instance_request.this) > 0 ? aws_spot_instance_request.this[0].private_dns : null) : (length(aws_instance.this) > 0 ? aws_instance.this[0].private_dns : null)
}

output "primary_network_interface_id" {
  description = "The ID of the primary network interface."
  value       = var.enable_spot_instance ? (length(aws_spot_instance_request.this) > 0 ? aws_spot_instance_request.this[0].primary_network_interface_id : null) : (length(aws_instance.this) > 0 ? aws_instance.this[0].primary_network_interface_id : null)
}

output "availability_zone" {
  description = "The availability zone where the instance is running."
  value       = var.enable_spot_instance ? (length(aws_spot_instance_request.this) > 0 ? aws_spot_instance_request.this[0].availability_zone : null) : (length(aws_instance.this) > 0 ? aws_instance.this[0].availability_zone : null)
}

# -----------------------------------------------------------------------------
# Spot Instance Specific Outputs
# -----------------------------------------------------------------------------

output "spot_request_id" {
  description = "The ID of the spot instance request, if using spot instances."
  value       = var.enable_spot_instance ? (length(aws_spot_instance_request.this) > 0 ? aws_spot_instance_request.this[0].id : null) : null
}

output "spot_request_state" {
  description = "The state of the spot instance request (active, cancelled, etc.)."
  value       = var.enable_spot_instance ? (length(aws_spot_instance_request.this) > 0 ? aws_spot_instance_request.this[0].spot_request_state : null) : null
}

output "spot_bid_status" {
  description = "The bid status of the spot instance request."
  value       = var.enable_spot_instance ? (length(aws_spot_instance_request.this) > 0 ? aws_spot_instance_request.this[0].spot_bid_status : null) : null
}

# -----------------------------------------------------------------------------
# Security Group Outputs
# -----------------------------------------------------------------------------

output "security_group_id" {
  description = "The ID of the security group created by this module, if any."
  value       = var.create_security_group ? aws_security_group.this[0].id : null
}

output "security_group_arn" {
  description = "The ARN of the security group created by this module, if any."
  value       = var.create_security_group ? aws_security_group.this[0].arn : null
}

output "security_group_name" {
  description = "The name of the security group created by this module, if any."
  value       = var.create_security_group ? aws_security_group.this[0].name : null
}

# -----------------------------------------------------------------------------
# IAM Outputs
# -----------------------------------------------------------------------------

output "iam_role_arn" {
  description = "The ARN of the IAM role created by this module, if any."
  value       = var.create_iam_instance_profile ? aws_iam_role.this[0].arn : null
}

output "iam_role_name" {
  description = "The name of the IAM role created by this module, if any."
  value       = var.create_iam_instance_profile ? aws_iam_role.this[0].name : null
}

output "iam_instance_profile_arn" {
  description = "The ARN of the IAM instance profile created by this module, if any."
  value       = var.create_iam_instance_profile ? aws_iam_instance_profile.this[0].arn : null
}

output "iam_instance_profile_name" {
  description = "The name of the IAM instance profile created by this module, if any."
  value       = var.create_iam_instance_profile ? aws_iam_instance_profile.this[0].name : null
}

# -----------------------------------------------------------------------------
# Elastic IP Outputs
# -----------------------------------------------------------------------------

output "eip_id" {
  description = "The ID of the Elastic IP created by this module, if any."
  value       = var.create_eip ? aws_eip.this[0].id : null
}

output "eip_public_ip" {
  description = "The Elastic IP address."
  value       = var.create_eip ? aws_eip.this[0].public_ip : null
}

output "eip_allocation_id" {
  description = "The allocation ID of the Elastic IP."
  value       = var.create_eip ? aws_eip.this[0].allocation_id : null
}

output "eip_association_id" {
  description = "The ID of the EIP association."
  value       = var.create_eip ? (length(aws_eip_association.this) > 0 ? aws_eip_association.this[0].id : null) : null
}

# -----------------------------------------------------------------------------
# EBS Volume Outputs
# -----------------------------------------------------------------------------

output "ebs_volume_ids" {
  description = "Map of device names to EBS volume IDs for additional volumes."
  value = {
    for device_name, volume in aws_ebs_volume.this :
    device_name => volume.id
  }
}

output "ebs_volume_arns" {
  description = "Map of device names to EBS volume ARNs for additional volumes."
  value = {
    for device_name, volume in aws_ebs_volume.this :
    device_name => volume.arn
  }
}

output "root_block_device_volume_id" {
  description = "The volume ID of the root block device."
  value       = var.enable_spot_instance ? (length(aws_spot_instance_request.this) > 0 ? try(aws_spot_instance_request.this[0].root_block_device[0].volume_id, null) : null) : (length(aws_instance.this) > 0 ? try(aws_instance.this[0].root_block_device[0].volume_id, null) : null)
}

# -----------------------------------------------------------------------------
# Tags Outputs
# -----------------------------------------------------------------------------

output "tags_all" {
  description = "A map of all tags applied to the instance."
  value       = var.enable_spot_instance ? (length(aws_spot_instance_request.this) > 0 ? aws_spot_instance_request.this[0].tags_all : {}) : (length(aws_instance.this) > 0 ? aws_instance.this[0].tags_all : {})
}
