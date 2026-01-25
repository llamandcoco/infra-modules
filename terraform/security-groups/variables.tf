# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "vpc_id" {
  description = "VPC ID where security groups will be created. Must start with 'vpc-'."
  type        = string

  validation {
    condition     = can(regex("^vpc-[a-z0-9]{8,}$", var.vpc_id))
    error_message = "VPC ID must start with 'vpc-' followed by alphanumeric characters."
  }
}

variable "security_groups" {
  description = <<-EOT
    Map of security groups to create, keyed by an arbitrary name.
    Each security group can define ingress and egress rules with support for:
    - CIDR blocks (IPv4 and IPv6)
    - Prefix lists
    - Cross-group references using source_sg_key
    - Self-referencing rules
  EOT
  type = map(object({
    name        = string
    description = optional(string, "Managed security group")
    tags        = optional(map(string), {})

    ingress_rules = optional(list(object({
      description      = optional(string)
      from_port        = number
      to_port          = number
      protocol         = string
      cidr_blocks      = optional(list(string))
      ipv6_cidr_blocks = optional(list(string))
      prefix_list_ids  = optional(list(string))
      source_sg_key    = optional(string)
      self             = optional(bool)
    })), [])

    egress_rules = optional(list(object({
      description      = optional(string)
      from_port        = number
      to_port          = number
      protocol         = string
      cidr_blocks      = optional(list(string))
      ipv6_cidr_blocks = optional(list(string))
      prefix_list_ids  = optional(list(string))
      source_sg_key    = optional(string)
      self             = optional(bool)
    })), [])
  }))
}
