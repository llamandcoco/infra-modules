# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the DB parameter group. Must be unique within the region."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name))
    error_message = "Parameter group name must only contain lowercase alphanumeric characters and hyphens."
  }

  validation {
    condition     = length(var.name) <= 255
    error_message = "Parameter group name must be 255 characters or less."
  }
}

variable "family" {
  description = <<-EOT
    The DB parameter group family (e.g., mysql8.0, postgres15, mariadb10.6).
    Must match the database engine family you plan to use.
    See AWS documentation for available families.
  EOT
  type        = string

  validation {
    condition     = length(var.family) > 0
    error_message = "Family must be specified."
  }
}

# -----------------------------------------------------------------------------
# Optional Variables
# -----------------------------------------------------------------------------

variable "description" {
  description = "Description of the DB parameter group."
  type        = string
  default     = null
}

variable "parameters" {
  description = <<-EOT
    List of database parameters to configure.
    Each parameter requires a name and value.
    Apply method can be 'immediate' (default) or 'pending-reboot'.
    
    Example:
    [
      {
        name  = "max_connections"
        value = "200"
        apply_method = "immediate"
      }
    ]
  EOT
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = []

  validation {
    condition = alltrue([
      for param in var.parameters :
      contains(["immediate", "pending-reboot"], param.apply_method)
    ])
    error_message = "Apply method must be either 'immediate' or 'pending-reboot'."
  }
}

variable "tags" {
  description = "A map of tags to add to the parameter group."
  type        = map(string)
  default     = {}
}
