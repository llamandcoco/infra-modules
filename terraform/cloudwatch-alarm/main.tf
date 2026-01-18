terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name          = var.alarm_name
  namespace           = var.namespace
  metric_name         = var.metric_name
  comparison_operator = var.comparison_operator
  threshold           = var.threshold
  period              = var.period
  evaluation_periods  = var.evaluation_periods
  statistic           = var.statistic
  treat_missing_data  = var.treat_missing_data

  dimensions = var.dimensions

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions

  tags = var.tags
}
