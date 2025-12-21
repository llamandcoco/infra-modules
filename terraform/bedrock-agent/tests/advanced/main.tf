terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Advanced Bedrock Agent Test
# Tests comprehensive agent configuration with:
# - Multiple action groups (Lambda-based API integrations)
# - Knowledge base association
# - Custom prompt override configuration
# - Multiple agent aliases
# - Custom IAM role configuration
# -----------------------------------------------------------------------------

provider "aws" {
  region = "us-west-2"

  # Mock configuration for testing - no real AWS credentials needed for plan
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    bedrock        = "http://localhost:4566"
    bedrockagent   = "http://localhost:4566"
    iam            = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    cloudwatchlogs = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }
}

# -----------------------------------------------------------------------------
# Lambda Functions for Action Groups
# These Lambda functions will be called by the agent to perform actions
# -----------------------------------------------------------------------------

# Create sample Lambda code for order lookup
resource "local_file" "order_lookup_code" {
  filename = "${path.module}/order_lookup.py"
  content  = <<-EOT
    import json

    def handler(event, context):
        """
        Look up order information by order ID.
        """
        # Extract parameters from the agent event
        parameters = event.get('parameters', [])
        order_id = next((p['value'] for p in parameters if p['name'] == 'orderId'), None)

        # Mock order lookup
        order_data = {
            'orderId': order_id,
            'status': 'shipped',
            'estimatedDelivery': '2024-01-15',
            'items': ['Widget A', 'Gadget B']
        }

        return {
            'messageVersion': '1.0',
            'response': {
                'actionGroup': event['actionGroup'],
                'apiPath': event['apiPath'],
                'httpMethod': event['httpMethod'],
                'httpStatusCode': 200,
                'responseBody': {
                    'application/json': {
                        'body': json.dumps(order_data)
                    }
                }
            }
        }
  EOT
}

# Package Lambda function
data "archive_file" "order_lookup" {
  type        = "zip"
  source_file = local_file.order_lookup_code.filename
  output_path = "${path.module}/order_lookup.zip"
}

