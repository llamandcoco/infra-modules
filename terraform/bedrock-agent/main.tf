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
# Local Variables
# -----------------------------------------------------------------------------

locals {
  # Common tags to apply to all resources
  common_tags = merge(
    var.tags,
    {
      ManagedBy = "Terraform"
      Module    = "bedrock-agent"
    }
  )

  # Determine if we should create action groups
  has_action_groups = length(var.action_groups) > 0

  # Determine if we should associate knowledge bases
  has_knowledge_bases = length(var.knowledge_base_ids) > 0
}


# -----------------------------------------------------------------------------
# IAM Role for Bedrock Agent
# Allows the agent to invoke foundation models and perform actions
# -----------------------------------------------------------------------------
resource "aws_iam_role" "agent" {
  name        = var.agent_role_name != null ? var.agent_role_name : "${var.agent_name}-agent-role"
  description = "IAM role for Bedrock Agent ${var.agent_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = var.agent_role_name != null ? var.agent_role_name : "${var.agent_name}-agent-role"
    }
  )
}

# -----------------------------------------------------------------------------
# IAM Policy for Foundation Model Access
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy" "model_invocation" {
  name = "bedrock-model-invocation-policy"
  role = aws_iam_role.agent.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = var.foundation_model_arn
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# IAM Policy for Knowledge Base Access (if enabled)
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy" "knowledge_base" {
  count = local.has_knowledge_bases ? 1 : 0

  name = "bedrock-knowledge-base-policy"
  role = aws_iam_role.agent.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:Retrieve"
        ]
        Resource = [
          for kb_id in var.knowledge_base_ids :
          "arn:aws:bedrock:*:*:knowledge-base/${kb_id}"
        ]
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# Bedrock Agent
# Creates the AI agent with configuration
# -----------------------------------------------------------------------------
resource "aws_bedrockagent_agent" "this" {
  agent_name              = var.agent_name
  agent_resource_role_arn = aws_iam_role.agent.arn
  foundation_model        = var.foundation_model
  description             = var.description
  instruction             = var.instruction

  idle_session_ttl_in_seconds = var.idle_session_ttl_in_seconds

  # Customer encryption key (optional)
  customer_encryption_key_arn = var.customer_encryption_key_arn

  # Prompt override configuration (optional)
  dynamic "prompt_override_configuration" {
    for_each = var.prompt_override_configuration != null ? [var.prompt_override_configuration] : []

    content {
      prompt_configurations {
        base_prompt_template = prompt_override_configuration.value.orchestration_prompt_template
        inference_configuration {
          temperature    = prompt_override_configuration.value.temperature
          top_p          = prompt_override_configuration.value.top_p
          top_k          = prompt_override_configuration.value.top_k
          max_length     = prompt_override_configuration.value.max_length
          stop_sequences = prompt_override_configuration.value.stop_sequences
        }
        parser_mode          = "DEFAULT"
        prompt_creation_mode = "OVERRIDDEN"
        prompt_state         = "ENABLED"
        prompt_type          = "ORCHESTRATION"
      }
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = var.agent_name
    }
  )

  depends_on = [
    aws_iam_role_policy.model_invocation,
    aws_iam_role_policy.knowledge_base
  ]
}

# -----------------------------------------------------------------------------
# Action Groups
# Connect the agent to Lambda functions or API schemas
# -----------------------------------------------------------------------------
resource "aws_bedrockagent_agent_action_group" "this" {
  for_each = { for ag in var.action_groups : ag.name => ag }

  agent_id          = aws_bedrockagent_agent.this.agent_id
  agent_version     = "DRAFT"
  action_group_name = each.value.name
  description       = each.value.description

  # Action group executor - Lambda function
  dynamic "action_group_executor" {
    for_each = each.value.lambda_arn != null ? [1] : []

    content {
      lambda = each.value.lambda_arn
    }
  }

  # API schema (OpenAPI or JSON schema)
  dynamic "api_schema" {
    for_each = each.value.api_schema_s3_bucket != null ? [1] : []

    content {
      s3 {
        s3_bucket_name = each.value.api_schema_s3_bucket
        s3_object_key  = each.value.api_schema_s3_key
      }
    }
  }

  # Inline API schema
  dynamic "api_schema" {
    for_each = each.value.api_schema_payload != null ? [1] : []

    content {
      payload = each.value.api_schema_payload
    }
  }

  skip_resource_in_use_check = var.skip_resource_in_use_check
}

# -----------------------------------------------------------------------------
# Lambda Permissions for Action Groups
# Allows Bedrock agent to invoke Lambda functions
# -----------------------------------------------------------------------------
resource "aws_lambda_permission" "agent_action_group" {
  for_each = {
    for ag in var.action_groups :
    ag.name => ag if ag.lambda_arn != null && ag.grant_lambda_permission
  }

  statement_id  = "AllowBedrockAgent"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_arn
  principal     = "bedrock.amazonaws.com"
  source_arn    = "arn:aws:bedrock:*:*:agent/${aws_bedrockagent_agent.this.agent_id}"
}

# -----------------------------------------------------------------------------
# Knowledge Base Associations
# Connect the agent to knowledge bases for RAG
# -----------------------------------------------------------------------------
resource "aws_bedrockagent_agent_knowledge_base_association" "this" {
  for_each = toset(var.knowledge_base_ids)

  agent_id             = aws_bedrockagent_agent.this.agent_id
  agent_version        = "DRAFT"
  knowledge_base_id    = each.value
  description          = "Knowledge base association for ${var.agent_name}"
  knowledge_base_state = "ENABLED"
}

# -----------------------------------------------------------------------------
# Agent Alias
# Creates a stable endpoint for the agent
# -----------------------------------------------------------------------------
resource "aws_bedrockagent_agent_alias" "this" {
  count = var.create_agent_alias ? 1 : 0

  agent_id         = aws_bedrockagent_agent.this.agent_id
  agent_alias_name = var.agent_alias_name
  description      = var.agent_alias_description

  tags = merge(
    local.common_tags,
    {
      Name = var.agent_alias_name
    }
  )

  depends_on = [
    aws_bedrockagent_agent_action_group.this,
    aws_bedrockagent_agent_knowledge_base_association.this
  ]
}

# -----------------------------------------------------------------------------
# Prepare Agent (prepares the DRAFT version)
# Note: This is done automatically, but explicit preparation ensures
# the agent is ready before creating aliases
# -----------------------------------------------------------------------------
resource "terraform_data" "prepare_agent" {
  triggers_replace = {
    agent_id        = aws_bedrockagent_agent.this.agent_id
    instruction     = var.instruction
    action_groups   = jsonencode(var.action_groups)
    knowledge_bases = jsonencode(var.knowledge_base_ids)
  }

  depends_on = [
    aws_bedrockagent_agent.this,
    aws_bedrockagent_agent_action_group.this,
    aws_bedrockagent_agent_knowledge_base_association.this
  ]
}
