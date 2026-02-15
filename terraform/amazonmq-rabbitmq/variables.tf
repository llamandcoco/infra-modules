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
    condition     = length(var.configuration_name) > 0 && length(var.configuration_name) <= 255
    error_message = "Configuration name must be between 1 and 255 characters long."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.configuration_name))
    error_message = "Configuration name must only contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "engine_version" {
  description = <<-EOT
    The version of the RabbitMQ broker engine.
    
    Supported versions:
    - 3.13
    - 3.12
    - 3.11
    - 3.10
    - 3.9
    - 3.8
    
    Refer to AWS documentation for the latest supported versions:
    https://docs.aws.amazon.com/amazon-mq/latest/developer-guide/rabbitmq-version-management.html
  EOT
  type        = string

  validation {
    condition     = can(regex("^3\\.(8|9|10|11|12|13)$", var.engine_version))
    error_message = "Engine version must be a valid RabbitMQ version (3.8, 3.9, 3.10, 3.11, 3.12, or 3.13)."
  }
}

variable "configuration_data" {
  description = <<-EOT
    The RabbitMQ configuration data in Base64-encoded format.
    
    This should be a Base64-encoded RabbitMQ advanced.config file following Erlang syntax.
    The configuration allows you to customize RabbitMQ broker settings such as:
    - Memory limits and thresholds
    - Disk space limits
    - Queue and message policies
    - Connection limits
    - Authentication mechanisms
    - Logging levels
    
    Example (before Base64 encoding):
    [
      {rabbit, [
        {vm_memory_high_watermark, 0.4},
        {disk_free_limit, {mem_relative, 1.0}}
      ]}
    ].
    
    Use the base64encode() function to encode your configuration:
    configuration_data = base64encode(file("path/to/advanced.config"))
    
    For configuration reference, see:
    https://www.rabbitmq.com/configure.html
  EOT
  type        = string

  validation {
    condition     = can(base64decode(var.configuration_data))
    error_message = "Configuration data must be a valid Base64-encoded string."
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
