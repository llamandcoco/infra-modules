# -----------------------------------------------------------------------------
# ECS Cluster Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the ECS cluster"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.name)) && length(var.name) <= 255
    error_message = "Cluster name must start with a letter, contain only alphanumeric characters and hyphens, and be up to 255 characters long."
  }
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights for the cluster"
  type        = bool
  default     = true
}

variable "capacity_providers" {
  description = "List of capacity providers to associate with the cluster (e.g., FARGATE, FARGATE_SPOT)"
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "default_capacity_provider_strategy" {
  description = "Default capacity provider strategy for the cluster"
  type = list(object({
    capacity_provider = string
    weight            = optional(number)
    base              = optional(number)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to the cluster"
  type        = map(string)
  default     = {}
}
