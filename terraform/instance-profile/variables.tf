variable "name" {
  description = "Name prefix for role and instance profile"
  type        = string
}

variable "enable_ecr" {
  description = "Attach ECR pull permissions"
  type        = bool
  default     = true
}

variable "enable_ssm" {
  description = "Attach SSM GetParameter permissions"
  type        = bool
  default     = true
}

variable "enable_cw_logs" {
  description = "Attach CloudWatch Logs permissions"
  type        = bool
  default     = true
}

variable "enable_cw_agent" {
  description = "Attach CloudWatch Agent permissions (required for memory/disk metrics)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
