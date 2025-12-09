variable "name" {
  description = "Name tag for the VPC."
  type        = string

  validation {
    condition     = length(var.name) > 0
    error_message = "name must not be empty."
  }
}

variable "cidr_block" {
  description = "CIDR block for the VPC."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.cidr_block))
    error_message = "cidr_block must be a valid IPv4 CIDR."
  }
}

variable "enable_dns_support" {
  description = "Enable DNS resolution for the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames for instances launched in the VPC."
  type        = bool
  default     = true
}

variable "enable_ipv6" {
  description = "Assign an Amazon-provided IPv6 CIDR block to the VPC."
  type        = bool
  default     = false
}

variable "instance_tenancy" {
  description = "The allowed tenancy of instances launched into the VPC."
  type        = string
  default     = "default"

  validation {
    condition     = contains(["default", "dedicated", "host"], var.instance_tenancy)
    error_message = "instance_tenancy must be one of default, dedicated, or host."
  }
}

variable "enable_network_address_usage_metrics" {
  description = "Enable network address usage metrics for the VPC."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to apply to the VPC."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# VPC Flow Logs Configuration
# -----------------------------------------------------------------------------

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs for network monitoring and security auditing."
  type        = bool
  default     = false
}

variable "flow_logs_traffic_type" {
  description = "Type of traffic to log (ACCEPT, REJECT, ALL)."
  type        = string
  default     = "ALL"

  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.flow_logs_traffic_type)
    error_message = "flow_logs_traffic_type must be one of ACCEPT, REJECT, or ALL."
  }
}

variable "flow_logs_iam_role_arn" {
  description = "IAM role ARN for VPC Flow Logs. Required if enable_flow_logs is true."
  type        = string
  default     = null
}

variable "flow_logs_destination_arn" {
  description = "ARN of the destination for VPC Flow Logs (CloudWatch Log Group or S3 bucket). Required if enable_flow_logs is true."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Default Resource Management
# -----------------------------------------------------------------------------

variable "manage_default_security_group" {
  description = "Manage the default security group and lock it down (recommended for security)."
  type        = bool
  default     = true
}

variable "manage_default_nacl" {
  description = "Manage the default network ACL."
  type        = bool
  default     = true
}
