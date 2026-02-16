# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "configuration_name" {
  description = <<-EOT
    Name of the Amazon MQ RabbitMQ configuration.
    Must be unique within the AWS account and region.
  EOT
  type        = string

  validation {
    condition     = length(var.configuration_name) > 0 && length(var.configuration_name) <= 150
    error_message = "Configuration name must be between 1 and 150 characters long."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9._~-]+$", var.configuration_name))
    error_message = "Configuration name must only contain alphanumeric characters, periods, hyphens, underscores, and tildes."
  }
}

variable "engine_version" {
  description = <<-EOT
    The version of the RabbitMQ broker engine.
    
    Use major.minor format (for example: 3.13).
    
    Refer to AWS documentation for the latest supported versions:
    https://docs.aws.amazon.com/amazon-mq/latest/developer-guide/rabbitmq-version-management.html
  EOT
  type        = string

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.engine_version))
    error_message = "Engine version must be in major.minor format (for example: 3.13)."
  }
}

variable "configuration_data" {
  description = <<-EOT
    The RabbitMQ configuration data in Base64-encoded format.
    
    This should be a Base64-encoded RabbitMQ Cuttlefish configuration (rabbitmq.conf format).
    The configuration allows you to customize RabbitMQ broker settings such as:
    - Memory limits and thresholds
    - Disk space limits
    - Queue and message policies
    - Connection limits
    - Authentication mechanisms
    - Logging levels
    
    Example (before Base64 encoding):
    vm_memory_high_watermark.relative = 0.4
    disk_free_limit.relative = 1.0
    
    Use the base64encode() function to encode your configuration:
    configuration_data = base64encode(file("path/to/rabbitmq.conf"))
    
    For configuration reference, see:
    https://www.rabbitmq.com/configure.html
  EOT
  type        = string

  validation {
    condition     = can(base64decode(var.configuration_data))
    error_message = "Configuration data must be a valid Base64-encoded string."
  }

  validation {
    condition     = try(length(trimspace(base64decode(var.configuration_data))) > 0, false)
    error_message = "Configuration data must decode to a non-empty RabbitMQ Cuttlefish configuration."
  }
}

# -----------------------------------------------------------------------------
# Optional Variables
# -----------------------------------------------------------------------------

variable "description" {
  description = <<-EOT
    Description of the RabbitMQ configuration.
    Helps identify the purpose and scope of the configuration.
  EOT
  type        = string
  default     = "RabbitMQ configuration managed by Terraform"
}

variable "tags" {
  description = "A map of tags to add to all resources. Use this to add consistent tagging across your infrastructure."
  type        = map(string)
  default     = {}
}
