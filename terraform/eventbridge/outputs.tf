# -----------------------------------------------------------------------------
# Event Bus Outputs
# -----------------------------------------------------------------------------

output "event_bus_arn" {
  description = "ARN of the EventBridge event bus. Use this to reference the event bus in other resources or for cross-account configuration."
  value       = var.create_event_bus ? aws_cloudwatch_event_bus.this[0].arn : "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:event-bus/default"
}

output "event_bus_name" {
  description = "Name of the EventBridge event bus. Use this to send events to the bus."
  value       = local.event_bus_name
}

# -----------------------------------------------------------------------------
# Event Rule Outputs
# -----------------------------------------------------------------------------

output "rule_arn" {
  description = "ARN of the EventBridge rule. Use this for IAM policies or monitoring."
  value       = aws_cloudwatch_event_rule.this.arn
}

output "rule_name" {
  description = "Name of the EventBridge rule."
  value       = aws_cloudwatch_event_rule.this.name
}

output "rule_id" {
  description = "ID of the EventBridge rule. Unique identifier for the rule."
  value       = aws_cloudwatch_event_rule.this.id
}

output "rule_description" {
  description = "Description of the EventBridge rule."
  value       = aws_cloudwatch_event_rule.this.description
}

output "rule_is_enabled" {
  description = "Whether the EventBridge rule is enabled."
  value       = aws_cloudwatch_event_rule.this.is_enabled
}

output "rule_schedule_expression" {
  description = "Schedule expression of the rule (if it's a scheduled rule)."
  value       = aws_cloudwatch_event_rule.this.schedule_expression
}

output "rule_event_pattern" {
  description = "Event pattern of the rule (if it's an event pattern rule)."
  value       = aws_cloudwatch_event_rule.this.event_pattern
}

# -----------------------------------------------------------------------------
# Event Target Outputs
# -----------------------------------------------------------------------------

output "target_arns" {
  description = "List of target ARNs configured for the EventBridge rule."
  value       = [for target in aws_cloudwatch_event_target.this : target.arn]
}

output "target_ids" {
  description = "List of target IDs configured for the EventBridge rule."
  value       = [for target in aws_cloudwatch_event_target.this : target.target_id]
}

# -----------------------------------------------------------------------------
# IAM Role Outputs
# -----------------------------------------------------------------------------

output "role_arn" {
  description = "ARN of the IAM role created for EventBridge to invoke targets. Returns null if create_role is false."
  value       = var.create_role ? aws_iam_role.eventbridge[0].arn : null
}

output "role_name" {
  description = "Name of the IAM role created for EventBridge. Returns null if create_role is false."
  value       = var.create_role ? aws_iam_role.eventbridge[0].name : null
}

output "role_id" {
  description = "ID of the IAM role created for EventBridge. Returns null if create_role is false."
  value       = var.create_role ? aws_iam_role.eventbridge[0].id : null
}

output "role_unique_id" {
  description = "Unique ID of the IAM role. Returns null if create_role is false."
  value       = var.create_role ? aws_iam_role.eventbridge[0].unique_id : null
}

# -----------------------------------------------------------------------------
# Event Bus Policy Outputs
# -----------------------------------------------------------------------------

output "event_bus_policy_id" {
  description = "ID of the event bus policy (for cross-account access). Returns null if no policy is created."
  value       = local.should_create_bus_policy ? aws_cloudwatch_event_bus_policy.this[0].id : null
}
