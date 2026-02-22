# -----------------------------------------------------------------------------
# IAM Role Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the IAM role"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-_+=,.@-]*$", var.name)) && length(var.name) <= 64
    error_message = "Role name must start with a letter, contain only alphanumeric characters and -_+=,.@- symbols, and be up to 64 characters long."
  }
}

variable "description" {
  description = "Description of the IAM role"
  type        = string
  default     = "IAM role created by Terraform"
}

variable "assume_role_policy" {
  description = "JSON-formatted assume role policy document (trust policy)"
  type        = string

  validation {
    condition     = can(jsondecode(var.assume_role_policy))
    error_message = "The assume role policy must be a valid JSON document."
  }
}

variable "managed_policy_arns" {
  description = "List of ARNs of managed policies to attach to the role"
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Map of inline policy names to policy documents (JSON strings)"
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for policy in values(var.inline_policies) : can(jsondecode(policy))])
    error_message = "All inline policies must be valid JSON documents."
  }
}

variable "max_session_duration" {
  description = "Maximum session duration (in seconds) for the role (3600-43200)"
  type        = number
  default     = 3600

  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "Max session duration must be between 3600 (1 hour) and 43200 (12 hours)."
  }
}

variable "path" {
  description = "Path for the IAM role"
  type        = string
  default     = "/"

  validation {
    condition     = can(regex("^/.*/$", var.path)) || var.path == "/"
    error_message = "Path must begin and end with /."
  }
}

variable "permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the role"
  type        = string
  default     = null
}

variable "force_detach_policies" {
  description = "Whether to force detach policies when destroying the role"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the IAM role"
  type        = map(string)
  default     = {}
}
