terraform {
  required_version = ">= 1.3.0"
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

module "alarm" {
  source = "../../"

  alarm_name          = "example-cpu-high"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 70
  period              = 60
  evaluation_periods  = 2
  statistic           = "Average"
  dimensions          = { AutoScalingGroupName = "example-asg" }
}

output "alarm_arn" {
  value = module.alarm.alarm_arn
}
