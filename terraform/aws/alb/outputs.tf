# -----------------------------------------------------------------------------
# ALB Identification Outputs
# -----------------------------------------------------------------------------

output "alb_id" {
  description = "The ID of the ALB. Use this for resource references and integrations."
  value       = aws_lb.this.id
}

output "alb_arn" {
  description = "The ARN of the ALB. Use this for IAM policies, CloudWatch alarms, and cross-account access."
  value       = aws_lb.this.arn
}

output "alb_arn_suffix" {
  description = "The ARN suffix for use with CloudWatch metrics. Format: app/alb-name/1234567890abcdef"
  value       = aws_lb.this.arn_suffix
}

output "alb_dns_name" {
  description = "The DNS name of the ALB. Use this to access the load balancer or create DNS records."
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "The canonical hosted zone ID of the ALB. Use this for creating Route53 alias records."
  value       = aws_lb.this.zone_id
}

# -----------------------------------------------------------------------------
# Security Group Outputs
# -----------------------------------------------------------------------------

output "security_group_id" {
  description = "The ID of the security group created for the ALB. Null if create_security_group is false."
  value       = var.create_security_group ? aws_security_group.this[0].id : null
}

# -----------------------------------------------------------------------------
# Target Group Outputs
# -----------------------------------------------------------------------------

output "target_group_arns" {
  description = "Map of target group names to their ARNs. Use these for registering targets or creating listener rules."
  value = {
    for name, tg in aws_lb_target_group.this : name => tg.arn
  }
}

output "target_group_arn_suffixes" {
  description = "Map of target group names to their ARN suffixes. Use these for CloudWatch metrics and monitoring."
  value = {
    for name, tg in aws_lb_target_group.this : name => tg.arn_suffix
  }
}

output "target_group_ids" {
  description = "Map of target group names to their IDs. Use these for resource references."
  value = {
    for name, tg in aws_lb_target_group.this : name => tg.id
  }
}

output "target_group_names" {
  description = "Map of target group keys to their names. Lists all target groups created."
  value = {
    for name, tg in aws_lb_target_group.this : name => tg.name
  }
}

# -----------------------------------------------------------------------------
# Listener Outputs
# -----------------------------------------------------------------------------

output "listener_arns" {
  description = "Map of listener ports to their ARNs. Use these for creating listener rules or certificates."
  value = {
    for port, listener in aws_lb_listener.this : port => listener.arn
  }
}

output "listener_ids" {
  description = "Map of listener ports to their IDs. Use these for resource references."
  value = {
    for port, listener in aws_lb_listener.this : port => listener.id
  }
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener (port 80), if it exists. Null otherwise."
  value       = contains([for l in var.listeners : l.port], 80) ? aws_lb_listener.this[80].arn : null
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener (port 443), if it exists. Null otherwise."
  value       = contains([for l in var.listeners : l.port], 443) ? aws_lb_listener.this[443].arn : null
}

# -----------------------------------------------------------------------------
# Listener Rule Outputs
# -----------------------------------------------------------------------------

output "listener_rule_arns" {
  description = "Map of listener rule keys to their ARNs. Use these for monitoring or modifications."
  value = {
    for key, rule in aws_lb_listener_rule.this : key => rule.arn
  }
}

output "listener_rule_ids" {
  description = "Map of listener rule keys to their IDs. Use these for resource references."
  value = {
    for key, rule in aws_lb_listener_rule.this : key => rule.id
  }
}

# -----------------------------------------------------------------------------
# Configuration Outputs
# -----------------------------------------------------------------------------

output "alb_name" {
  description = "The name of the ALB."
  value       = aws_lb.this.name
}

output "alb_type" {
  description = "The type of load balancer. Always 'application' for this module."
  value       = aws_lb.this.load_balancer_type
}

output "internal" {
  description = "Whether the ALB is internal (true) or internet-facing (false)."
  value       = aws_lb.this.internal
}

output "vpc_id" {
  description = "The VPC ID where the ALB and target groups are created."
  value       = var.vpc_id
}

output "subnets" {
  description = "The list of subnet IDs attached to the ALB."
  value       = aws_lb.this.subnets
}

output "ip_address_type" {
  description = "The IP address type of the ALB (ipv4, dualstack, or dualstack-without-public-ipv4)."
  value       = aws_lb.this.ip_address_type
}

output "enable_deletion_protection" {
  description = "Whether deletion protection is enabled for the ALB."
  value       = aws_lb.this.enable_deletion_protection
}

output "enable_http2" {
  description = "Whether HTTP/2 is enabled for the ALB."
  value       = aws_lb.this.enable_http2
}

output "idle_timeout" {
  description = "The idle timeout value in seconds for the ALB."
  value       = aws_lb.this.idle_timeout
}

# -----------------------------------------------------------------------------
# Tags Output
# -----------------------------------------------------------------------------

output "tags" {
  description = "All tags applied to the ALB, including defaults and custom tags."
  value       = aws_lb.this.tags_all
}
