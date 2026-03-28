terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Basic Bedrock Agent Test
# Tests minimal agent configuration without action groups or knowledge bases
# Creates a simple conversational agent using Claude 3.5 Sonnet
# -----------------------------------------------------------------------------

provider "aws" {
  region = "us-east-1"

  # Mock configuration for testing - no real AWS credentials needed for plan
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    bedrock      = "http://localhost:4566"
    bedrockagent = "http://localhost:4566"
    iam          = "http://localhost:4566"
    sts          = "http://localhost:4566"
  }
}

# Create a basic Bedrock agent
module "bedrock_agent" {
  source = "../.."

  # Agent configuration
  agent_name       = "basic-customer-support-agent"
  foundation_model = "anthropic.claude-3-5-sonnet-20241022-v2:0"

  description = "A basic customer support agent that answers common questions"

  instruction = <<-EOT
    You are a helpful customer support agent for an e-commerce company.

    Your responsibilities:
    - Answer customer questions about orders, shipping, and returns
    - Be polite, professional, and empathetic
    - If you don't know an answer, admit it and offer to escalate to a human agent

    Always maintain a friendly and helpful tone.
  EOT

  # Use defaults for all other variables
  # - idle_session_ttl_in_seconds: 600 (10 minutes)
  # - create_agent_alias: true
  # - agent_alias_name: "production"

  tags = {
    Environment = "test"
    Purpose     = "basic-agent-test"
  }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "agent_id" {
  description = "ID of the Bedrock agent"
  value       = module.bedrock_agent.agent_id
}

output "agent_arn" {
  description = "ARN of the Bedrock agent"
  value       = module.bedrock_agent.agent_arn
}

output "agent_alias_id" {
  description = "ID of the agent alias"
  value       = module.bedrock_agent.agent_alias_id
}

output "agent_role_arn" {
  description = "ARN of the agent IAM role"
  value       = module.bedrock_agent.agent_role_arn
}

output "invoke_cli_example" {
  description = "CLI command to invoke the agent"
  value       = module.bedrock_agent.invoke_agent_cli_example
}
