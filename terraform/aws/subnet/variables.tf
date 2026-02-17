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
    condition     = alltrue([for cidr in var.public_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "All public_subnet_cidrs must be valid IPv4 CIDRs."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets. Length must match azs when provided."
  type        = list(string)
  default     = []

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

variable "public_subnet_tags" {
  description = "Additional tags for public subnets only."
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for private subnets only."
  type        = map(string)
  default     = {}
}

variable "database_subnet_tags" {
  description = "Additional tags for database subnets only."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Common tags applied to all subnets."
  type        = map(string)
  default     = {}
}
