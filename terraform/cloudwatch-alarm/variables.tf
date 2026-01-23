# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "alarm_name" {
  description = "Name of the CloudWatch alarm. Used for identification and the Name tag."
  type        = string

  validation {
    condition     = length(var.alarm_name) >= 1 && length(var.alarm_name) <= 255
    error_message = "Alarm name must be between 1 and 255 characters long."
  }
}

variable "namespace" {
  description = <<-EOT
    The namespace for the metric associated with the alarm.
    Examples: AWS/EC2, AWS/RDS, AWS/Lambda, or custom namespaces.
  EOT
  type        = string
}

variable "metric_name" {
  description = <<-EOT
    The name of the metric to monitor.
    Examples: CPUUtilization, NetworkIn, DiskReadOps.
  EOT
  type        = string
}

variable "comparison_operator" {
  description = <<-EOT
    The arithmetic operation to use when comparing the specified statistic and threshold.
    Valid values: GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold.
  EOT
  type        = string

  validation {
    condition = contains(
      ["GreaterThanOrEqualToThreshold", "GreaterThanThreshold", "LessThanThreshold", "LessThanOrEqualToThreshold"],
      var.comparison_operator
    )
    error_message = "Comparison operator must be one of: GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold."
  }
}

variable "threshold" {
  description = "The value to compare the metric against."
  type        = number
}

variable "period" {
  description = <<-EOT
    The period in seconds over which the specified statistic is applied.
    Valid values are 10, 30, or any multiple of 60.
  EOT
  type        = number

  validation {
    condition     = var.period == 10 || var.period == 30 || (var.period >= 60 && var.period % 60 == 0)
    error_message = "Period must be 10, 30, or a multiple of 60 seconds."
  }
}

variable "evaluation_periods" {
  description = <<-EOT
    The number of periods over which data is compared to the specified threshold.
    Must be a positive integer.
  EOT
  type        = number

  validation {
    condition     = var.evaluation_periods > 0
    error_message = "Evaluation periods must be a positive integer."
  }
}

# -----------------------------------------------------------------------------
# Optional Variables
# -----------------------------------------------------------------------------

variable "dimensions" {
  description = <<-EOT
    The dimensions for the metric. Each metric has specific valid dimensions.
    Example: {InstanceId = "i-1234567890abcdef0"} for EC2 metrics.
  EOT
  type        = map(string)
  default     = {}
}

variable "statistic" {
  description = <<-EOT
    The statistic to apply to the metric.
    Valid values: Average, Sum, Minimum, Maximum, SampleCount.
  EOT
  type        = string
  default     = "Average"

  validation {
    condition     = contains(["Average", "Sum", "Minimum", "Maximum", "SampleCount"], var.statistic)
    error_message = "Statistic must be one of: Average, Sum, Minimum, Maximum, SampleCount."
  }
}

variable "treat_missing_data" {
  description = <<-EOT
    How to handle missing data points.
    Valid values:
    - notBreaching: Missing data is treated as good (within threshold)
    - breaching: Missing data is treated as bad (breaching threshold)
    - ignore: The alarm continues its current state
    - missing: The alarm does not consider missing data when evaluating
  EOT
  type        = string
  default     = "ignore"

  validation {
    condition     = contains(["notBreaching", "breaching", "ignore", "missing"], var.treat_missing_data)
    error_message = "Treat missing data must be one of: notBreaching, breaching, ignore, missing."
  }
}

variable "alarm_actions" {
  description = <<-EOT
    List of ARNs to execute when the alarm transitions to the ALARM state.
    Can include SNS topic ARNs, Auto Scaling policy ARNs, or Lambda function ARNs.
  EOT
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for arn in var.alarm_actions :
      can(regex("^arn:aws[a-z-]*:[a-z0-9-]+:[a-z0-9-]*:[0-9]{12}:.+", arn))
    ])
    error_message = "All alarm actions must be valid ARNs."
  }
}

variable "ok_actions" {
  description = <<-EOT
    List of ARNs to execute when the alarm transitions to the OK state.
    Can include SNS topic ARNs, Auto Scaling policy ARNs, or Lambda function ARNs.
  EOT
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for arn in var.ok_actions :
      can(regex("^arn:aws[a-z-]*:[a-z0-9-]+:[a-z0-9-]*:[0-9]{12}:.+", arn))
    ])
    error_message = "All OK actions must be valid ARNs."
  }
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to the CloudWatch alarm."
  type        = map(string)
  default     = {}
}
