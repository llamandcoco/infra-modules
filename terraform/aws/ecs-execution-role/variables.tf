# -----------------------------------------------------------------------------
# ECS Execution Role Variables
# This role is used by the ECS agent to pull images, send logs, etc.
# NOT to be confused with the task role used by container code.
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the ECS execution role"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-_]*$", var.name)) && length(var.name) <= 64
    error_message = "Role name must start with a letter, contain only alphanumeric characters, hyphens, and underscores, and be up to 64 characters long."
  }
}

variable "enable_ecr" {
  description = "Enable ECR read permissions for pulling container images"
  type        = bool
  default     = true
}

variable "enable_ssm" {
  description = "Enable SSM read permissions for parameter store access"
  type        = bool
  default     = false
}

variable "enable_cw_logs" {
  description = "Enable CloudWatch Logs permissions for container logging"
  type        = bool
  default     = true
}

variable "enable_cw_agent" {
  description = "Enable CloudWatch Agent permissions for custom metrics"
  type        = bool
  default     = false
}

variable "additional_policies" {
  description = "Map of additional IAM policy names to JSON policy documents"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to the IAM role"
  type        = map(string)
  default     = {}
}
