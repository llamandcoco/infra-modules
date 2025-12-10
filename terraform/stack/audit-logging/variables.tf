variable "trail_name" {
  description = "Name of the CloudTrail trail."
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs. Must be globally unique."
  type        = string
}

variable "is_multi_region_trail" {
  description = "Whether the trail is created in all regions. Recommended for complete visibility."
  type        = bool
  default     = true
}

variable "include_global_service_events" {
  description = "Whether to include global service events (IAM, STS, CloudFront, etc.)."
  type        = bool
  default     = true
}

variable "enable_log_file_validation" {
  description = "Enable log file integrity validation (recommended for security)."
  type        = bool
  default     = true
}

variable "is_organization_trail" {
  description = "Whether the trail is an organization trail. Requires AWS Organizations."
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "KMS key ARN for encrypting CloudTrail logs and S3 bucket. If null, uses S3-managed encryption (SSE-S3)."
  type        = string
  default     = null
}

variable "cloudwatch_logs_group_arn" {
  description = "CloudWatch Logs group ARN for real-time log analysis. Leave null to disable (cost optimization)."
  type        = string
  default     = null
}

variable "read_write_type" {
  description = "Type of events to log: All, ReadOnly, or WriteOnly."
  type        = string
  default     = "All"

  validation {
    condition     = contains(["All", "ReadOnly", "WriteOnly"], var.read_write_type)
    error_message = "read_write_type must be one of: All, ReadOnly, WriteOnly."
  }
}

variable "exclude_management_event_sources" {
  description = "List of management event sources to exclude (e.g., kms.amazonaws.com, rdsdata.amazonaws.com)."
  type        = list(string)
  default     = []
}

variable "advanced_event_selectors" {
  description = "Advanced event selectors for granular control over logged events."
  type = list(object({
    name = string
    field_selectors = list(object({
      field           = string
      equals          = optional(list(string))
      not_equals      = optional(list(string))
      starts_with     = optional(list(string))
      not_starts_with = optional(list(string))
      ends_with       = optional(list(string))
      not_ends_with   = optional(list(string))
    }))
  }))
  default = []
}

variable "enable_insights" {
  description = "Enable CloudTrail Insights for anomaly detection. Additional cost: $0.35 per 100k write events."
  type        = bool
  default     = false
}

variable "enable_lifecycle_policy" {
  description = "Enable S3 lifecycle policy to archive and delete old logs (cost optimization)."
  type        = bool
  default     = true
}

variable "glacier_transition_days" {
  description = "Number of days after which logs are transitioned to Glacier."
  type        = number
  default     = 90

  validation {
    condition     = var.glacier_transition_days >= 0
    error_message = "glacier_transition_days must be >= 0."
  }
}

variable "log_retention_days" {
  description = "Number of days to retain logs before deletion. Set to 0 to disable expiration."
  type        = number
  default     = 365

  validation {
    condition     = var.log_retention_days >= 0
    error_message = "log_retention_days must be >= 0."
  }
}

variable "force_destroy" {
  description = "Allow deletion of S3 bucket even if it contains logs. Use with caution."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
