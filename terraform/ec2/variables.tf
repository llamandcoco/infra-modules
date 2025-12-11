# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "instance_name" {
  description = "Name of the EC2 instance. Used for the Name tag and resource naming."
  type        = string

  validation {
    condition     = length(var.instance_name) >= 1 && length(var.instance_name) <= 255
    error_message = "Instance name must be between 1 and 255 characters long."
  }
}

variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance. Must start with 'ami-'."
  type        = string

  validation {
    condition     = can(regex("^ami-[a-z0-9]{8,}$", var.ami_id))
    error_message = "AMI ID must start with 'ami-' followed by alphanumeric characters."
  }
}

variable "instance_type" {
  description = <<-EOT
    The instance type to use for the EC2 instance.
    Common types: t3.micro, t3.small, t3.medium, c6i.large, r6i.large
  EOT
  type        = string

  validation {
    condition = can(regex("^[a-z][a-z0-9-]+\\.[a-z0-9]+$", var.instance_type))
    error_message = "Instance type must be a valid EC2 instance type format (e.g., t3.micro, c6i.large)."
  }
}

variable "subnet_id" {
  description = "The VPC subnet ID to launch the instance in. Must start with 'subnet-'."
  type        = string

  validation {
    condition     = can(regex("^subnet-[a-z0-9]{8,}$", var.subnet_id))
    error_message = "Subnet ID must start with 'subnet-' followed by alphanumeric characters."
  }
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------

variable "vpc_security_group_ids" {
  description = <<-EOT
    List of security group IDs to attach to the instance.
    Can be empty if create_security_group is true.
  EOT
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for sg in var.vpc_security_group_ids :
      can(regex("^sg-[a-z0-9]{8,}$", sg))
    ])
    error_message = "All security group IDs must start with 'sg-' followed by alphanumeric characters."
  }
}

variable "create_security_group" {
  description = "Whether to create a new security group for the instance."
  type        = bool
  default     = false
}

variable "security_group_name" {
  description = "Name of the security group to create. Required if create_security_group is true."
  type        = string
  default     = null
}

variable "security_group_description" {
  description = "Description of the security group to create."
  type        = string
  default     = "Security group managed by Terraform"
}

variable "security_group_rules" {
  description = <<-EOT
    List of security group rules to create. Only used if create_security_group is true.
    Each rule should specify type (ingress/egress), ports, protocol, CIDR blocks, and description.
  EOT
  type = list(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.security_group_rules :
      contains(["ingress", "egress"], rule.type)
    ])
    error_message = "Security group rule type must be either 'ingress' or 'egress'."
  }

  validation {
    condition = alltrue([
      for rule in var.security_group_rules :
      contains(["tcp", "udp", "icmp", "-1"], rule.protocol)
    ])
    error_message = "Security group rule protocol must be 'tcp', 'udp', 'icmp', or '-1' (all)."
  }
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance in a VPC."
  type        = bool
  default     = false
}

