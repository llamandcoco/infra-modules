variable "name" {
  description = "Name of the security group."
  type        = string
}

variable "description" {
  description = "Description of the security group."
  type        = string
  default     = "Managed by terraform"
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created."
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules to apply. Empty list denies all inbound traffic."
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

variable "egress_rules" {
  description = "List of egress rules to apply. Empty list denies all outbound traffic."
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

variable "tags" {
  description = "Tags applied to the security group."
  type        = map(string)
  default     = {}
}
