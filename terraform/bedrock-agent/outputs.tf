# -----------------------------------------------------------------------------
# Agent Outputs
# -----------------------------------------------------------------------------

output "agent_id" {
  description = "The unique identifier of the Bedrock agent. Use this for API calls and agent invocations."
  value       = aws_bedrockagent_agent.this.agent_id
}

output "agent_arn" {
  description = "The ARN of the Bedrock agent. Use this for IAM policies and cross-account access."
  value       = aws_bedrockagent_agent.this.agent_arn
}

output "agent_name" {
  description = "The name of the Bedrock agent."
  value       = aws_bedrockagent_agent.this.agent_name
}

output "agent_version" {
  description = "The version of the agent. DRAFT is the working version."
  value       = aws_bedrockagent_agent.this.agent_version
}

# -----------------------------------------------------------------------------
# Agent Alias Outputs
# -----------------------------------------------------------------------------

output "agent_alias_id" {
  description = "The ID of the agent alias. Use this for stable agent invocations."
  value       = var.create_agent_alias ? aws_bedrockagent_agent_alias.this[0].agent_alias_id : null
}

output "agent_alias_arn" {
  description = "The ARN of the agent alias."
  value       = var.create_agent_alias ? aws_bedrockagent_agent_alias.this[0].agent_alias_arn : null
}

output "agent_alias_name" {
  description = "The name of the agent alias."
  value       = var.create_agent_alias ? aws_bedrockagent_agent_alias.this[0].agent_alias_name : null
}

# -----------------------------------------------------------------------------
# IAM Role Outputs
# -----------------------------------------------------------------------------

output "agent_role_arn" {
  description = "The ARN of the IAM role used by the Bedrock agent."
  value       = aws_iam_role.agent.arn
}

output "agent_role_name" {
  description = "The name of the IAM role used by the Bedrock agent."
  value       = aws_iam_role.agent.name
}

output "agent_role_id" {
  description = "The unique ID of the IAM role."
  value       = aws_iam_role.agent.id
}

# -----------------------------------------------------------------------------
# Action Group Outputs
# -----------------------------------------------------------------------------

output "action_group_ids" {
  description = "Map of action group names to their IDs."
  value = {
    for ag_name, ag in aws_bedrockagent_agent_action_group.this :
    ag_name => ag.action_group_id
  }
}

output "action_group_count" {
  description = "Number of action groups configured for the agent."
  value       = length(aws_bedrockagent_agent_action_group.this)
}

# -----------------------------------------------------------------------------
# Knowledge Base Outputs
# -----------------------------------------------------------------------------

output "knowledge_base_associations" {
  description = "Map of knowledge base IDs to their association details."
  value = {
    for kb_id, kb in aws_bedrockagent_agent_knowledge_base_association.this :
    kb_id => {
      knowledge_base_id    = kb.knowledge_base_id
      knowledge_base_state = kb.knowledge_base_state
    }
  }
}

output "knowledge_base_count" {
  description = "Number of knowledge bases associated with the agent."
  value       = length(aws_bedrockagent_agent_knowledge_base_association.this)
}

# -----------------------------------------------------------------------------
# Configuration Outputs
# -----------------------------------------------------------------------------

output "foundation_model" {
  description = "The foundation model used by the agent."
  value       = aws_bedrockagent_agent.this.foundation_model
}

output "instruction" {
  description = "The instruction/system prompt for the agent."
  value       = aws_bedrockagent_agent.this.instruction
  sensitive   = true
}

output "idle_session_ttl" {
  description = "The idle session timeout in seconds."
  value       = aws_bedrockagent_agent.this.idle_session_ttl_in_seconds
}

# -----------------------------------------------------------------------------
# Region and Account Outputs
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Invocation Outputs
# -----------------------------------------------------------------------------

output "invoke_agent_cli_example" {
  description = "AWS CLI example command to invoke the agent."
  value = var.create_agent_alias ? (
    "aws bedrock-agent-runtime invoke-agent --agent-id ${aws_bedrockagent_agent.this.agent_id} --agent-alias-id ${aws_bedrockagent_agent_alias.this[0].agent_alias_id} --session-id $(uuidgen) --input-text 'Your prompt here' output.txt"
  ) : (
    "Create an agent alias first to invoke the agent"
  )
}

output "boto3_invoke_example" {
  description = "Python boto3 example code to invoke the agent."
  value = var.create_agent_alias ? <<-EOT
    import boto3
    import uuid

    bedrock_agent_runtime = boto3.client('bedrock-agent-runtime')

    response = bedrock_agent_runtime.invoke_agent(
        agentId='${aws_bedrockagent_agent.this.agent_id}',
        agentAliasId='${aws_bedrockagent_agent_alias.this[0].agent_alias_id}',
        sessionId=str(uuid.uuid4()),
        inputText='Your prompt here'
    )
  EOT
  : "Create an agent alias first to invoke the agent"
}