variable "create_eip" {
  description = "Whether to create and associate an Elastic IP with the instance."
  type        = bool
  default     = false
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC. If not specified, an IP will be automatically assigned."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Storage Configuration
# -----------------------------------------------------------------------------

variable "root_block_device" {
  description = <<-EOT
    Configuration for the root block device.
    Supports volume size, type, IOPS, throughput, encryption, and deletion settings.
  EOT
  type = object({
    volume_size           = optional(number, 8)
    volume_type           = optional(string, "gp3")
    iops                  = optional(number)
    throughput            = optional(number)
    encrypted             = optional(bool, true)
    kms_key_id            = optional(string)
    delete_on_termination = optional(bool, true)
  })
  default = {}

  validation {
    condition = contains(
      ["gp2", "gp3", "io1", "io2", "st1", "sc1"],
      lookup(var.root_block_device, "volume_type", "gp3")
    )
    error_message = "Root volume type must be one of: gp2, gp3, io1, io2, st1, sc1."
  }
}

variable "ebs_volumes" {
  description = <<-EOT
    List of additional EBS volumes to create and attach to the instance.
    Each volume requires device_name, size, and type. Supports encryption and IOPS/throughput settings.
  EOT
  type = list(object({
    device_name           = string
    volume_size           = number
    volume_type           = optional(string, "gp3")
    iops                  = optional(number)
    throughput            = optional(number)
    encrypted             = optional(bool, true)
    kms_key_id            = optional(string)
    availability_zone     = optional(string)
    delete_on_termination = optional(bool, true)
  }))
  default = []

  validation {
    condition = alltrue([
      for vol in var.ebs_volumes :
      contains(["gp2", "gp3", "io1", "io2", "st1", "sc1"], lookup(vol, "volume_type", "gp3"))
    ])
    error_message = "EBS volume type must be one of: gp2, gp3, io1, io2, st1, sc1."
  }
}

# -----------------------------------------------------------------------------
# Compute Configuration
# -----------------------------------------------------------------------------

variable "key_name" {
  description = "The name of the SSH key pair to use for the instance. Key pair must already exist in AWS."
  type        = string
  default     = null
}

variable "monitoring" {
  description = "Enable detailed monitoring (additional charges apply)."
  type        = bool
  default     = false
}

variable "user_data" {
  description = <<-EOT
    User data script to run at instance launch. Will be automatically base64 encoded.
    Cannot be used with user_data_base64.
  EOT
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = <<-EOT
    Base64-encoded user data script. Use this if you need to provide pre-encoded data.
    Cannot be used with user_data.
  EOT
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "When true, changes to user_data will trigger instance replacement instead of stop/start."
  type        = bool
  default     = false
}

variable "cpu_credits" {
  description = <<-EOT
    Credit option for CPU usage. Valid values: 'standard' or 'unlimited'.
    Only applicable for T2/T3/T4g instance types.
  EOT
  type        = string
  default     = "unlimited"

  validation {
    condition     = contains(["standard", "unlimited"], var.cpu_credits)
    error_message = "CPU credits must be either 'standard' or 'unlimited'."
  }
}

# -----------------------------------------------------------------------------
# IAM Configuration
# -----------------------------------------------------------------------------

variable "create_iam_instance_profile" {
  description = "Whether to create a new IAM instance profile and role for the instance."
  type        = bool
  default     = false
}

variable "iam_instance_profile_name" {
  description = "Name of an existing IAM instance profile to attach to the instance. Cannot be used with create_iam_instance_profile."
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "Custom name for the IAM role when create_iam_instance_profile is true. If not specified, will be auto-generated."
  type        = string
  default     = null
}

variable "iam_policy_arns" {
  description = "List of IAM policy ARNs to attach to the IAM role. Only used when create_iam_instance_profile is true."
  type        = list(string)
  default     = []
}

variable "iam_inline_policies" {
  description = <<-EOT
    List of inline IAM policies to attach to the role. Only used when create_iam_instance_profile is true.
    Each policy requires a name and a JSON policy document.
  EOT
  type = list(object({
    name   = string
    policy = string
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Lifecycle Configuration
# -----------------------------------------------------------------------------

variable "disable_api_termination" {
  description = "Enable EC2 instance termination protection."
  type        = bool
  default     = false
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance when initiated from the OS. Valid values: 'stop' or 'terminate'."
  type        = string
  default     = "stop"

  validation {
    condition     = contains(["stop", "terminate"], var.instance_initiated_shutdown_behavior)
    error_message = "Instance initiated shutdown behavior must be either 'stop' or 'terminate'."
  }
}

variable "enable_spot_instance" {
  description = "Whether to launch the instance as a spot instance."
  type        = bool
  default     = false
}

variable "spot_price" {
  description = "Maximum price to pay for spot instance (per hour). If not specified, uses on-demand price as max."
  type        = string
  default     = null
}

variable "spot_instance_interruption_behavior" {
  description = "Behavior when a spot instance is interrupted. Valid values: 'terminate', 'stop', or 'hibernate'."
  type        = string
  default     = "terminate"

  validation {
    condition     = contains(["terminate", "stop", "hibernate"], var.spot_instance_interruption_behavior)
    error_message = "Spot instance interruption behavior must be 'terminate', 'stop', or 'hibernate'."
  }
}

variable "spot_instance_type" {
  description = "Type of spot request. Valid values: 'one-time' or 'persistent'."
  type        = string
  default     = "one-time"

  validation {
    condition     = contains(["one-time", "persistent"], var.spot_instance_type)
    error_message = "Spot instance type must be 'one-time' or 'persistent'."
  }
}

# -----------------------------------------------------------------------------
# Metadata Options (IMDSv2)
# -----------------------------------------------------------------------------

variable "metadata_options" {
  description = <<-EOT
    Instance metadata service configuration. Controls access to instance metadata.
    Recommended to require IMDSv2 for enhanced security.
  EOT
  type = object({
    http_endpoint               = optional(string, "enabled")
    http_tokens                 = optional(string, "required")
    http_put_response_hop_limit = optional(number, 1)
    instance_metadata_tags      = optional(string, "disabled")
  })
  default = {}

  validation {
    condition = contains(
      ["enabled", "disabled"],
      lookup(var.metadata_options, "http_endpoint", "enabled")
    )
    error_message = "Metadata http_endpoint must be 'enabled' or 'disabled'."
  }

  validation {
    condition = contains(
      ["required", "optional"],
      lookup(var.metadata_options, "http_tokens", "required")
    )
    error_message = "Metadata http_tokens must be 'required' (IMDSv2) or 'optional' (IMDSv1)."
  }

  validation {
    condition = contains(
      ["enabled", "disabled"],
      lookup(var.metadata_options, "instance_metadata_tags", "disabled")
    )
    error_message = "Metadata instance_metadata_tags must be 'enabled' or 'disabled'."
  }
}

# -----------------------------------------------------------------------------
# Tenancy and Placement
# -----------------------------------------------------------------------------

variable "tenancy" {
  description = <<-EOT
    Tenancy of the instance. Valid values: 'default', 'dedicated', or 'host'.
    - default: Shared hardware (most cost-effective)
    - dedicated: Runs on single-tenant hardware
    - host: Runs on a Dedicated Host
  EOT
  type        = string
  default     = "default"

  validation {
    condition     = contains(["default", "dedicated", "host"], var.tenancy)
    error_message = "Tenancy must be 'default', 'dedicated', or 'host'."
  }
}

variable "hibernation" {
  description = "Enable hibernation for the instance. Requires encrypted root volume."
  type        = bool
  default     = false
}

variable "source_dest_check" {
  description = "Enable source/destination checking. Should be disabled for NAT instances or routers."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# VPC Configuration
# -----------------------------------------------------------------------------

variable "vpc_id" {
  description = "VPC ID where the security group will be created. Required if create_security_group is true."
  type        = string
  default     = null

  validation {
    condition     = var.vpc_id == null || can(regex("^vpc-[a-z0-9]{8,}$", var.vpc_id))
    error_message = "VPC ID must start with 'vpc-' followed by alphanumeric characters."
  }
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "volume_tags" {
  description = "A map of tags to add to all EBS volumes (root and additional volumes)."
  type        = map(string)
  default     = {}
}
