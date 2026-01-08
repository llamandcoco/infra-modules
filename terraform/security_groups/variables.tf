variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "security_groups" {
  description = "Map of security groups to create keyed by an arbitrary name"
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
