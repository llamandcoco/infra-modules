output "role_name" {
  description = "IAM role name"
  value       = aws_iam_role.this.name
}

output "instance_profile_name" {
  description = "Instance profile name"
  value       = aws_iam_instance_profile.this.name
}
