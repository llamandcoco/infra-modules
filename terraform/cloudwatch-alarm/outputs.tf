# -----------------------------------------------------------------------------
# CloudWatch Alarm Outputs
# -----------------------------------------------------------------------------

output "alarm_arn" {
  description = "The ARN of the CloudWatch metric alarm."
  value       = aws_cloudwatch_metric_alarm.this.arn
}

output "alarm_name" {
  description = "The name of the CloudWatch metric alarm."
  value       = aws_cloudwatch_metric_alarm.this.alarm_name
}

output "alarm_id" {
  description = "The ID of the CloudWatch metric alarm."
  value       = aws_cloudwatch_metric_alarm.this.id
}
