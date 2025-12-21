# AWS Bedrock Agent

A production-ready Terraform module for creating AWS Agents for Amazon Bedrock with action groups, knowledge base integration, and customizable configuration.

## Features

- **Managed AI Agents** - Create fully managed agents with built-in orchestration and reasoning
- **Action Groups** - Connect agents to Lambda functions and APIs for real-world actions
- **Knowledge Base Integration** - Enable RAG (Retrieval-Augmented Generation) capabilities
- **Agent Aliases** - Stable endpoints for different agent versions
- **Prompt Customization** - Override default prompts and inference parameters
- **IAM Management** - Automatic role creation with least-privilege permissions

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
| Basic - Simple conversational agent | [`tests/basic/main.tf`](tests/basic/main.tf) |
| Advanced - With action groups and knowledge bases | [`tests/advanced/main.tf`](tests/advanced/main.tf) |

**Usage:**
```bash
# View example
cat tests/basic/main.tf

# Copy and adapt
cp -r tests/basic/ my-project/
```

## Use Cases

### 1. Basic Conversational Agent

Simple agent without external integrations:

```hcl
module "chatbot" {
  source = "github.com/llamandcoco/infra-modules//terraform/bedrock-agent?ref=<commit-sha>"

  agent_name       = "company-chatbot"
  foundation_model = "anthropic.claude-3-haiku-20240307-v1:0"

  instruction = "You are a friendly chatbot that helps users navigate our website."
}
```

### 2. Agent with Action Groups (Lambda Integration)

Agent that can perform actions via Lambda functions:

```hcl
# First, create your Lambda function
resource "aws_lambda_function" "order_lookup" {
  function_name = "order-lookup"
  handler       = "index.handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda.arn
  filename      = "lambda.zip"
}

# Then create the agent with action group
module "agent" {
  source = "github.com/llamandcoco/infra-modules//terraform/bedrock-agent?ref=<commit-sha>"

  agent_name       = "order-agent"
  foundation_model = "anthropic.claude-3-5-sonnet-20241022-v2:0"

  instruction = "You are an order management agent. Use the order lookup API to help customers."

  action_groups = [
    {
      name                    = "order-lookup"
      description             = "Look up order information"
      lambda_arn              = aws_lambda_function.order_lookup.arn
      grant_lambda_permission = true
      api_schema_payload      = file("${path.module}/order-api-schema.json")
    }
  ]
}
```

### 3. Agent with Knowledge Base (RAG)

Agent with access to a knowledge base for context-aware responses:

```hcl
# Assuming you have a Bedrock knowledge base created
module "agent" {
  source = "github.com/llamandcoco/infra-modules//terraform/bedrock-agent?ref=<commit-sha>"

  agent_name       = "documentation-agent"
  foundation_model = "anthropic.claude-3-5-sonnet-20241022-v2:0"

  instruction = "You are a documentation assistant. Use the knowledge base to answer questions accurately."

  knowledge_base_ids = [
    "YOUR-KNOWLEDGE-BASE-ID"
  ]
}
```

### 4. Advanced Agent with Custom Configuration

Full-featured agent with all options:

```hcl
module "agent" {
  source = "github.com/llamandcoco/infra-modules//terraform/bedrock-agent?ref=<commit-sha>"

  agent_name       = "advanced-agent"
  foundation_model = "anthropic.claude-3-opus-20240229-v1:0"
  description      = "Production agent with full capabilities"

  instruction = "Your detailed agent instructions here..."

  # Action groups
  action_groups = [
    {
      name           = "database-query"
      lambda_arn     = aws_lambda_function.db_query.arn
      api_schema_payload = file("db-api-schema.json")
    },
    {
      name           = "send-email"
      lambda_arn     = aws_lambda_function.email.arn
      api_schema_payload = file("email-api-schema.json")
    }
  ]

  # Knowledge bases
  knowledge_base_ids = ["KB-123", "KB-456"]

  # Custom prompt configuration
  prompt_override_configuration = {
    orchestration_prompt_template = "Your custom prompt template..."
    temperature                   = 0.7
    top_p                         = 0.9
    max_length                    = 2048
  }

  # Session settings
  idle_session_ttl_in_seconds = 1800  # 30 minutes

  # Alias configuration
  create_agent_alias      = true
  agent_alias_name        = "production"
  agent_alias_description = "Production version"

  tags = {
    Environment = "production"
    Team        = "ai-platform"
  }
}
```

