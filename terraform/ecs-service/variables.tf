# -----------------------------------------------------------------------------
# ECS Service Variables
# -----------------------------------------------------------------------------

variable "cluster_id" {
  description = "ID of the ECS cluster where the service will be deployed"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.service_name)) && length(var.service_name) <= 255
    error_message = "Service name must start with a letter, contain only alphanumeric characters and hyphens, and be up to 255 characters long."
  }
}

# -----------------------------------------------------------------------------
# Container Variables
# -----------------------------------------------------------------------------

variable "container_name" {
  description = "Name of the container (defaults to service_name if not provided)"
  type        = string
  default     = null
}

variable "container_image" {
  description = "Docker image to run in the container (e.g., nginx:latest or ECR URI)"
  type        = string
}

variable "container_port" {
  description = "Port number the container listens on"
  type        = number

  validation {
    condition     = var.container_port > 0 && var.container_port <= 65535
    error_message = "Container port must be between 1 and 65535."
  }
}

variable "environment_variables" {
  description = "Environment variables to pass to the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "container_health_check" {
  description = "Container-level health check configuration"
  type = object({
    command      = list(string)
    interval     = number
    timeout      = number
    retries      = number
    start_period = number
  })
  default = null
}

# -----------------------------------------------------------------------------
# Fargate Sizing Variables
# -----------------------------------------------------------------------------

variable "cpu" {
  description = "Fargate task CPU units (256, 512, 1024, 2048, 4096). See AWS docs for valid CPU/memory combinations"
  type        = string
  default     = "256"

  validation {
    condition     = contains(["256", "512", "1024", "2048", "4096"], var.cpu)
    error_message = "CPU must be one of: 256, 512, 1024, 2048, 4096."
  }
}

variable "memory" {
  description = "Fargate task memory in MB. Must be valid for the selected CPU. See AWS docs for valid combinations"
  type        = string
  default     = "512"
}

# -----------------------------------------------------------------------------
# Networking Variables
# -----------------------------------------------------------------------------

variable "subnet_ids" {
  description = "List of subnet IDs for ECS tasks (typically private subnets)"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 1
    error_message = "At least one subnet must be provided."
  }
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to ECS tasks"
  type        = list(string)

  validation {
    condition     = length(var.security_group_ids) >= 1
    error_message = "At least one security group must be provided."
  }
}

variable "assign_public_ip" {
  description = "Assign a public IP address to ECS tasks. Required for tasks in public subnets without NAT"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Load Balancer Variables
# -----------------------------------------------------------------------------

variable "target_group_arn" {
  description = "ARN of the ALB target group to attach to the ECS service"
  type        = string
}

variable "health_check_grace_period" {
  description = "Seconds to wait before starting health checks after task starts"
  type        = number
  default     = 60
}

# -----------------------------------------------------------------------------
# IAM Variables
# -----------------------------------------------------------------------------

variable "execution_role_arn" {
  description = "ARN of the IAM role for ECS task execution (required for pulling images from ECR, writing logs)"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the IAM role for ECS tasks (optional, for AWS API access from within containers)"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Service Configuration Variables
# -----------------------------------------------------------------------------

variable "desired_count" {
  description = "Desired number of tasks to run"
  type        = number
  default     = 1

  validation {
    condition     = var.desired_count >= 0
    error_message = "Desired count must be non-negative."
  }
}

variable "deployment_maximum_percent" {
  description = "Maximum percentage of tasks to run during deployment (100-200)"
  type        = number
  default     = 200

  validation {
    condition     = var.deployment_maximum_percent >= 100 && var.deployment_maximum_percent <= 200
    error_message = "Deployment maximum percent must be between 100 and 200."
  }
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum percentage of healthy tasks during deployment (0-100)"
  type        = number
  default     = 100

  validation {
    condition     = var.deployment_minimum_healthy_percent >= 0 && var.deployment_minimum_healthy_percent <= 100
    error_message = "Deployment minimum healthy percent must be between 0 and 100."
  }
}

variable "enable_ecs_exec" {
  description = "Enable ECS Exec for debugging (requires IAM permissions)"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Auto Scaling Variables
# -----------------------------------------------------------------------------

variable "min_capacity" {
  description = "Minimum number of tasks for auto-scaling"
  type        = number
  default     = 1

  validation {
    condition     = var.min_capacity >= 0
    error_message = "Minimum capacity must be non-negative."
  }
}

variable "max_capacity" {
  description = "Maximum number of tasks for auto-scaling"
  type        = number
  default     = 10

  validation {
    condition     = var.max_capacity >= 1
    error_message = "Maximum capacity must be at least 1."
  }
}

variable "enable_cpu_scaling" {
  description = "Enable CPU-based auto-scaling"
  type        = bool
  default     = true
}

variable "target_cpu_utilization" {
  description = "Target CPU utilization percentage for auto-scaling"
  type        = number
  default     = 60

  validation {
    condition     = var.target_cpu_utilization > 0 && var.target_cpu_utilization <= 100
    error_message = "Target CPU utilization must be between 1 and 100."
  }
}

variable "enable_memory_scaling" {
  description = "Enable memory-based auto-scaling"
  type        = bool
  default     = false
}

variable "target_memory_utilization" {
  description = "Target memory utilization percentage for auto-scaling"
  type        = number
  default     = 80

  validation {
    condition     = var.target_memory_utilization > 0 && var.target_memory_utilization <= 100
    error_message = "Target memory utilization must be between 1 and 100."
  }
}

variable "enable_alb_scaling" {
  description = "Enable ALB request count-based auto-scaling"
  type        = bool
  default     = false
}

variable "target_request_count_per_target" {
  description = "Target number of ALB requests per task for auto-scaling"
  type        = number
  default     = 100

  validation {
    condition     = var.target_request_count_per_target > 0
    error_message = "Target request count per target must be positive."
  }
}

variable "alb_resource_label" {
  description = "ALB resource label for request count scaling. Format: app/<alb-name>/<id>/targetgroup/<tg-name>/<id>"
  type        = string
  default     = null
}

variable "scale_in_cooldown" {
  description = "Cooldown period (in seconds) after a scale-in activity"
  type        = number
  default     = 300

  validation {
    condition     = var.scale_in_cooldown >= 0
    error_message = "Scale-in cooldown must be non-negative."
  }
}

variable "scale_out_cooldown" {
  description = "Cooldown period (in seconds) after a scale-out activity"
  type        = number
  default     = 60

  validation {
    condition     = var.scale_out_cooldown >= 0
    error_message = "Scale-out cooldown must be non-negative."
  }
}

# -----------------------------------------------------------------------------
# CloudWatch Logs Variables
# -----------------------------------------------------------------------------

variable "log_retention_days" {
  description = "CloudWatch Logs retention period in days"
  type        = number
  default     = 7

  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch Logs retention period."
  }
}

# -----------------------------------------------------------------------------
# Tags Variable
# -----------------------------------------------------------------------------

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
