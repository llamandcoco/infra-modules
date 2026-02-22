# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the launch template"
  type        = string
}

# -----------------------------------------------------------------------------
# Instance Configuration
# -----------------------------------------------------------------------------

variable "description" {
  description = "Description of the launch template"
  type        = string
  default     = null
}

variable "update_default_version" {
  description = "Whether to update Default Version each time a new version is created. Set to true for automatic rollout, false to keep existing default."
  type        = bool
  default     = false
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = null
}

variable "image_id" {
  description = "AMI ID for instances (if provided, overrides SSM lookup)"
  type        = string
  default     = null
}

variable "use_ssm_ami_lookup" {
  description = "When true, use SSM parameter to lookup AL2023 AMI"
  type        = bool
  default     = true
}

variable "ami_architecture" {
  description = "AMI architecture for AL2023 SSM lookup: auto (infer from instance_type), x86_64, or arm64"
  type        = string
  default     = "auto"

  validation {
    condition     = contains(["auto", "x86_64", "arm64"], var.ami_architecture)
    error_message = "ami_architecture must be one of: auto, x86_64, arm64."
  }
}

variable "ami_ssm_parameter_name" {
  description = "Optional custom SSM parameter name for AL2023 AMI lookup"
  type        = string
  default     = null
}

variable "key_name" {
  description = "SSH key name to use for instances"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# IAM Configuration
# -----------------------------------------------------------------------------

variable "iam_instance_profile_name" {
  description = "IAM instance profile name for EC2 instances"
  type        = string
  default     = null
}

variable "iam_instance_profile_arn" {
  description = "IAM instance profile ARN for EC2 instances"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------

variable "vpc_security_group_ids" {
  description = "List of security group IDs for instances"
  type        = list(string)
  default     = []
}

variable "network_interfaces" {
  description = "Network interface configuration for the launch template"
  type = list(object({
    associate_public_ip_address = optional(bool)
    delete_on_termination       = optional(bool)
    device_index                = number
    security_groups             = optional(list(string), [])
    subnet_id                   = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# User Data
# -----------------------------------------------------------------------------

variable "user_data" {
  description = "Plain user data script (will be base64-encoded)"
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "Base64-encoded user data script"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Metadata Options (IMDSv2)
# -----------------------------------------------------------------------------

variable "metadata_options" {
  description = "Instance metadata service configuration. If not specified, defaults to IMDSv2 enforcement (http_tokens = required). Set to null or provide custom values to override."
  type = object({
    http_endpoint               = optional(string)
    http_tokens                 = optional(string)
    http_put_response_hop_limit = optional(number)
    instance_metadata_tags      = optional(string)
  })
  default = null
}

# -----------------------------------------------------------------------------
# Monitoring
# -----------------------------------------------------------------------------

variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = null
}

# -----------------------------------------------------------------------------
# Block Device Mappings
# -----------------------------------------------------------------------------

variable "block_device_mappings" {
  description = "Block device mappings for the launch template"
  type = list(object({
    device_name  = string
    no_device    = optional(string)
    virtual_name = optional(string)
    ebs = optional(object({
      delete_on_termination = optional(bool, true)
      encrypted             = optional(bool, true)
      iops                  = optional(number)
      kms_key_id            = optional(string)
      snapshot_id           = optional(string)
      throughput            = optional(number)
      volume_size           = optional(number)
      volume_type           = optional(string, "gp3")
    }))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# CPU Credits
# -----------------------------------------------------------------------------

variable "cpu_credits" {
  description = "Credit option for CPU usage (standard or unlimited). Only for T2/T3/T4g instances."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Placement
# -----------------------------------------------------------------------------

variable "placement" {
  description = "Placement configuration for instances"
  type = object({
    availability_zone = optional(string)
    group_name        = optional(string)
    tenancy           = optional(string, "default")
  })
  default = null
}

# -----------------------------------------------------------------------------
# Tag Specifications
# -----------------------------------------------------------------------------

variable "tag_specifications" {
  description = "Resource types to tag at launch"
  type = list(object({
    resource_type = string
    tags          = map(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Additional Settings
# -----------------------------------------------------------------------------

variable "disable_api_termination" {
  description = "Enable EC2 instance termination protection"
  type        = bool
  default     = false
}

variable "ebs_optimized" {
  description = "Enable EBS optimization"
  type        = bool
  default     = null
}

# -----------------------------------------------------------------------------
# Instance Market Options (Spot)
# -----------------------------------------------------------------------------

variable "instance_market_options" {
  description = "Market (purchasing) option for the instances"
  type = object({
    market_type = string
    spot_options = optional(object({
      block_duration_minutes         = optional(number)
      instance_interruption_behavior = optional(string, "terminate")
      max_price                      = optional(string)
      spot_instance_type             = optional(string, "one-time")
      valid_until                    = optional(string)
    }))
  })
  default = null
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "tags" {
  description = "Tags to apply to the launch template resource"
  type        = map(string)
  default     = {}
}
