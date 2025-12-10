variable "public_subnet_ids" {
  description = "List of public subnet IDs where NAT Gateways will be placed."
  type        = list(string)
  default     = []
}

variable "create_per_az" {
  description = "Create one NAT Gateway per provided subnet for high availability."
  type        = bool
  default     = true
}

variable "name_prefix" {
  description = "Prefix used for NAT Gateway resource names."
  type        = string
  default     = "network"
}

variable "tags" {
  description = "Tags to apply to NAT Gateways and EIPs."
  type        = map(string)
  default     = {}
}
