variable "name" {
  description = "Name of the IAM group"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9+=,.@_-]*$", var.name)) && length(var.name) <= 128
    error_message = "Group name must start with a letter, contain only valid characters (alphanumeric, +=,.@_-), and be up to 128 characters long."
  }
}

variable "path" {
  description = "Path for the IAM group"
  type        = string
  default     = "/"

  validation {
    condition     = can(regex("^\\/([a-zA-Z0-9+=,.@_-]+\\/)*$", var.path))
    error_message = "Path must start and end with a forward slash and contain only valid characters."
  }
}

variable "managed_policy_arns" {
  description = "List of IAM managed policy ARNs to attach to the group"
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Map of inline policy names to JSON policy documents"
  type        = map(string)
  default     = {}
}

variable "user_names" {
  description = "List of IAM user names to add to the group"
  type        = list(string)
  default     = []
}
