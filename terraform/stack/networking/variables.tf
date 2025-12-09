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
  description = "CIDR blocks for public subnets."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == length(var.azs)
    error_message = "public_subnet_cidrs must match the number of AZs."
  }

  validation {
    condition     = alltrue([for cidr in var.public_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "All public_subnet_cidrs must be valid IPv4 CIDRs."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) == length(var.azs)
    error_message = "private_subnet_cidrs must match the number of AZs."
  }

  validation {
    condition     = alltrue([for cidr in var.private_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "All private_subnet_cidrs must be valid IPv4 CIDRs."
  }
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.database_subnet_cidrs) == 0 || length(var.database_subnet_cidrs) == length(var.azs)
    error_message = "database_subnet_cidrs must be empty or match the number of AZs."
  }

  validation {
    condition     = alltrue([for cidr in var.database_subnet_cidrs : can(cidrnetmask(cidr))])
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

variable "map_public_ip_on_launch" {
  description = "Auto-assign public IPs to instances in public subnets."
  type        = bool
  default     = true
}

variable "nat_per_az" {
  description = "Create one NAT Gateway per AZ for high availability."
  type        = bool
  default     = true
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
    description                   = optional(string)
    from_port                     = number
    to_port                       = number
    protocol                      = string
    cidr_blocks                   = optional(list(string), [])
    ipv6_cidr_blocks              = optional(list(string), [])
    destination_security_group_id = optional(string)
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
