# -----------------------------------------------------------------------------
# ECS Task Role Variables
# This role is used by your container code to access AWS services.
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the ECS task role"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-_]*$", var.name)) && length(var.name) <= 64
    error_message = "Role name must start with a letter, contain only alphanumeric characters, hyphens, and underscores, and be up to 64 characters long."
  }
}

# -----------------------------------------------------------------------------
# Policy Attachments
# -----------------------------------------------------------------------------

variable "managed_policy_arns" {
  description = "List of AWS managed policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Map of inline policy names to JSON policy documents"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# S3 Access
# -----------------------------------------------------------------------------

variable "enable_s3_access" {
  description = "Enable S3 access permissions"
  type        = bool
  default     = false
}

variable "s3_bucket_arns" {
  description = "List of S3 bucket ARNs to grant access to"
  type        = list(string)
  default     = []
}

variable "s3_actions" {
  description = "List of S3 actions to allow"
  type        = list(string)
  default = [
    "s3:GetObject",
    "s3:PutObject",
    "s3:DeleteObject",
    "s3:ListBucket"
  ]
}

# -----------------------------------------------------------------------------
# DynamoDB Access
# -----------------------------------------------------------------------------

variable "enable_dynamodb_access" {
  description = "Enable DynamoDB access permissions"
  type        = bool
  default     = false
}

variable "dynamodb_table_arns" {
  description = "List of DynamoDB table ARNs to grant access to"
  type        = list(string)
  default     = []
}

variable "dynamodb_actions" {
  description = "List of DynamoDB actions to allow"
  type        = list(string)
  default = [
    "dynamodb:GetItem",
    "dynamodb:PutItem",
    "dynamodb:UpdateItem",
    "dynamodb:DeleteItem",
    "dynamodb:Query",
    "dynamodb:Scan"
  ]
}

# -----------------------------------------------------------------------------
# SQS Access
# -----------------------------------------------------------------------------

variable "enable_sqs_access" {
  description = "Enable SQS access permissions"
  type        = bool
  default     = false
}

variable "sqs_queue_arns" {
  description = "List of SQS queue ARNs to grant access to"
  type        = list(string)
  default     = []
}

variable "sqs_actions" {
  description = "List of SQS actions to allow"
  type        = list(string)
  default = [
    "sqs:SendMessage",
    "sqs:ReceiveMessage",
    "sqs:DeleteMessage",
    "sqs:GetQueueAttributes"
  ]
}

# -----------------------------------------------------------------------------
# Secrets Manager Access
# -----------------------------------------------------------------------------

variable "enable_secrets_manager" {
  description = "Enable Secrets Manager access permissions"
  type        = bool
  default     = false
}

variable "secret_arns" {
  description = "List of Secrets Manager secret ARNs to grant access to"
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "tags" {
  description = "Tags to apply to the IAM role"
  type        = map(string)
  default     = {}
}
