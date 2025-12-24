# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "function_name" {
  description = "Name of the Lambda function. This will be displayed in the AWS console and used in resource naming."
  type        = string

  validation {
    condition     = length(var.function_name) > 0 && length(var.function_name) <= 64
    error_message = "Function name must be between 1 and 64 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.function_name))
    error_message = "Function name must contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "runtime" {
  description = "Runtime environment for the Lambda function. Supported runtimes: python3.11, python3.12, nodejs18.x, nodejs20.x, provided.al2023, provided.al2."
  type        = string

  validation {
    condition = contains([
      "python3.11",
      "python3.12",
      "nodejs18.x",
      "nodejs20.x",
      "provided.al2023",
      "provided.al2"
    ], var.runtime)
    error_message = "Runtime must be one of: python3.11, python3.12, nodejs18.x, nodejs20.x, provided.al2023, provided.al2."
  }
}

variable "handler" {
  description = "Function entrypoint in your code. Format varies by runtime: Python: 'module.function_name' (e.g., 'lambda_function.handler'), Node.js: 'file.function_name' (e.g., 'index.handler' or 'dist/index.handler'), Go: 'bootstrap' (the binary name)."
  type        = string

  validation {
    condition     = length(var.handler) > 0
    error_message = "Handler must not be empty."
  }
}

# -----------------------------------------------------------------------------
# Deployment Method Variables (One Required)
# -----------------------------------------------------------------------------

variable "s3_bucket" {
  description = "S3 bucket containing the Lambda deployment package. Use for production deployments via CI/CD. Required if using S3 deployment method."
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 object key of the Lambda deployment package. Required if using S3 deployment method."
  type        = string
  default     = null
}

variable "s3_object_version" {
  description = "Version of the S3 object. Optional. Use for S3 versioned buckets to ensure specific package version deployment."
  type        = string
  default     = null
}

variable "filename" {
  description = "Path to the local Lambda deployment package zip file. Use for development and testing. Required if using local deployment method."
  type        = string
  default     = null
}

variable "source_code_hash" {
  description = "Base64-encoded SHA256 hash of the deployment package. Used to trigger redeployment when code changes. Optional but recommended for local deployment."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Lambda Configuration Variables
# -----------------------------------------------------------------------------

variable "timeout" {
  description = "Maximum execution time in seconds. Lambda functions are terminated if they run longer than this value."
  type        = number
  default     = 30

  validation {
    condition     = var.timeout >= 1 && var.timeout <= 900
    error_message = "Timeout must be between 1 and 900 seconds."
  }
}

variable "memory_size" {
  description = "Amount of memory in MB available to the Lambda function at runtime. CPU allocation scales with memory."
  type        = number
  default     = 128

  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "Memory size must be between 128 and 10240 MB."
  }
}

variable "environment_variables" {
  description = "Map of environment variables to pass to the Lambda function. These are encrypted at rest using AWS managed keys by default."
  type        = map(string)
  default     = {}
}

variable "description" {
  description = "Description of the Lambda function. Helps document the purpose and functionality."
  type        = string
  default     = null
}

variable "reserved_concurrent_executions" {
  description = "Number of concurrent executions reserved for this function. Set to -1 for unreserved (default). Use positive values to guarantee capacity."
  type        = number
  default     = -1

  validation {
    condition     = var.reserved_concurrent_executions == -1 || var.reserved_concurrent_executions >= 0
    error_message = "Reserved concurrent executions must be -1 (unreserved) or a non-negative number."
  }
}

# -----------------------------------------------------------------------------
# IAM Configuration Variables
# -----------------------------------------------------------------------------

variable "additional_policy_arns" {
  description = "List of IAM policy ARNs to attach to the Lambda execution role. Use for granting additional permissions (e.g., DynamoDB, S3, SQS access)."
  type        = list(string)
  default     = []
}

variable "policy_statements" {
  description = "List of IAM policy statements to attach as inline policies to the Lambda execution role. Each statement defines permissions for specific actions on resources."
  type = list(object({
    effect    = string
    actions   = list(string)
    resources = list(string)
    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for statement in var.policy_statements :
      contains(["Allow", "Deny"], statement.effect)
    ])
    error_message = "Effect must be either 'Allow' or 'Deny'."
  }
}

variable "create_cloudwatch_log_policy" {
  description = "Whether to create and attach an IAM policy for CloudWatch Logs. Recommended for production to enable logging."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# CloudWatch Logs Variables
# -----------------------------------------------------------------------------

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs. Common values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653."
  type        = number
  default     = 7

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days must be one of: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653."
  }
}

# -----------------------------------------------------------------------------
# Event Source Mapping Variables
# -----------------------------------------------------------------------------

variable "event_source_mappings" {
  description = "List of event source mappings to configure for the Lambda function. Supports SQS, Kinesis, DynamoDB Streams, MSK, and other event sources."
  type = list(object({
    event_source_arn                   = string
    enabled                            = optional(bool, true)
    batch_size                         = optional(number, 10)
    starting_position                  = optional(string, null) # Required for Kinesis and DynamoDB Streams: LATEST, TRIM_HORIZON, or AT_TIMESTAMP
    starting_position_timestamp        = optional(string, null)
    maximum_batching_window_in_seconds = optional(number, 0)
    maximum_record_age_in_seconds      = optional(number, null)       # For Kinesis and DynamoDB Streams
    maximum_retry_attempts             = optional(number, null)       # For Kinesis and DynamoDB Streams
    parallelization_factor             = optional(number, null)       # For Kinesis and DynamoDB Streams
    bisect_batch_on_function_error     = optional(bool, null)         # For Kinesis and DynamoDB Streams
    tumbling_window_in_seconds         = optional(number, null)       # For Kinesis and DynamoDB Streams
    function_response_types            = optional(list(string), null) # For Kinesis and DynamoDB Streams: ["ReportBatchItemFailures"]

    # SQS-specific configurations
    scaling_config = optional(object({
      maximum_concurrency = number
    }), null)

    # Filtering
    filter_criteria = optional(object({
      filters = list(object({
        pattern = string
      }))
    }), null)

    # Destination configuration for failure handling
    destination_config = optional(object({
      on_failure = optional(object({
        destination_arn = string
      }), null)
    }), null)
  }))
  default = []

  validation {
    condition = alltrue([
      for mapping in var.event_source_mappings :
      mapping.batch_size >= 1 && mapping.batch_size <= 10000
    ])
    error_message = "Batch size must be between 1 and 10000."
  }

  validation {
    condition = alltrue([
      for mapping in var.event_source_mappings :
      mapping.starting_position == null || contains(["LATEST", "TRIM_HORIZON", "AT_TIMESTAMP"], mapping.starting_position)
    ])
    error_message = "Starting position must be one of: LATEST, TRIM_HORIZON, AT_TIMESTAMP."
  }
}

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to all resources. Use this for cost allocation, resource organization, and governance."
  type        = map(string)
  default     = {}
}