## Action Group API Schema

Action groups require an OpenAPI schema to define the API contract. Example:

```json
{
  "openapi": "3.0.0",
  "info": {
    "title": "Order Lookup API",
    "version": "1.0.0"
  },
  "paths": {
    "/orders/{orderId}": {
      "get": {
        "summary": "Get order details",
        "operationId": "getOrder",
        "parameters": [
          {
            "name": "orderId",
            "in": "path",
            "required": true,
            "schema": { "type": "string" }
          }
        ],
        "responses": {
          "200": {
            "description": "Success"
          }
        }
      }
    }
  }
}
```

## Lambda Function Format for Action Groups

Your Lambda function must return a specific response format:

```python
def handler(event, context):
    # Extract parameters from the agent event
    parameters = event.get('parameters', [])

    # Process the request
    result = {"key": "value"}

    # Return in Bedrock Agent format
    return {
        'messageVersion': '1.0',
        'response': {
            'actionGroup': event['actionGroup'],
            'apiPath': event['apiPath'],
            'httpMethod': event['httpMethod'],
            'httpStatusCode': 200,
            'responseBody': {
                'application/json': {
                    'body': json.dumps(result)
                }
            }
        }
    }
```

## Invoking Your Agent

### AWS CLI

```bash
aws bedrock-agent-runtime invoke-agent \
  --agent-id <agent-id> \
  --agent-alias-id <alias-id> \
  --session-id $(uuidgen) \
  --input-text "What is the status of order 12345?" \
  output.txt
```

### Python (boto3)

```python
import boto3
import uuid

bedrock_runtime = boto3.client('bedrock-agent-runtime')

response = bedrock_runtime.invoke_agent(
    agentId='YOUR-AGENT-ID',
    agentAliasId='YOUR-ALIAS-ID',
    sessionId=str(uuid.uuid4()),
    inputText='Your question here'
)

# Stream the response
for event in response['completion']:
    chunk = event.get('chunk', {})
    if 'bytes' in chunk:
        print(chunk['bytes'].decode('utf-8'), end='')
```

### JavaScript (AWS SDK v3)

```javascript
import { BedrockAgentRuntimeClient, InvokeAgentCommand } from "@aws-sdk/client-bedrock-agent-runtime";
import { v4 as uuidv4 } from 'uuid';

const client = new BedrockAgentRuntimeClient({ region: "us-east-1" });

const command = new InvokeAgentCommand({
  agentId: "YOUR-AGENT-ID",
  agentAliasId: "YOUR-ALIAS-ID",
  sessionId: uuidv4(),
  inputText: "Your question here"
});

const response = await client.send(command);
```

## Testing

```bash
# Basic test
cd tests/basic && terraform init && terraform plan

# Advanced test
cd tests/advanced && terraform init && terraform plan
```

## Notes

- **Model Selection**: Choose models based on your needs:
  - Claude 3.5 Sonnet: Best balance of intelligence and speed
  - Claude 3 Opus: Maximum intelligence for complex tasks
  - Claude 3 Haiku: Fastest and most cost-effective

- **Action Group Limits**: Each agent can have up to 10 action groups

- **Knowledge Base Association**: Agents can be associated with multiple knowledge bases for comprehensive RAG

- **Session Management**: Sessions automatically expire after `idle_session_ttl_in_seconds` of inactivity

- **Agent Preparation**: After creating or updating an agent, it must be "prepared" before use. This happens automatically when creating an alias.

- **Costs**: Bedrock Agents pricing includes:
  - Base agent cost per session
  - Foundation model inference costs
  - Knowledge base query costs (if using RAG)
  - Lambda invocation costs (for action groups)

## Common Patterns

### Multi-Step Task Automation
Agents can chain multiple action groups together to complete complex tasks:
1. User asks "Order product X and send me tracking info"
2. Agent calls `check-inventory` action
3. Agent calls `create-order` action
4. Agent calls `send-email` action with tracking details

### RAG with Dynamic Data
Combine knowledge bases with action groups:
- Knowledge base: Static documentation
- Action groups: Real-time data (inventory, orders, user accounts)

### Human-in-the-Loop
Configure agents to escalate complex queries:
- Agent attempts to handle request
- If confidence is low, agent suggests human escalation
- Action group creates support ticket

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
