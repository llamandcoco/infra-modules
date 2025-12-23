# -----------------------------------------------------------------------------
# Event Bus Outputs
# -----------------------------------------------------------------------------

output "event_bus_arn" {
  description = "ARN of the EventBridge event bus. Use this to reference the event bus in other resources or for cross-account configuration."
  value       = var.create_event_bus ? aws_cloudwatch_event_bus.this[0].arn : "arn:aws:events:${data.aws_region.current.id}:${local.caller_identity.account_id}:event-bus/${var.event_bus_name}"
}

output "event_bus_name" {
  description = "Name of the EventBridge event bus. Use this to send events to the bus."
  value       = local.event_bus_name
}

# -----------------------------------------------------------------------------
# Event Rule Outputs (Multiple Rules Support)
# -----------------------------------------------------------------------------

output "rules" {
  description = "Map of all EventBridge rules created, keyed by rule name."
  value = {
    for name, rule in aws_cloudwatch_event_rule.this : name => {
      arn                 = rule.arn
      name                = rule.name
      id                  = rule.id
      description         = rule.description
      is_enabled          = rule.state == "ENABLED"
      schedule_expression = rule.schedule_expression
      event_pattern       = rule.event_pattern
    }
  }
}

output "rule_arns" {
  description = "Map of rule names to ARNs."
  value       = { for name, rule in aws_cloudwatch_event_rule.this : name => rule.arn }
}

output "rule_names" {
  description = "List of all rule names."
  value       = [for name, rule in aws_cloudwatch_event_rule.this : rule.name]
}

# Backwards compatibility outputs (single rule mode)
output "rule_arn" {
  description = "ARN of the first EventBridge rule (for backwards compatibility with single rule mode)."
  value       = length(aws_cloudwatch_event_rule.this) > 0 ? values(aws_cloudwatch_event_rule.this)[0].arn : null
}

output "rule_name" {
  description = "Name of the first EventBridge rule (for backwards compatibility with single rule mode)."
  value       = length(aws_cloudwatch_event_rule.this) > 0 ? values(aws_cloudwatch_event_rule.this)[0].name : null
}

output "rule_id" {
  description = "ID of the first EventBridge rule (for backwards compatibility with single rule mode)."
  value       = length(aws_cloudwatch_event_rule.this) > 0 ? values(aws_cloudwatch_event_rule.this)[0].id : null
}

# -----------------------------------------------------------------------------
# Event Target Outputs
# -----------------------------------------------------------------------------

output "targets" {
  description = "Map of all targets created, keyed by target key (rule_name-target_id)."
  value = {
    for key, target in aws_cloudwatch_event_target.this : key => {
      rule_name = target.rule
      target_id = target.target_id
      arn       = target.arn
      role_arn  = target.role_arn
    }
  }
}

output "target_arns" {
  description = "List of all target ARNs configured across all rules."
  value       = [for target in aws_cloudwatch_event_target.this : target.arn]
}

output "target_ids" {
  description = "List of all target IDs configured across all rules."
  value       = [for target in aws_cloudwatch_event_target.this : target.target_id]
}

# -----------------------------------------------------------------------------
# IAM Role Outputs
# -----------------------------------------------------------------------------

output "role_arn" {
  description = "ARN of the IAM role created for EventBridge to invoke targets. Returns null if create_role is false."
  value       = var.create_role && length(local.all_rules) > 0 ? aws_iam_role.eventbridge[0].arn : null
}

output "role_name" {
  description = "Name of the IAM role created for EventBridge. Returns null if create_role is false."
  value       = var.create_role && length(local.all_rules) > 0 ? aws_iam_role.eventbridge[0].name : null
}

output "role_id" {
  description = "ID of the IAM role created for EventBridge. Returns null if create_role is false."
  value       = var.create_role && length(local.all_rules) > 0 ? aws_iam_role.eventbridge[0].id : null
}

output "role_unique_id" {
  description = "Unique ID of the IAM role. Returns null if create_role is false."
  value       = var.create_role && length(local.all_rules) > 0 ? aws_iam_role.eventbridge[0].unique_id : null
}

# -----------------------------------------------------------------------------
# Event Bus Policy Outputs
# -----------------------------------------------------------------------------

output "event_bus_policy_id" {
  description = "ID of the event bus policy (for cross-account access). Returns null if no policy is created."
  value       = local.should_create_bus_policy ? aws_cloudwatch_event_bus_policy.this[0].id : null
}

# -----------------------------------------------------------------------------
# Archive Outputs
# -----------------------------------------------------------------------------

output "archive_arn" {
  description = "ARN of the EventBridge archive. Returns null if archive is not configured."
  value       = var.archive_config != null ? aws_cloudwatch_event_archive.this[0].arn : null
}

output "archive_name" {
  description = "Name of the EventBridge archive. Returns null if archive is not configured."
  value       = var.archive_config != null ? aws_cloudwatch_event_archive.this[0].name : null
}
