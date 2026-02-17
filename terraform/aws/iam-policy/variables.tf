# -----------------------------------------------------------------------------
# IAM Policy Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the IAM policy"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-_+=,.@-]*$", var.name)) && length(var.name) <= 128
    error_message = "Policy name must start with a letter, contain only alphanumeric characters and -_+=,.@- symbols, and be up to 128 characters long."
  }
}

variable "description" {
  description = "Description of the IAM policy"
  type        = string
  default     = "IAM policy created by Terraform"
}

variable "policy" {
  description = "JSON-formatted IAM policy document"
  type        = string

  validation {
    condition     = can(jsondecode(var.policy))
    error_message = "The policy must be a valid JSON document."
  }
}

variable "tags" {
  description = "Tags to apply to the IAM policy"
  type        = map(string)
  default     = {}
}
