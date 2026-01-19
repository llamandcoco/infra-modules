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

variable "enable_ssm_session_manager" {
  description = "Attach SSM Session Manager permissions (for interactive sessions)"
  type        = bool
  default     = false
}

variable "s3_log_buckets" {
  description = "S3 bucket ARNs for log storage (session logs, CloudWatch logs export)"
  type        = list(string)
  default     = []
}

variable "kms_key_arns" {
  description = "KMS key ARNs for decryption (ECR images, SSM parameters, S3 objects)"
  type        = list(string)
  default     = []
}

variable "additional_policy_arns" {
  description = "Additional managed IAM policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "custom_policy_statements" {
  description = "Custom IAM policy statements to attach as inline policies"
  type = list(object({
    sid       = optional(string)
    actions   = list(string)
    resources = list(string)
    effect    = optional(string, "Allow")
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
