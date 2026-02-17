variable "name" {
  description = "Name of the managed prefix list."
  type        = string
}

variable "create" {
  description = "Whether to create the managed prefix list."
  type        = bool
  default     = true
}

variable "address_family" {
  description = "Address family (IPv4 or IPv6) for the managed prefix list."
  type        = string
  default     = "IPv4"

  validation {
    condition     = contains(["IPv4", "IPv6"], var.address_family)
    error_message = "Address family must be either 'IPv4' or 'IPv6'."
  }
}

variable "max_entries" {
  description = "Maximum number of entries in the prefix list."
  type        = number

  validation {
    condition     = var.max_entries > 0 && var.max_entries <= 1000
    error_message = "Max entries must be between 1 and 1000."
  }
}

variable "entries" {
  description = "List of prefix list entries. Each entry should have 'cidr' and optional 'description'."
  type = list(object({
    cidr        = string
    description = optional(string)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to the managed prefix list."
  type        = map(string)
  default     = {}
}
