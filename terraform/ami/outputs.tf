# -----------------------------------------------------------------------------
# AMI Identification Outputs
# -----------------------------------------------------------------------------

output "ami_id" {
  description = "The ID of the AMI. Either from the data source lookup or the copied AMI."
  value       = var.copy_ami_config != null ? aws_ami_copy.this[0].id : (var.ami_id != null ? var.ami_id : data.aws_ami.this[0].id)
}

output "ami_arn" {
  description = "The ARN of the AMI. Use this for IAM policies and cross-account access."
  value       = var.copy_ami_config != null ? aws_ami_copy.this[0].arn : (var.ami_id != null ? null : data.aws_ami.this[0].arn)
}

output "ami_name" {
  description = "The name of the AMI."
  value       = var.copy_ami_config != null ? aws_ami_copy.this[0].name : (var.ami_id != null ? null : data.aws_ami.this[0].name)
}

# -----------------------------------------------------------------------------
# AMI Details Outputs
# -----------------------------------------------------------------------------

output "ami_description" {
  description = "The description of the AMI."
  value       = var.copy_ami_config != null ? aws_ami_copy.this[0].description : (var.ami_id != null ? null : data.aws_ami.this[0].description)
}

output "ami_architecture" {
  description = "The architecture of the AMI (e.g., x86_64, arm64)."
  value       = var.copy_ami_config != null ? aws_ami_copy.this[0].architecture : (var.ami_id != null ? null : data.aws_ami.this[0].architecture)
}

output "ami_image_location" {
  description = "The location of the AMI. Only available for AMI lookup, not for copied AMIs."
  value       = var.ami_id != null ? null : (var.copy_ami_config != null ? null : data.aws_ami.this[0].image_location)
}

output "ami_owner_id" {
  description = "The AWS account ID of the AMI owner. Only available for AMI lookup, not for copied AMIs."
  value       = var.ami_id != null ? null : (var.copy_ami_config != null ? null : data.aws_ami.this[0].owner_id)
}

output "ami_platform" {
  description = "The platform of the AMI (e.g., windows)."
  value       = var.copy_ami_config != null ? null : (var.ami_id != null ? null : data.aws_ami.this[0].platform)
}

output "ami_root_device_type" {
  description = "The root device type of the AMI (e.g., ebs, instance-store). Only available for AMI lookup, not for copied AMIs."
  value       = var.ami_id != null ? null : (var.copy_ami_config != null ? null : data.aws_ami.this[0].root_device_type)
}

output "ami_virtualization_type" {
  description = "The virtualization type of the AMI (e.g., hvm, paravirtual). Only available for AMI lookup, not for copied AMIs."
  value       = var.ami_id != null ? null : (var.copy_ami_config != null ? null : data.aws_ami.this[0].virtualization_type)
}

# -----------------------------------------------------------------------------
# AMI Block Devices Outputs
# -----------------------------------------------------------------------------

output "ami_root_device_name" {
  description = "The device name of the root device."
  value       = var.copy_ami_config != null ? aws_ami_copy.this[0].root_device_name : (var.ami_id != null ? null : data.aws_ami.this[0].root_device_name)
}

output "ami_root_snapshot_id" {
  description = "The snapshot ID of the root device."
  value       = var.copy_ami_config != null ? aws_ami_copy.this[0].root_snapshot_id : (var.ami_id != null ? null : data.aws_ami.this[0].root_snapshot_id)
}

# -----------------------------------------------------------------------------
# Source Information (for copied AMIs)
# -----------------------------------------------------------------------------

output "source_ami_id" {
  description = "The source AMI ID when using AMI copy. Null if not copying."
  value       = var.copy_ami_config != null ? var.copy_ami_config.source_ami_id : null
}

output "source_ami_region" {
  description = "The source AMI region when using AMI copy. Null if not copying."
  value       = var.copy_ami_config != null ? var.copy_ami_config.source_ami_region : null
}
