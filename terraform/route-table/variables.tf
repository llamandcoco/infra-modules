variable "vpc_id" {
  description = "ID of the VPC."
  type        = string
}

variable "internet_gateway_id" {
  description = "ID of the Internet Gateway for public route table."
  type        = string
  default     = null
}

variable "enable_public_internet_route" {
  description = "Create a default route for public subnets via the Internet Gateway."
  type        = bool
  default     = true
}

variable "nat_gateway_ids" {
  description = "Map of NAT Gateway IDs keyed by index."
  type        = map(string)
  default     = {}
}

variable "enable_private_default_route" {
  description = "Create default routes for private subnets using NAT."
  type        = bool
  default     = true
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs to associate with the public route table."
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs to associate with private route tables."
  type        = list(string)
  default     = []
}

variable "database_subnet_ids" {
  description = "List of database subnet IDs to associate with the database route table."
  type        = list(string)
  default     = []
}

variable "availability_zones" {
  description = "Availability zones corresponding to subnets (used for naming)."
  type        = list(string)
  default     = []
}

variable "database_route_via_nat" {
  description = "Route database subnets through the first NAT Gateway."
  type        = bool
  default     = false
}

variable "name_prefix" {
  description = "Prefix used for route table Name tags."
  type        = string
  default     = "network"
}

variable "tags" {
  description = "Tags applied to all route tables."
  type        = map(string)
  default     = {}
}
