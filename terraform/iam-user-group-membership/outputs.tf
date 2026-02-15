# -----------------------------------------------------------------------------
# IAM User Group Membership Outputs
# -----------------------------------------------------------------------------

output "user_name" {
  description = "Name of the IAM user"
  value       = aws_iam_user_group_membership.this.user
}

output "group_names" {
  description = "List of IAM group names the user is a member of"
  value       = aws_iam_user_group_membership.this.groups
}

output "membership_id" {
  description = "ID of the IAM user group membership resource"
  value       = aws_iam_user_group_membership.this.id
}
