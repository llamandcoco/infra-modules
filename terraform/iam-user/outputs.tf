output "user_name" {
  description = "IAM user name"
  value       = aws_iam_user.this.name
}

output "user_arn" {
  description = "IAM user ARN"
  value       = aws_iam_user.this.arn
}

output "user_unique_id" {
  description = "IAM user unique ID"
  value       = aws_iam_user.this.unique_id
}

output "access_key_id" {
  description = "Access key ID (if created)"
  value       = var.create_access_key ? aws_iam_access_key.this[0].id : null
}

output "access_key_secret" {
  description = "Access key secret (sensitive - store securely)"
  value       = var.create_access_key ? aws_iam_access_key.this[0].secret : null
  sensitive   = true
}

output "login_profile_created" {
  description = "Whether a login profile was created"
  value       = var.create_login_profile
}

output "login_profile_password" {
  description = "PGP-encrypted console password for login profile (sensitive). Requires pgp_key input."
  value       = var.create_login_profile ? aws_iam_user_login_profile.this[0].encrypted_password : null
  sensitive   = true
}

output "login_profile_key_fingerprint" {
  description = "PGP key fingerprint used for password encryption (if login profile is created)."
  value       = var.create_login_profile ? aws_iam_user_login_profile.this[0].key_fingerprint : null
}

output "attached_policy_arns" {
  description = "List of managed policy ARNs attached to the user"
  value       = var.policy_arns
}

output "inline_policy_names" {
  description = "List of inline policy names attached to the user"
  value = [
    for idx, statement in var.custom_policy_statements :
    statement.sid != null ? "${statement.sid}-${idx}" : "${var.name}-custom-${idx}"
  ]
}

output "group_memberships" {
  description = "List of IAM groups the user belongs to"
  value       = var.group_names
}
