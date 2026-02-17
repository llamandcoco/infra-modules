variable "name" {
  description = "IAM user name"
  type        = string
}

variable "path" {
  description = "Path for the IAM user"
  type        = string
  default     = "/"
}

variable "force_destroy" {
  description = "Delete user even if it has non-Terraform managed access keys or policies"
  type        = bool
  default     = false
}

variable "create_access_key" {
  description = "Create programmatic access key for the user"
  type        = bool
  default     = false
}

variable "access_key_status" {
  description = "Access key status (Active or Inactive)"
  type        = string
  default     = "Active"

  validation {
    condition     = contains(["Active", "Inactive"], var.access_key_status)
    error_message = "Access key status must be either 'Active' or 'Inactive'."
  }
}

variable "create_login_profile" {
  description = "Create console login profile for the user"
  type        = bool
  default     = false
}

variable "pgp_key" {
  description = "PGP key used to encrypt the generated console password. Required when create_login_profile is true."
  type        = string
  default     = null
}

variable "password_reset_required" {
  description = "Require password reset on first login"
  type        = bool
  default     = true
}

variable "policy_arns" {
  description = "List of IAM policy ARNs to attach to the user"
  type        = list(string)
  default     = []
}

variable "custom_policy_statements" {
  description = "List of custom IAM policy statements to attach as inline policies"
  type = list(object({
    sid       = optional(string)
    effect    = optional(string, "Allow")
    actions   = list(string)
    resources = list(string)
  }))
  default = []
}

variable "group_names" {
  description = "List of IAM group names to add the user to"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to the IAM user"
  type        = map(string)
  default     = {}
}
