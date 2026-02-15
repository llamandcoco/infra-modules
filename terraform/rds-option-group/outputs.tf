# -----------------------------------------------------------------------------
# Option Group Outputs
# -----------------------------------------------------------------------------

output "id" {
  description = "ID of the option group. Use this to reference the option group in RDS instance or cluster configurations."
  value       = aws_db_option_group.this.id
}

output "arn" {
  description = "ARN of the option group. Use for IAM policies, cross-account access, and resource tagging."
  value       = aws_db_option_group.this.arn
}

output "name" {
  description = "Name of the option group."
  value       = aws_db_option_group.this.name
}

output "engine_name" {
  description = "Database engine name for this option group."
  value       = aws_db_option_group.this.engine_name
}

output "major_engine_version" {
  description = "Major engine version for this option group."
  value       = aws_db_option_group.this.major_engine_version
}

# -----------------------------------------------------------------------------
# Full Option Group Details
# -----------------------------------------------------------------------------

output "option_group" {
  description = "Complete option group details including all configured options and settings."
  value = {
    id                   = aws_db_option_group.this.id
    arn                  = aws_db_option_group.this.arn
    name                 = aws_db_option_group.this.name
    description          = aws_db_option_group.this.option_group_description
    engine_name          = aws_db_option_group.this.engine_name
    major_engine_version = aws_db_option_group.this.major_engine_version
    options              = aws_db_option_group.this.option
    tags                 = aws_db_option_group.this.tags_all
  }
}
