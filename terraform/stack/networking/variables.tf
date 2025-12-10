variable "name" {
  description = "Name prefix for networking resources."
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.cidr_block))
    error_message = "cidr_block must be a valid IPv4 CIDR."
  }
}

variable "azs" {
  description = "Availability zones to span the network across."
  type        = list(string)

  validation {
    condition     = length(var.azs) >= 2
    error_message = "Provide at least two availability zones for HA."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets. If null, automatically calculated from VPC CIDR."
  type        = list(string)
  default     = null

  validation {
    condition     = var.public_subnet_cidrs == null || alltrue([for cidr in var.public_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "All public_subnet_cidrs must be valid IPv4 CIDRs."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets. If null, automatically calculated from VPC CIDR."
  type        = list(string)
  default     = null

  validation {
    condition     = var.private_subnet_cidrs == null || alltrue([for cidr in var.private_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "All private_subnet_cidrs must be valid IPv4 CIDRs."
  }
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets. If null, automatically calculated from VPC CIDR. Use [] to disable database subnets."
  type        = list(string)
  default     = null

  validation {
    condition     = var.database_subnet_cidrs == null || alltrue([for cidr in var.database_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "All database_subnet_cidrs must be valid IPv4 CIDRs."
  }
}

variable "enable_dns_support" {
  description = "Enable DNS resolution in the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC."
  type        = bool
  default     = true
}

variable "enable_network_address_usage_metrics" {
  description = "Enable VPC IP address usage metrics."
  type        = bool
  default     = false
}

variable "instance_tenancy" {
  description = "Instance tenancy for the VPC."
  type        = string
  default     = "default"
}

variable "enable_ipv6" {
  description = "Enable IPv6 for the VPC and public subnets."
  type        = bool
  default     = false
}

variable "internet_gateway_enabled" {
  description = "Create an Internet Gateway. Automatically enabled if public subnets are configured."
  type        = bool
  default     = true
}

variable "map_public_ip_on_launch" {
  description = "Auto-assign public IPs to instances in public subnets."
  type        = bool
  default     = true
}

variable "nat_gateway_mode" {
  description = "NAT Gateway deployment strategy: 'per_az' (HA, one per AZ), 'single' (cost-optimized, one NAT), or 'none' (no NAT)."
  type        = string
  default     = "per_az"

  validation {
    condition     = contains(["per_az", "single", "none"], var.nat_gateway_mode)
    error_message = "nat_gateway_mode must be one of: per_az, single, none."
  }
}

variable "nat_per_az" {
  description = "DEPRECATED: Use nat_gateway_mode instead. Create one NAT Gateway per AZ for high availability."
  type        = bool
  default     = null
}

variable "database_route_via_nat" {
  description = "Route database subnets to the internet via NAT."
  type        = bool
  default     = false
}

variable "workload_security_group_ingress" {
  description = "Ingress rules for the default workload security group."
  type = list(object({
    description              = optional(string)
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string), [])
    ipv6_cidr_blocks         = optional(list(string), [])
    source_security_group_id = optional(string)
  }))
  default = []
}

variable "workload_security_group_egress" {
  description = "Egress rules for the default workload security group."
  type = list(object({
    description              = optional(string)
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string), [])
    ipv6_cidr_blocks         = optional(list(string), [])
    source_security_group_id = optional(string)
  }))
  default = [
    {
      description = "Allow all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "tags" {
  description = "Common tags applied to all networking resources."
  type        = map(string)
  default     = {}
}
