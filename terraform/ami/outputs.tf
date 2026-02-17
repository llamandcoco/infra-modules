# -----------------------------------------------------------------------------
# AMI Identification Outputs
# -----------------------------------------------------------------------------

output "ami_id" {
  description = "The AMI ID. Uses ami_id directly when provided, otherwise the lookup result."
  value       = var.ami_id != null ? var.ami_id : data.aws_ami.this[0].id
}

output "ami_arn" {
  description = "The ARN of the selected AMI. Null when ami_id is provided directly."
  value       = var.ami_id != null ? null : data.aws_ami.this[0].arn
}

output "ami_name" {
  description = "The name of the selected AMI. Null when ami_id is provided directly."
  value       = var.ami_id != null ? null : data.aws_ami.this[0].name
}

# -----------------------------------------------------------------------------
# AMI Details Outputs
# -----------------------------------------------------------------------------

output "ami_description" {
  description = "The description of the selected AMI. Null when ami_id is provided directly."
  value       = var.ami_id != null ? null : data.aws_ami.this[0].description
}

output "ami_architecture" {
  description = "The architecture of the AMI (e.g., x86_64, arm64)."
  value       = var.ami_id != null ? null : data.aws_ami.this[0].architecture
}

output "ami_image_location" {
  description = "The image location of the selected AMI. Null when ami_id is provided directly."
  value       = var.ami_id != null ? null : data.aws_ami.this[0].image_location
}

output "ami_owner_id" {
  description = "The AWS account ID of the selected AMI owner. Null when ami_id is provided directly."
  value       = var.ami_id != null ? null : data.aws_ami.this[0].owner_id
}

output "ami_platform" {
  description = "The platform of the AMI (e.g., windows)."
  value       = var.ami_id != null ? null : data.aws_ami.this[0].platform
}

output "ami_root_device_type" {
  description = "The root device type of the selected AMI. Null when ami_id is provided directly."
  value       = var.ami_id != null ? null : data.aws_ami.this[0].root_device_type
}

output "ami_virtualization_type" {
  description = "The virtualization type of the selected AMI. Null when ami_id is provided directly."
  value       = var.ami_id != null ? null : data.aws_ami.this[0].virtualization_type
}

# -----------------------------------------------------------------------------
# AMI Block Devices Outputs
# -----------------------------------------------------------------------------

output "ami_root_device_name" {
  description = "The root device name of the selected AMI. Null when ami_id is provided directly."
  value       = var.ami_id != null ? null : data.aws_ami.this[0].root_device_name
}

output "ami_root_snapshot_id" {
  description = "The root snapshot ID of the selected AMI. Null when ami_id is provided directly."
  value       = var.ami_id != null ? null : data.aws_ami.this[0].root_snapshot_id
}
