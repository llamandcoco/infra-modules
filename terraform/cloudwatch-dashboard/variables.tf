# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "dashboard_name" {
  description = "Name of the CloudWatch dashboard. Must be unique within the AWS region."
  type        = string

  validation {
    condition     = length(var.dashboard_name) > 0 && length(var.dashboard_name) <= 255
    error_message = "Dashboard name must be between 1 and 255 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.dashboard_name))
    error_message = "Dashboard name must contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "widgets" {
  description = <<-EOT
    List of widget configurations for the dashboard.
    Each widget must include: type, properties, width, height, x, y.

    Widget types:
    - metric: Display CloudWatch metrics
    - log: Display CloudWatch Logs Insights queries
    - text: Display markdown text
    - alarm: Display CloudWatch alarms

    Example:
    ```
    widgets = [
      {
        type = "metric"
        properties = {
          title = "Lambda Invocations"
          region = "us-east-1"
          metrics = [
            ["AWS/Lambda", "Invocations", { stat = "Sum" }]
          ]
          view = "timeSeries"
          period = 300
        }
        width = 12
        height = 6
        x = 0
        y = 0
      }
    ]
    ```
  EOT
  type        = any

  validation {
    condition     = length(var.widgets) > 0
    error_message = "At least one widget must be defined."
  }
}
