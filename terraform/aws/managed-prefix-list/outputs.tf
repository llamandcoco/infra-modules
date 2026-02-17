output "prefix_list_id" {
  description = "ID of the managed prefix list."
  value       = length(aws_ec2_managed_prefix_list.this) > 0 ? aws_ec2_managed_prefix_list.this[0].id : null
}

output "prefix_list_arn" {
  description = "ARN of the managed prefix list."
  value       = length(aws_ec2_managed_prefix_list.this) > 0 ? aws_ec2_managed_prefix_list.this[0].arn : null
}

output "prefix_list_version" {
  description = "Version of the managed prefix list."
  value       = length(aws_ec2_managed_prefix_list.this) > 0 ? aws_ec2_managed_prefix_list.this[0].version : null
}

output "prefix_list_owner_id" {
  description = "Owner ID of the managed prefix list."
  value       = length(aws_ec2_managed_prefix_list.this) > 0 ? aws_ec2_managed_prefix_list.this[0].owner_id : null
}

output "prefix_list_tags" {
  description = "Tags applied to the managed prefix list."
  value       = length(aws_ec2_managed_prefix_list.this) > 0 ? aws_ec2_managed_prefix_list.this[0].tags_all : {}
}
