variable "vpc_id" {
  description = "ID of the VPC where subnets will be created."
  type        = string
}

variable "azs" {
  description = "List of availability zones to spread subnets across."
  type        = list(string)

  validation {
    condition     = length(var.azs) >= 1
    error_message = "At least one availability zone must be provided."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets. Length must match azs when provided."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.public_subnet_cidrs) == 0 || length(var.public_subnet_cidrs) == length(var.azs)
    error_message = "public_subnet_cidrs must be empty or have the same length as azs."
  }

  validation {
    condition     = alltrue([for cidr in var.public_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "All public_subnet_cidrs must be valid IPv4 CIDRs."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets. Length must match azs when provided."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.private_subnet_cidrs) == 0 || length(var.private_subnet_cidrs) == length(var.azs)
    error_message = "private_subnet_cidrs must be empty or have the same length as azs."
  }

  validation {
    condition     = alltrue([for cidr in var.private_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "All private_subnet_cidrs must be valid IPv4 CIDRs."
  }
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets. Length must match azs when provided."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.database_subnet_cidrs) == 0 || length(var.database_subnet_cidrs) == length(var.azs)
    error_message = "database_subnet_cidrs must be empty or have the same length as azs."
  }

  validation {
    condition     = alltrue([for cidr in var.database_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "All database_subnet_cidrs must be valid IPv4 CIDRs."
  }
}

variable "name_prefix" {
  description = "Prefix used for subnet Name tags."
  type        = string
  default     = "network"
}

variable "map_public_ip_on_launch" {
  description = "Auto-assign public IPs for instances in public subnets."
  type        = bool
  default     = true
}

variable "enable_ipv6" {
  description = "Assign IPv6 addresses on creation for public subnets."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags applied to all subnets."
  type        = map(string)
  default     = {}
}
