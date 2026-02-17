output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.this.name
}

output "launch_template_id" {
  description = "Launch Template ID"
  value       = aws_launch_template.this.id
}

output "tt_cpu_policy_arn" {
  description = "Target tracking CPU policy ARN (if created)"
  value       = try(aws_autoscaling_policy.tt_cpu[0].arn, null)
}

output "tt_alb_policy_arn" {
  description = "Target tracking RPS (ALB request count) policy ARN (if created)"
  value       = try(aws_autoscaling_policy.tt_alb[0].arn, null)
}

output "memory_alarm_arn" {
  description = "Memory-based CloudWatch alarm ARN (if created)"
  value       = try(aws_cloudwatch_metric_alarm.memory[0].arn, null)
}

output "step_policy_arn" {
  description = "Step scaling policy ARN (if created)"
  value       = try(aws_autoscaling_policy.step[0].arn, null)
}

output "step_cpu_policy_arn" {
  description = "Step scaling CPU policy ARN (if created)"
  value       = try(aws_autoscaling_policy.step_cpu[0].arn, null)
}

output "step_rps_policy_arn" {
  description = "Step scaling RPS policy ARN (if created)"
  value       = try(aws_autoscaling_policy.step_rps[0].arn, null)
}

output "cpu_high_step_alarm_arn" {
  description = "CPU high step scaling alarm ARN (if created)"
  value       = try(aws_cloudwatch_metric_alarm.cpu_high_step[0].arn, null)
}

output "rps_high_step_alarm_arn" {
  description = "RPS high step scaling alarm ARN (if created)"
  value       = try(aws_cloudwatch_metric_alarm.rps_high_step[0].arn, null)
}
