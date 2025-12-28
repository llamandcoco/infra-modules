# -----------------------------------------------------------------------------
# Custom Metrics Dashboard Example
# -----------------------------------------------------------------------------
# Dashboard for custom CloudWatch metrics (business metrics)

module "custom_metrics_dashboard" {
  source = "../../"

  dashboard_name = "test-custom-metrics"

  widgets = [
    # Row 1: Command Processing Metrics
    {
      type = "metric"
      properties = {
        title  = "Command Success vs Failure"
        region = "ca-central-1"
        metrics = [
          ["SlackBot", "CommandProcessed", { stat = "Sum", label = "Success", color = "#2ca02c" }, { dimensions = { Command = "echo", Status = "Success", Environment = "plt" } }],
          ["...", { stat = "Sum", label = "Failure", color = "#d62728" }, { dimensions = { Status = "Failure" } }]
        ]
        view    = "timeSeries"
        stacked = true
        period  = 300
        yAxis = {
          left = {
            label = "Command Count"
          }
        }
      }
      width  = 12
      height = 6
      x      = 0
      y      = 0
    },

    # Row 1: Command Duration
    {
      type = "metric"
      properties = {
        title  = "Command Processing Duration"
        region = "ca-central-1"
        metrics = [
          ["SlackBot", "CommandDuration", { stat = "Average", label = "Average" }],
          ["...", { stat = "p99", label = "p99", color = "#ff7f0e" }],
          ["...", { stat = "Maximum", label = "Max", color = "#d62728" }]
        ]
        view   = "timeSeries"
        period = 300
        yAxis = {
          left = {
            label = "Milliseconds"
          }
        }
      }
      width  = 12
      height = 6
      x      = 12
      y      = 0
    },

    # Row 2: Slack API Latency
    {
      type = "metric"
      properties = {
        title  = "Slack API Response Time"
        region = "ca-central-1"
        metrics = [
          ["SlackBot", "SlackApiLatency", { stat = "Average", label = "Average Latency" }, { dimensions = { Environment = "plt", Endpoint = "response_url", Success = "true" } }],
          ["...", { stat = "p99", label = "p99 Latency", color = "#ff7f0e" }]
        ]
        view   = "timeSeries"
        period = 300
        yAxis = {
          left = {
            label = "Milliseconds"
          }
        }
        annotations = {
          horizontal = [
            {
              label = "Slow API Warning (2s)"
              value = 2000
              fill  = "above"
              color = "#ff7f0e"
            }
          ]
        }
      }
      width  = 12
      height = 6
      x      = 0
      y      = 6
    },

    # Row 2: Worker Processing Time
    {
      type = "metric"
      properties = {
        title  = "Worker Processing Time"
        region = "ca-central-1"
        metrics = [
          ["SlackBot", "WorkerProcessingTime", { stat = "Average", label = "Average" }, { dimensions = { WorkerType = "echo", Status = "Success", Environment = "plt" } }],
          ["...", { stat = "p99", label = "p99", color = "#ff7f0e" }]
        ]
        view   = "timeSeries"
        period = 300
        yAxis = {
          left = {
            label = "Milliseconds"
          }
        }
      }
      width  = 12
      height = 6
      x      = 12
      y      = 6
    },

    # Row 3: Success Rate (Single Value)
    {
      type = "metric"
      properties = {
        title  = "Success Rate (24h)"
        region = "ca-central-1"
        metrics = [
          [
            {
              expression = "100 - (m2 / (m1 + m2) * 100)"
              label      = "Success Rate (%)"
              id         = "e1"
            }
          ],
          ["SlackBot", "CommandProcessed", { id = "m1", stat = "Sum", visible = false }, { dimensions = { Status = "Success" } }],
          ["...", { id = "m2", stat = "Sum", visible = false }, { dimensions = { Status = "Failure" } }]
        ]
        view   = "singleValue"
        period = 86400
        yAxis = {
          left = {
            min = 0
            max = 100
          }
        }
      }
      width  = 8
      height = 6
      x      = 0
      y      = 12
    },

    # Row 3: Total Commands
    {
      type = "metric"
      properties = {
        title  = "Total Commands (24h)"
        region = "ca-central-1"
        metrics = [
          ["SlackBot", "CommandProcessed", { stat = "Sum", label = "Total" }]
        ]
        view   = "singleValue"
        period = 86400
      }
      width  = 8
      height = 6
      x      = 8
      y      = 12
    },

    # Row 3: Avg Slack API Latency
    {
      type = "metric"
      properties = {
        title  = "Avg Slack API Latency (24h)"
        region = "ca-central-1"
        metrics = [
          ["SlackBot", "SlackApiLatency", { stat = "Average", label = "Avg (ms)" }]
        ]
        view   = "singleValue"
        period = 86400
      }
      width  = 8
      height = 6
      x      = 16
      y      = 12
    },

    # Row 4: Commands by Type (Pie Chart)
    {
      type = "metric"
      properties = {
        title  = "Commands by Type"
        region = "ca-central-1"
        metrics = [
          ["SlackBot", "CommandProcessed", { stat = "Sum", label = "Echo" }, { dimensions = { Command = "echo" } }],
          ["...", { stat = "Sum", label = "Deploy" }, { dimensions = { Command = "deploy" } }],
          ["...", { stat = "Sum", label = "Status" }, { dimensions = { Command = "status" } }]
        ]
        view   = "pie"
        period = 3600
      }
      width  = 12
      height = 6
      x      = 0
      y      = 18
    },

    # Row 4: Documentation
    {
      type = "text"
      properties = {
        markdown = <<-MARKDOWN
          # Custom Metrics Dashboard

          ## Metrics Overview

          **Business Metrics:**
          - `CommandProcessed` - Total commands by status
          - `CommandDuration` - Time to process commands
          - `SlackApiLatency` - Slack API response time
          - `WorkerProcessingTime` - Worker execution time

          ## Namespace
          All custom metrics are in the **SlackBot** namespace.

          ## Dimensions
          - `Environment` - plt/prod
          - `Command` - echo/deploy/status
          - `Status` - Success/Failure
          - `WorkerType` - echo/deploy/status
        MARKDOWN
      }
      width  = 12
      height = 6
      x      = 12
      y      = 18
    }
  ]
}

output "dashboard_url" {
  value = module.custom_metrics_dashboard.dashboard_url
}
