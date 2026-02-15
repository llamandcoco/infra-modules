# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "application_name" {
  description = "The name of the CodeDeploy application."
  type        = string

  validation {
    condition     = length(var.application_name) >= 1 && length(var.application_name) <= 100
    error_message = "Application name must be between 1 and 100 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.application_name))
    error_message = "Application name can only contain letters, numbers, hyphens, and underscores."
  }
}

variable "deployment_group_name" {
  description = "The name of the deployment group."
  type        = string

  validation {
    condition     = length(var.deployment_group_name) >= 1 && length(var.deployment_group_name) <= 100
    error_message = "Deployment group name must be between 1 and 100 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.deployment_group_name))
    error_message = "Deployment group name can only contain letters, numbers, hyphens, and underscores."
  }
}

# -----------------------------------------------------------------------------
# Compute Platform
# -----------------------------------------------------------------------------

variable "compute_platform" {
  description = <<-EOT
    The compute platform on which CodeDeploy deploys the application.
    Valid values: Server (EC2/On-Premises), Lambda, ECS.
  EOT
  type        = string
  default     = "Server"

  validation {
    condition     = contains(["Server", "Lambda", "ECS"], var.compute_platform)
    error_message = "Compute platform must be one of: Server, Lambda, ECS."
  }
}

# -----------------------------------------------------------------------------
# Service Role
# -----------------------------------------------------------------------------

variable "create_service_role" {
  description = "Whether to create a new IAM service role for CodeDeploy. If false, service_role_arn must be provided."
  type        = bool
  default     = true
}

variable "service_role_arn" {
  description = "ARN of an existing IAM role for CodeDeploy. Required when create_service_role is false."
  type        = string
  default     = null

  validation {
    condition     = var.service_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.service_role_arn))
    error_message = "Service role ARN must be a valid IAM role ARN."
  }
}

# -----------------------------------------------------------------------------
# Deployment Configuration
# -----------------------------------------------------------------------------

variable "deployment_config_name" {
  description = <<-EOT
    The name of the deployment configuration.
    For EC2/On-Premises: CodeDeployDefault.OneAtATime, CodeDeployDefault.HalfAtATime, CodeDeployDefault.AllAtOnce
    For Lambda: CodeDeployDefault.LambdaCanary10Percent5Minutes, CodeDeployDefault.LambdaLinear10PercentEvery1Minute, CodeDeployDefault.LambdaAllAtOnce
    For ECS: CodeDeployDefault.ECSAllAtOnce, CodeDeployDefault.ECSLinear10PercentEvery1Minutes, CodeDeployDefault.ECSCanary10Percent5Minutes
  EOT
  type        = string
  default     = "CodeDeployDefault.OneAtATime"
}

variable "deployment_type" {
  description = "Deployment type for Lambda deployments. Valid values: BLUE_GREEN, IN_PLACE."
  type        = string
  default     = "BLUE_GREEN"

  validation {
    condition     = contains(["BLUE_GREEN", "IN_PLACE"], var.deployment_type)
    error_message = "Deployment type must be either BLUE_GREEN or IN_PLACE."
  }
}

# -----------------------------------------------------------------------------
# EC2/On-Premises Configuration
# -----------------------------------------------------------------------------

variable "ec2_tag_filters" {
  description = <<-EOT
    List of EC2 tag filters to identify instances for deployment.
    Each filter should have: key, type (KEY_ONLY, VALUE_ONLY, KEY_AND_VALUE), and value.
  EOT
  type = list(object({
    key   = string
    type  = string
    value = string
  }))
  default = []
}

variable "autoscaling_groups" {
  description = "List of Auto Scaling Group names to deploy to."
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# ECS Configuration
# -----------------------------------------------------------------------------

variable "ecs_service" {
  description = "ECS service configuration for ECS deployments."
  type = object({
    cluster_name = string
    service_name = string
  })
  default = null
}

# -----------------------------------------------------------------------------
# Blue/Green Deployment Configuration
# -----------------------------------------------------------------------------

variable "blue_green_deployment_config" {
  description = "Blue/Green deployment configuration for EC2/On-Premises or ECS deployments."
  type = object({
    terminate_blue_instances_action  = string
    termination_wait_time_in_minutes = number
    deployment_ready_action          = string
    green_fleet_provisioning_action  = string
  })
  default = null
}

# -----------------------------------------------------------------------------
# Load Balancer Configuration
# -----------------------------------------------------------------------------

variable "load_balancer_info" {
  description = "Load balancer configuration for deployment group."
  type = object({
    target_group_names = list(string)
    elb_names          = list(string)
  })
  default = null
}

# -----------------------------------------------------------------------------
# Auto Rollback Configuration
# -----------------------------------------------------------------------------

variable "auto_rollback_enabled" {
  description = "Enable automatic rollback on deployment failure or alarm threshold breach."
  type        = bool
  default     = false
}

variable "auto_rollback_events" {
  description = "List of events that can trigger automatic rollback. Valid values: DEPLOYMENT_FAILURE, DEPLOYMENT_STOP_ON_ALARM, DEPLOYMENT_STOP_ON_REQUEST."
  type        = list(string)
  default     = ["DEPLOYMENT_FAILURE"]

  validation {
    condition = alltrue([
      for event in var.auto_rollback_events :
      contains(["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM", "DEPLOYMENT_STOP_ON_REQUEST"], event)
    ])
    error_message = "Auto rollback events must be one of: DEPLOYMENT_FAILURE, DEPLOYMENT_STOP_ON_ALARM, DEPLOYMENT_STOP_ON_REQUEST."
  }
}

# -----------------------------------------------------------------------------
# CloudWatch Alarm Configuration
# -----------------------------------------------------------------------------

variable "alarm_names" {
  description = "List of CloudWatch alarm names to monitor during deployment."
  type        = list(string)
  default     = []
}

variable "ignore_poll_alarm_failure" {
  description = "Whether to ignore failures in polling CloudWatch alarms."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Trigger Configuration
# -----------------------------------------------------------------------------

variable "trigger_configurations" {
  description = <<-EOT
    List of trigger configurations for deployment notifications.
    Each trigger should have: trigger_name, trigger_events (list), and trigger_target_arn (SNS topic ARN).
  EOT
  type = list(object({
    trigger_name       = string
    trigger_events     = list(string)
    trigger_target_arn = string
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
