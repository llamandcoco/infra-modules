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
