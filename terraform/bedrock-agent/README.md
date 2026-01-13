# AWS Bedrock Agent

Production-ready Terraform module for creating AWS Agents for Amazon Bedrock with action groups, knowledge base integration, and customizable configuration.

## Features

- Managed AI Agents Create fully managed agents with built-in orchestration and reasoning
- Action Groups Connect agents to Lambda functions and APIs for real-world actions
- Knowledge Base Integration Enable RAG (Retrieval-Augmented Generation) capabilities
- Agent Aliases Stable endpoints for different agent versions
- Prompt Customization Override default prompts and inference parameters
- IAM Management Automatic role creation with least-privilege permissions
- Lambda Triggers Automatic permission grants for action group Lambda functions
- Comprehensive Outputs Agent IDs, ARNs, and invocation examples

## Quick Start

```hcl
module "bedrock_agent" {
  source = "github.com/llamandcoco/infra-modules//terraform/bedrock-agent?ref=<commit-sha>"

  agent_name       = "customer-support-agent"
  foundation_model = "anthropic.claude-3-5-sonnet-20241022-v2:0"

  instruction = <<-EOT
    You are a helpful customer support agent.
    Answer questions about orders, shipping, and returns.
    Always be polite and professional.
  EOT
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|----------|
| Basic | [`tests/basic/main.tf`](tests/basic/main.tf) |
| Advanced | [`tests/advanced/main.tf`](tests/advanced/main.tf) |

**Usage:**
```bash
# View example
cat tests/basic/

# Copy and adapt
cp -r tests/basic/ my-project/
```

## Testing

```bash
cd tests/basic && terraform init && terraform plan
```

<details>
<summary>Terraform Documentation</summary>

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
</details>
