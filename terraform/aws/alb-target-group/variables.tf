# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the target group. Must be 1-32 characters, alphanumeric or hyphens."
  type        = string

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 32
    error_message = "Target group name must be between 1 and 32 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.name))
    error_message = "Target group name may contain only letters, numbers, and hyphens."
  }
}

variable "vpc_id" {
  description = "VPC ID where the target group will be created."
  type        = string

  validation {
    condition     = can(regex("^vpc-[a-z0-9]+$", var.vpc_id))
    error_message = "VPC ID must start with 'vpc-'."
  }
}

variable "port" {
  description = "Port for the target group."
  type        = number

  validation {
    condition     = var.port >= 1 && var.port <= 65535
    error_message = "Port must be between 1 and 65535."
  }
}

variable "protocol" {
  description = "Protocol for the target group (HTTP or HTTPS)."
  type        = string

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.protocol)
    error_message = "Protocol must be HTTP or HTTPS."
  }
}

variable "target_type" {
  description = "Target type for the target group (instance, ip, lambda, alb)."
  type        = string

  validation {
    condition     = contains(["instance", "ip", "lambda", "alb"], var.target_type)
    error_message = "Target type must be one of: instance, ip, lambda, alb."
  }
}

# -----------------------------------------------------------------------------
# Target Group Behavior
# -----------------------------------------------------------------------------

variable "deregistration_delay" {
  description = "Deregistration delay in seconds."
  type        = number
  default     = 300

  validation {
    condition     = var.deregistration_delay >= 0 && var.deregistration_delay <= 3600
    error_message = "deregistration_delay must be between 0 and 3600 seconds."
  }
}

variable "slow_start" {
  description = "Slow start duration in seconds (0 disables)."
  type        = number
  default     = 0

  validation {
    condition     = var.slow_start == 0 || (var.slow_start >= 30 && var.slow_start <= 900)
    error_message = "slow_start must be 0 (disabled) or between 30 and 900 seconds."
  }
}

# -----------------------------------------------------------------------------
# Health Check Configuration
# -----------------------------------------------------------------------------

variable "health_check" {
  description = "Health check configuration for the target group."
  type = object({
    enabled             = optional(bool)
    healthy_threshold   = optional(number)
    unhealthy_threshold = optional(number)
    timeout             = optional(number)
    interval            = optional(number)
    path                = optional(string)
    port                = optional(string)
    protocol            = optional(string)
    matcher             = optional(string)
  })
  default = {}
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "target_group_tags" {
  description = "Additional tags to apply to the target group only."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Optional Listener Rule
# -----------------------------------------------------------------------------

variable "listener_arn" {
  description = "Listener ARN to attach a listener rule. If null, no rule is created."
  type        = string
  default     = null
}

variable "listener_priority" {
  description = "Listener rule priority. Required when listener_arn is set."
  type        = number
  default     = null

  validation {
    condition     = var.listener_priority == null ? true : (var.listener_priority >= 1 && var.listener_priority <= 50000)
    error_message = "listener_priority must be between 1 and 50000."
  }
}

variable "listener_conditions" {
  description = "Listener rule conditions. Required when listener_arn is set."
  type = list(object({
    path_pattern = optional(object({
      values = list(string)
    }))

    host_header = optional(object({
      values = list(string)
    }))

    http_header = optional(object({
      http_header_name = string
      values           = list(string)
    }))

    http_request_method = optional(object({
      values = list(string)
    }))

    query_string = optional(object({
      key   = optional(string)
      value = string
    }))

    source_ip = optional(object({
      values = list(string)
    }))
  }))
  default = []
}
