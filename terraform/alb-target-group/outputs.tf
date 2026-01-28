# -----------------------------------------------------------------------------
# Target Group Outputs
# -----------------------------------------------------------------------------

output "target_group_arn" {
  description = "ARN of the target group."
  value       = aws_lb_target_group.this.arn
}

output "target_group_arn_suffix" {
  description = "ARN suffix of the target group."
  value       = aws_lb_target_group.this.arn_suffix
}

output "target_group_id" {
  description = "ID of the target group."
  value       = aws_lb_target_group.this.id
}

output "target_group_name" {
  description = "Name of the target group."
  value       = aws_lb_target_group.this.name
}

# -----------------------------------------------------------------------------
# Listener Rule Outputs
# -----------------------------------------------------------------------------

output "listener_rule_arn" {
  description = "ARN of the listener rule (if created)."
  value       = var.listener_arn != null ? aws_lb_listener_rule.this[0].arn : null
}

output "listener_rule_id" {
  description = "ID of the listener rule (if created)."
  value       = var.listener_arn != null ? aws_lb_listener_rule.this[0].id : null
}
