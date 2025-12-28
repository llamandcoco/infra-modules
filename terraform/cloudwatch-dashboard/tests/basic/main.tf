# -----------------------------------------------------------------------------
# Basic CloudWatch Dashboard Example
# -----------------------------------------------------------------------------
# This example creates a simple dashboard with Lambda metrics

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  token                       = "mock_token"
  skip_credentials_validation = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

module "basic_dashboard" {
  source = "../../"

  dashboard_name = "test-basic-dashboard"

  widgets = [
    # Lambda Invocations
    {
      type = "metric"
      properties = {
        title  = "Lambda Invocations"
        region = "us-east-1"
        metrics = [
          ["AWS/Lambda", "Invocations", { stat = "Sum", label = "Total Invocations" }]
        ]
        view   = "timeSeries"
        period = 300
      }
      width  = 12
      height = 6
      x      = 0
      y      = 0
    },

    # Lambda Errors
    {
      type = "metric"
      properties = {
        title  = "Lambda Errors"
        region = "us-east-1"
        metrics = [
          ["AWS/Lambda", "Errors", { stat = "Sum", label = "Errors", color = "#d62728" }]
        ]
        view   = "timeSeries"
        period = 300
      }
      width  = 12
      height = 6
      x      = 12
      y      = 0
    },

    # Info Text
    {
      type = "text"
      properties = {
        markdown = <<-MARKDOWN
          # Basic Dashboard Example

          This dashboard monitors Lambda function metrics.

          ## Quick Links
          - [Lambda Console](https://console.aws.amazon.com/lambda/)
          - [CloudWatch Logs](https://console.aws.amazon.com/cloudwatch/logs/)
        MARKDOWN
      }
      width  = 24
      height = 3
      x      = 0
      y      = 6
    }
  ]
}

output "dashboard_url" {
  value = module.basic_dashboard.dashboard_url
}
