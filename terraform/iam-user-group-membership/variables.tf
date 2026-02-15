# -----------------------------------------------------------------------------
# IAM User Group Membership Variables
# -----------------------------------------------------------------------------

variable "user_name" {
  description = "Name of the IAM user"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9+=,.@_-]+$", var.user_name)) && length(var.user_name) >= 1 && length(var.user_name) <= 64
    error_message = "User name must be 1-64 characters and contain only alphanumeric characters and +=,.@_- symbols."
  }
}

variable "group_names" {
  description = "List of IAM group names to add the user to"
  type        = list(string)

  validation {
    condition     = length(var.group_names) > 0
    error_message = "At least one group name must be provided."
  }

  validation {
    condition     = alltrue([for g in var.group_names : can(regex("^[a-zA-Z0-9+=,.@_-]+$", g)) && length(g) >= 1 && length(g) <= 128])
    error_message = "Each group name must be 1-128 characters and contain only alphanumeric characters and +=,.@_- symbols."
  }

  validation {
    condition     = length(var.group_names) <= 10
    error_message = "IAM users can be members of at most 10 groups."
  }
}