# IAM role for Lambda
resource "aws_iam_role" "order_lookup_lambda" {
  name = "advanced-order-lookup-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Lambda function for order lookup
resource "aws_lambda_function" "order_lookup" {
  function_name    = "advanced-order-lookup"
  handler          = "order_lookup.handler"
  runtime          = "python3.12"
  role             = aws_iam_role.order_lookup_lambda.arn
  filename         = data.archive_file.order_lookup.output_path
  source_code_hash = data.archive_file.order_lookup.output_base64sha256
  timeout          = 30
}

# Create sample Lambda code for inventory check
resource "local_file" "inventory_check_code" {
  filename = "${path.module}/inventory_check.py"
  content  = <<-EOT
    import json

    def handler(event, context):
        """
        Check inventory availability for a product.
        """
        parameters = event.get('parameters', [])
        product_id = next((p['value'] for p in parameters if p['name'] == 'productId'), None)

        # Mock inventory check
        inventory_data = {
            'productId': product_id,
            'inStock': True,
            'quantity': 42,
            'warehouse': 'US-West-1'
        }

        return {
            'messageVersion': '1.0',
            'response': {
                'actionGroup': event['actionGroup'],
                'apiPath': event['apiPath'],
                'httpMethod': event['httpMethod'],
                'httpStatusCode': 200,
                'responseBody': {
                    'application/json': {
                        'body': json.dumps(inventory_data)
                    }
                }
            }
        }
  EOT
}

# Package Lambda function
data "archive_file" "inventory_check" {
  type        = "zip"
  source_file = local_file.inventory_check_code.filename
  output_path = "${path.module}/inventory_check.zip"
}

# IAM role for Lambda
resource "aws_iam_role" "inventory_check_lambda" {
  name = "advanced-inventory-check-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Lambda function for inventory check
resource "aws_lambda_function" "inventory_check" {
  function_name    = "advanced-inventory-check"
  handler          = "inventory_check.handler"
  runtime          = "python3.12"
  role             = aws_iam_role.inventory_check_lambda.arn
  filename         = data.archive_file.inventory_check.output_path
  source_code_hash = data.archive_file.inventory_check.output_base64sha256
  timeout          = 30
}

# -----------------------------------------------------------------------------
# API Schema for Action Groups (OpenAPI specification)
# -----------------------------------------------------------------------------

locals {
  order_lookup_api_schema = jsonencode({
    openapi = "3.0.0"
    info = {
      title   = "Order Lookup API"
      version = "1.0.0"
    }
    paths = {
      "/orders/{orderId}" = {
        get = {
          summary     = "Get order details by order ID"
          description = "Retrieves detailed information about a specific order"
          operationId = "getOrderById"
          parameters = [
            {
              name        = "orderId"
              in          = "path"
              required    = true
              description = "The unique identifier of the order"
              schema = {
                type = "string"
              }
            }
          ]
          responses = {
            "200" = {
              description = "Successful response"
              content = {
                "application/json" = {
                  schema = {
                    type = "object"
                    properties = {
                      orderId = {
                        type        = "string"
                        description = "Order ID"
                      }
                      status = {
                        type        = "string"
                        description = "Order status"
                      }
                      estimatedDelivery = {
                        type        = "string"
                        description = "Estimated delivery date"
                      }
                      items = {
                        type        = "array"
                        description = "List of items in the order"
                        items = {
                          type = "string"
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  })

  inventory_check_api_schema = jsonencode({
    openapi = "3.0.0"
    info = {
      title   = "Inventory Check API"
      version = "1.0.0"
    }
    paths = {
      "/inventory/{productId}" = {
        get = {
          summary     = "Check product inventory"
          description = "Retrieves inventory information for a specific product"
          operationId = "checkInventory"
          parameters = [
            {
              name        = "productId"
              in          = "path"
              required    = true
              description = "The unique identifier of the product"
              schema = {
                type = "string"
              }
            }
          ]
          responses = {
            "200" = {
              description = "Successful response"
              content = {
                "application/json" = {
                  schema = {
                    type = "object"
                    properties = {
                      productId = {
                        type        = "string"
                        description = "Product ID"
                      }
                      inStock = {
                        type        = "boolean"
                        description = "Whether product is in stock"
                      }
                      quantity = {
                        type        = "integer"
                        description = "Available quantity"
                      }
                      warehouse = {
                        type        = "string"
                        description = "Warehouse location"
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  })
}

# -----------------------------------------------------------------------------
# Bedrock Agent with Advanced Configuration
# -----------------------------------------------------------------------------

module "bedrock_agent" {
  source = "../.."

  # Agent configuration
  agent_name       = "advanced-ecommerce-agent"
  foundation_model = "anthropic.claude-3-5-sonnet-20241022-v2:0"
  agent_role_name  = "advanced-ecommerce-agent-role"

  description = "Advanced e-commerce agent with order lookup and inventory management capabilities"

  instruction = <<-EOT
    You are an advanced customer support agent for an e-commerce platform.

    Your capabilities:
    1. Look up order information using the order lookup API
    2. Check product inventory using the inventory check API
    3. Answer customer questions about orders, shipping, returns, and products
    4. Access the knowledge base for detailed product information and policies

    Guidelines:
    - Always be polite, professional, and helpful
    - Use the order lookup API when customers ask about their order status
    - Use the inventory API when customers ask about product availability
    - Refer to the knowledge base for detailed product specs and company policies
    - If you cannot help, offer to escalate to a human agent

    Remember to provide accurate information and excellent customer service.
  EOT

  # Action groups - Lambda integrations
  action_groups = [
    {
      name                    = "order-lookup"
      description             = "Look up order information by order ID"
      lambda_arn              = aws_lambda_function.order_lookup.arn
      grant_lambda_permission = true
      api_schema_payload      = local.order_lookup_api_schema
    },
    {
      name                    = "inventory-check"
      description             = "Check product inventory availability"
      lambda_arn              = aws_lambda_function.inventory_check.arn
      grant_lambda_permission = true
      api_schema_payload      = local.inventory_check_api_schema
    }
  ]

  # Knowledge base association (mock ID for testing)
  # In production, this would be an actual knowledge base ID
  knowledge_base_ids = [
    "MOCK-KB-123456789"
  ]

  # Advanced prompt configuration
  prompt_override_configuration = {
    orchestration_prompt_template = <<-EOT
      You are an AI agent with access to tools and a knowledge base.
      Follow the user's instructions carefully and use available tools when appropriate.

      $instruction$

      $tools$

      $knowledge_base$
    EOT
    temperature                   = 0.7
    top_p                         = 0.9
    top_k                         = 250
    max_length                    = 2048
    stop_sequences                = []
  }

  # Session configuration
  idle_session_ttl_in_seconds = 1800 # 30 minutes

  # Create production alias
  create_agent_alias      = true
  agent_alias_name        = "production"
  agent_alias_description = "Production alias for the advanced e-commerce agent"

  tags = {
    Environment = "production"
    Purpose     = "advanced-agent-test"
    Team        = "customer-support"
    CostCenter  = "engineering"
  }

  depends_on = [
    aws_lambda_function.order_lookup,
    aws_lambda_function.inventory_check
  ]
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

output "agent_alias_arn" {
  description = "ARN of the agent alias"
  value       = module.bedrock_agent.agent_alias_arn
}

output "agent_role_arn" {
  description = "ARN of the agent IAM role"
  value       = module.bedrock_agent.agent_role_arn
}

output "action_groups" {
  description = "Action groups configured for the agent"
  value       = module.bedrock_agent.action_group_ids
}

output "knowledge_bases" {
  description = "Knowledge bases associated with the agent"
  value       = module.bedrock_agent.knowledge_base_associations
}

output "invoke_cli_example" {
  description = "CLI command to invoke the agent"
  value       = module.bedrock_agent.invoke_agent_cli_example
}

output "boto3_invoke_example" {
  description = "Python boto3 code to invoke the agent"
  value       = module.bedrock_agent.boto3_invoke_example
}

output "order_lookup_lambda_arn" {
  description = "ARN of the order lookup Lambda function"
  value       = aws_lambda_function.order_lookup.arn
}

output "inventory_check_lambda_arn" {
  description = "ARN of the inventory check Lambda function"
  value       = aws_lambda_function.inventory_check.arn
}
