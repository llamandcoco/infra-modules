variable "alarm_name" {
  description = "Alarm name"
  type        = string
}

variable "namespace" {
  description = "Metric namespace"
  type        = string
}

variable "metric_name" {
  description = "Metric name"
  type        = string
}

variable "dimensions" {
  description = "Metric dimensions"
  type        = map(string)
  default     = {}
}

variable "comparison_operator" {
  description = "Comparison operator (e.g., GreaterThanThreshold)"
  type        = string
}

variable "threshold" {
  description = "Alarm threshold"
  type        = number
}

variable "period" {
  description = "Metric period in seconds"
  type        = number
}

variable "evaluation_periods" {
  description = "Number of periods to evaluate"
  type        = number
}

variable "statistic" {
  description = "Statistic (Average|Sum|Minimum|Maximum|SampleCount)"
  type        = string
  default     = "Average"
}

variable "treat_missing_data" {
  description = "Treat missing data (notBreaching|breaching|ignore|missing)"
  type        = string
  default     = "ignore"
}

variable "alarm_actions" {
  description = "List of ARNs to execute when alarm transitions to ALARM"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "List of ARNs to execute when alarm transitions to OK"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
