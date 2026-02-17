# -----------------------------------------------------------------------------
# Model Invocation Logging Variables
# -----------------------------------------------------------------------------

variable "enable_model_invocation_logging" {
  description = "Enable logging of Bedrock model invocations to CloudWatch and/or S3. Useful for auditing, debugging, and monitoring model usage."
  type        = bool
  default     = false
}

variable "log_group_name" {
  description = "Name of the CloudWatch log group for Bedrock model invocation logs. If not specified, defaults to '/aws/bedrock/modelinvocations'."
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs for Bedrock model invocations. Common values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653."
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days must be one of: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653."
  }
}

variable "logging_role_name" {
  description = "Name of the IAM role for Bedrock to write logs to CloudWatch. If not specified, defaults to 'bedrock-model-invocation-logging-role'."
  type        = string
  default     = null
}

variable "log_text_data" {
  description = "Whether to log text input/output data from model invocations. Enable for debugging prompts and responses."
  type        = bool
  default     = true
}

variable "log_image_data" {
  description = "Whether to log image input/output data from model invocations. Enable for debugging image-based models."
  type        = bool
  default     = false
}

variable "log_embedding_data" {
  description = "Whether to log embedding data from model invocations. Enable for debugging embedding models."
  type        = bool
  default     = false
}

variable "s3_logging_bucket" {
  description = "Optional S3 bucket name for storing Bedrock model invocation logs. Use for long-term log archival or compliance requirements."
  type        = string
  default     = null
}

variable "s3_logging_key_prefix" {
  description = "Optional S3 key prefix for Bedrock model invocation logs. Used when s3_logging_bucket is specified."
  type        = string
  default     = "bedrock-logs/"
}

# -----------------------------------------------------------------------------
# Service Role Variables
# -----------------------------------------------------------------------------

variable "create_service_role" {
  description = "Whether to create an IAM role for AWS services (Lambda, ECS, EC2, etc.) to invoke Bedrock models. Set to true if you need services to call Bedrock."
  type        = bool
  default     = false
}

variable "service_role_name" {
  description = "Name of the IAM role for services to invoke Bedrock models. Required if create_service_role is true."
  type        = string
  default     = "bedrock-service-role"
}

variable "service_principals" {
  description = "List of AWS service principals that can assume the Bedrock service role. Common values: ['lambda.amazonaws.com', 'ecs-tasks.amazonaws.com', 'ec2.amazonaws.com']."
  type        = list(string)
  default     = ["lambda.amazonaws.com"]

  validation {
    condition     = length(var.service_principals) > 0
    error_message = "At least one service principal must be specified."
  }
}

variable "allowed_model_arns" {
  description = "List of Bedrock model ARNs that the service role can invoke. Use wildcards for flexibility (e.g., 'arn:aws:bedrock:*:*:foundation-model/*' for all models). Common model IDs: anthropic.claude-3-5-sonnet-20241022-v2:0, anthropic.claude-3-opus-20240229, meta.llama3-1-70b-instruct-v1:0."
  type        = list(string)
  default     = ["arn:aws:bedrock:*::foundation-model/*"]
}

variable "additional_service_policy_arns" {
  description = "List of additional IAM policy ARNs to attach to the Bedrock service role. Use for granting access to S3, DynamoDB, or other AWS services."
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to all resources. Use this for cost allocation, resource organization, and governance."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# AWS Environment Variables (for CI/CD and testing)
# -----------------------------------------------------------------------------

variable "aws_account_id" {
  description = "AWS Account ID. If not provided, will be detected automatically using AWS API. Set this to a dummy value (e.g., '123456789012') for CI/CD testing without credentials."
  type        = string
  default     = null
}

variable "aws_region" {
  description = "AWS Region. If not provided, will be detected automatically using AWS API. Set this to a dummy value (e.g., 'us-east-1') for CI/CD testing without credentials."
  type        = string
  default     = null
}
