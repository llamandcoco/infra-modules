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
  description = "List of custom ingress rules to apply. Empty list denies all inbound traffic."
  type = list(object({
    description              = optional(string)
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string), [])
    ipv6_cidr_blocks         = optional(list(string), [])
    source_security_group_id = optional(string)
    prefix_list_ids          = optional(list(string), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.ingress_rules :
      contains(["-1", "tcp", "udp", "icmp", "icmpv6", "esp", "ah", "gre"], lower(rule.protocol))
    ])
    error_message = "Protocol must be one of: -1 (all), tcp, udp, icmp, icmpv6, esp, ah, gre."
  }
}

variable "egress_rules" {
  description = "List of custom egress rules to apply. Empty list denies all outbound traffic."
  type = list(object({
    description              = optional(string)
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string), [])
    ipv6_cidr_blocks         = optional(list(string), [])
    source_security_group_id = optional(string)
    prefix_list_ids          = optional(list(string), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.egress_rules :
      contains(["-1", "tcp", "udp", "icmp", "icmpv6", "esp", "ah", "gre"], lower(rule.protocol))
    ])
    error_message = "Protocol must be one of: -1 (all), tcp, udp, icmp, icmpv6, esp, ah, gre."
  }
}

# -----------------------------------------------------------------------------
# Predefined Rule Templates
# -----------------------------------------------------------------------------

variable "predefined_ingress_rules" {
  description = "List of predefined ingress rule names to apply (http, https, ssh, mysql, postgres, redis, mongodb, etc.)."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for rule in var.predefined_ingress_rules :
      contains(["http", "https", "ssh", "rdp", "mysql", "postgres", "redis", "mongodb", "dns_tcp", "dns_udp", "ntp", "smtp", "smtps", "submission"], rule)
    ])
    error_message = "Predefined rule must be one of: http, https, ssh, rdp, mysql, postgres, redis, mongodb, dns_tcp, dns_udp, ntp, smtp, smtps, submission."
  }
}

variable "predefined_rule_cidr_blocks" {
  description = "CIDR blocks to apply to predefined ingress rules."
  type        = list(string)
  default     = []
}

variable "predefined_rule_ipv6_cidr_blocks" {
  description = "IPv6 CIDR blocks to apply to predefined ingress rules."
  type        = list(string)
  default     = []
}

variable "enable_default_egress_rule" {
  description = "Enable default egress rule allowing all outbound traffic."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to the security group."
  type        = map(string)
  default     = {}
}
