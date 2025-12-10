variable "trail_name" {
  description = "Name of the CloudTrail trail."
  type        = string
}

variable "s3_bucket_id" {
  description = "ID of the existing S3 bucket for CloudTrail logs."
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the existing S3 bucket for CloudTrail logs."
  type        = string
}

variable "create_s3_bucket_policy" {
  description = "Whether to create the S3 bucket policy for CloudTrail. Set to false if managing the policy externally."
  type        = bool
  default     = true
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
  description = "KMS key ARN for encrypting CloudTrail logs. If null, uses S3-managed encryption (SSE-S3)."
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


variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
