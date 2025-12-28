# -----------------------------------------------------------------------------
# Pipeline Dashboard Example
# -----------------------------------------------------------------------------
# Multi-component monitoring for Slack bot pipeline:
# Slack → API Gateway → Router Lambda → EventBridge → SQS → Echo Worker

module "pipeline_dashboard" {
  source = "../../"

  dashboard_name = "test-slack-bot-pipeline"

  widgets = [
    # Row 1: End-to-End Pipeline Health
    {
      type = "metric"
      properties = {
        title  = "Pipeline Health - All Components"
        region = "ca-central-1"
        metrics = [
          ["AWS/ApiGateway", "Count", { stat = "Sum", label = "1. API Gateway" }],
          ["AWS/Lambda", "Invocations", { stat = "Sum", label = "2. Router Lambda" }],
          ["AWS/Events", "Invocations", { stat = "Sum", label = "3. EventBridge" }],
          ["AWS/SQS", "NumberOfMessagesSent", { stat = "Sum", label = "4. SQS Queue" }],
          ["AWS/Lambda", "Invocations", { stat = "Sum", label = "5. Echo Worker" }]
        ]
        view    = "timeSeries"
        stacked = false
        period  = 300
        yAxis = {
          left = {
            label     = "Requests"
            showUnits = false
          }
        }
      }
      width  = 24
      height = 6
      x      = 0
      y      = 0
    },

    # Row 2: Error Rate
    {
      type = "metric"
      properties = {
        title  = "Pipeline Error Rate"
        region = "ca-central-1"
        metrics = [
          ["AWS/ApiGateway", "5XXError", { stat = "Sum", label = "API Gateway 5XX", color = "#d62728" }],
          ["AWS/Lambda", "Errors", { stat = "Sum", label = "Lambda Errors", color = "#ff7f0e" }],
          ["AWS/Events", "FailedInvocations", { stat = "Sum", label = "EventBridge Failures", color = "#bcbd22" }]
        ]
        view    = "timeSeries"
        stacked = true
        period  = 300
      }
      width  = 12
      height = 6
      x      = 0
      y      = 6
    },

    # Row 2: Dead Letter Queue (Critical)
    {
      type = "metric"
      properties = {
        title  = "🚨 Dead Letter Queue"
        region = "ca-central-1"
        metrics = [
          ["AWS/SQS", "ApproximateNumberOfMessagesVisible", { stat = "Maximum", color = "#d62728" }]
        ]
        view   = "timeSeries"
        period = 60
        annotations = {
          horizontal = [
            {
              label = "CRITICAL: Must be 0"
              value = 1
              fill  = "above"
              color = "#d62728"
            }
          ]
        }
      }
      width  = 12
      height = 6
      x      = 12
      y      = 6
    },

    # Row 3: SQS Queue Health
    {
      type = "metric"
      properties = {
        title  = "SQS Queue Metrics"
        region = "ca-central-1"
        metrics = [
          ["AWS/SQS", "ApproximateNumberOfMessagesVisible", { stat = "Average", label = "Messages in Queue" }],
          [".", "ApproximateAgeOfOldestMessage", { stat = "Maximum", label = "Oldest Message Age (s)", yAxis = "right", color = "#ff7f0e" }]
        ]
        view   = "timeSeries"
        period = 60
        yAxis = {
          left = {
            label = "Message Count"
          }
          right = {
            label = "Age (seconds)"
          }
        }
        annotations = {
          horizontal = [
            {
              label = "Backlog Warning"
              value = 50
              fill  = "above"
              color = "#ff7f0e"
              yAxis = "left"
            },
            {
              label = "Age Warning (5min)"
              value = 300
              fill  = "above"
              color = "#d62728"
              yAxis = "right"
            }
          ]
        }
      }
      width  = 24
      height = 6
      x      = 0
      y      = 12
    },

    # Row 4: Lambda Performance
    {
      type = "metric"
      properties = {
        title  = "Lambda Duration (p99)"
        region = "ca-central-1"
        metrics = [
          ["AWS/Lambda", "Duration", { stat = "p99", label = "Router p99" }],
          ["AWS/Lambda", "Duration", { stat = "p99", label = "Worker p99", color = "#ff7f0e" }]
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
              label = "Slack Timeout (3s)"
              value = 3000
              fill  = "above"
              color = "#d62728"
            }
          ]
        }
      }
      width  = 12
      height = 6
      x      = 0
      y      = 18
    },

    # Row 4: Success Rate
    {
      type = "metric"
      properties = {
        title  = "Success Rate"
        region = "ca-central-1"
        metrics = [
          [
            {
              expression = "100 - (m2 / m1 * 100)"
              label      = "Success Rate (%)"
              id         = "e1"
            }
          ],
          ["AWS/Lambda", "Invocations", { id = "m1", stat = "Sum", visible = false }],
          [".", "Errors", { id = "m2", stat = "Sum", visible = false }]
        ]
        view   = "timeSeries"
        period = 300
        yAxis = {
          left = {
            min = 0
            max = 100
          }
        }
      }
      width  = 12
      height = 6
      x      = 12
      y      = 18
    },

    # Row 5: Recent Errors (Log Query)
    {
      type = "log"
      properties = {
        title  = "Recent Errors"
        region = "ca-central-1"
        query  = <<-QUERY
          SOURCE '/aws/lambda/laco-plt-slack-router'
          | SOURCE '/aws/lambda/laco-plt-chatbot-echo-worker'
          | fields @timestamp, @logStream, message, error.message, correlationId
          | filter level = "error"
          | sort @timestamp desc
          | limit 20
        QUERY
        view   = "table"
      }
      width  = 24
      height = 6
      x      = 0
      y      = 24
    },

    # Row 6: Quick Links
    {
      type = "text"
      properties = {
        markdown = <<-MARKDOWN
          # Slack Bot Pipeline Dashboard

          ## Flow
          \`\`\`
          Slack → API Gateway → Router Lambda → EventBridge → SQS → Echo Worker → Slack
          \`\`\`

          ## Quick Links
          - [X-Ray Service Map](https://ca-central-1.console.aws.amazon.com/xray/home?region=ca-central-1#/service-map)
          - [CloudWatch Logs Insights](https://ca-central-1.console.aws.amazon.com/cloudwatch/home?region=ca-central-1#logsV2:logs-insights)

          ## Health Indicators
          - ✅ Green: Error rate < 1%, DLQ = 0
          - ⚠️ Yellow: Warning thresholds exceeded
          - 🚨 Red: Critical issues
        MARKDOWN
      }
      width  = 24
      height = 4
      x      = 0
      y      = 30
    }
  ]
}

output "dashboard_url" {
  value = module.pipeline_dashboard.dashboard_url
}
