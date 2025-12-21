# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "agent_name" {
  description = "Name of the Bedrock agent. This will be displayed in the AWS console and used in resource naming."
  type        = string

  validation {
    condition     = length(var.agent_name) > 0 && length(var.agent_name) <= 100
    error_message = "Agent name must be between 1 and 100 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.agent_name))
    error_message = "Agent name must contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "foundation_model" {
  description = "Foundation model identifier for the agent. Examples: 'anthropic.claude-3-5-sonnet-20241022-v2:0', 'anthropic.claude-3-opus-20240229-v1:0', 'anthropic.claude-3-haiku-20240307-v1:0'."
  type        = string

  validation {
    condition     = length(var.foundation_model) > 0
    error_message = "Foundation model must not be empty."
  }
}

variable "instruction" {
  description = "Instructions that tell the agent what it should do and how it should interact with users. This is the agent's system prompt."
  type        = string

  validation {
    condition     = length(var.instruction) > 0 && length(var.instruction) <= 4000
    error_message = "Instruction must be between 1 and 4000 characters."
  }
}

# -----------------------------------------------------------------------------
# Foundation Model Configuration
# -----------------------------------------------------------------------------

variable "foundation_model_arn" {
  description = "ARN of the foundation model. If not specified, it will be constructed from the foundation_model variable. Format: 'arn:aws:bedrock:<region>::foundation-model/<model-id>'."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Agent Configuration Variables
# -----------------------------------------------------------------------------

variable "description" {
  description = "Description of the Bedrock agent. Helps document the purpose and functionality."
  type        = string
  default     = null
}

variable "idle_session_ttl_in_seconds" {
  description = "Maximum time in seconds that an agent session can remain idle before it is ended. Valid range: 60-3600."
  type        = number
  default     = 600

  validation {
    condition     = var.idle_session_ttl_in_seconds >= 60 && var.idle_session_ttl_in_seconds <= 3600
    error_message = "Idle session TTL must be between 60 and 3600 seconds."
  }
}

variable "customer_encryption_key_arn" {
  description = "ARN of the AWS KMS key to encrypt the agent's data. If not specified, AWS managed keys are used."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# IAM Configuration Variables
# -----------------------------------------------------------------------------

variable "agent_role_name" {
  description = "Name of the IAM role for the Bedrock agent. If not specified, defaults to '<agent_name>-agent-role'."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Action Group Variables
# -----------------------------------------------------------------------------

variable "action_groups" {
  description = "List of action groups to attach to the agent. Each action group connects the agent to a Lambda function or API."
  type = list(object({
    name                    = string
    description             = optional(string)
    lambda_arn              = optional(string)
    grant_lambda_permission = optional(bool, true)
    api_schema_s3_bucket    = optional(string)
    api_schema_s3_key       = optional(string)
    api_schema_payload      = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for ag in var.action_groups :
      ag.lambda_arn != null || ag.api_schema_s3_bucket != null || ag.api_schema_payload != null
    ])
    error_message = "Each action group must have either lambda_arn, api_schema_s3_bucket, or api_schema_payload specified."
  }
}

variable "skip_resource_in_use_check" {
  description = "Whether to skip the resource in use check when deleting action groups. Set to true to force deletion."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Knowledge Base Variables
# -----------------------------------------------------------------------------

variable "knowledge_base_ids" {
  description = "List of knowledge base IDs to associate with the agent. These enable RAG (Retrieval-Augmented Generation) capabilities."
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Agent Alias Variables
# -----------------------------------------------------------------------------

variable "create_agent_alias" {
  description = "Whether to create an agent alias. Aliases provide stable endpoints for different versions of the agent."
  type        = bool
  default     = true
}

variable "agent_alias_name" {
  description = "Name of the agent alias. Required if create_agent_alias is true."
  type        = string
  default     = "production"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.agent_alias_name))
    error_message = "Agent alias name must contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "agent_alias_description" {
  description = "Description of the agent alias."
  type        = string
  default     = "Production alias for the agent"
}

# -----------------------------------------------------------------------------
# Prompt Override Configuration
# Advanced configuration for customizing agent prompts and inference
# -----------------------------------------------------------------------------

variable "prompt_override_configuration" {
  description = "Optional advanced configuration for overriding default prompts and inference parameters."
  type = object({
    orchestration_prompt_template = string
    temperature                   = optional(number, 0.7)
    top_p                         = optional(number, 0.9)
    top_k                         = optional(number, 250)
    max_length                    = optional(number, 2048)
    stop_sequences                = optional(list(string), [])
  })
  default = null

  validation {
    condition = var.prompt_override_configuration == null || (
      var.prompt_override_configuration.temperature >= 0 &&
      var.prompt_override_configuration.temperature <= 1
    )
    error_message = "Temperature must be between 0 and 1."
  }

  validation {
    condition = var.prompt_override_configuration == null || (
      var.prompt_override_configuration.top_p >= 0 &&
      var.prompt_override_configuration.top_p <= 1
    )
    error_message = "Top_p must be between 0 and 1."
  }
}

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to all resources. Use this for cost allocation, resource organization, and governance."
  type        = map(string)
  default     = {}
}
