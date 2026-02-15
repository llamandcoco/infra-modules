variable "name" {
  description = "Name of the IAM group"
  type        = string
}

variable "path" {
  description = "Path for the IAM group"
  type        = string
  default     = "/"
}

variable "users" {
  description = "List of IAM users to add to the group"
  type        = list(string)
  default     = []
}

variable "enable_s3_read" {
  description = "Attach S3 read permissions"
  type        = bool
  default     = false
}

variable "enable_s3_write" {
  description = "Attach S3 write permissions"
  type        = bool
  default     = false
}

variable "enable_ec2_read" {
  description = "Attach EC2 read-only permissions"
  type        = bool
  default     = false
}

variable "enable_dynamodb_read" {
  description = "Attach DynamoDB read permissions"
  type        = bool
  default     = false
}

variable "enable_dynamodb_write" {
  description = "Attach DynamoDB write permissions"
  type        = bool
  default     = false
}

variable "enable_logs_read" {
  description = "Attach CloudWatch Logs read permissions"
  type        = bool
  default     = false
}

variable "enable_ssm_read" {
  description = "Attach SSM Parameter Store read permissions"
  type        = bool
  default     = false
}

variable "managed_policy_arns" {
  description = "List of managed IAM policy ARNs to attach to the group"
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
