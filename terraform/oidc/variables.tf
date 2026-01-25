variable "provider_url" {
  description = "URL of the OIDC provider (e.g., token.actions.githubusercontent.com for GitHub Actions)"
  type        = string
  default     = "token.actions.githubusercontent.com"
}

variable "client_id_list" {
  description = "List of client IDs (audiences) for the OIDC provider"
  type        = list(string)
  default     = ["sts.amazonaws.com"]
}

variable "thumbprint_list" {
  description = "List of server certificate thumbprints. If not provided, will use GitHub Actions thumbprint"
  type        = list(string)
  default     = null
}

variable "role_name" {
  description = "Name of the IAM role to create for OIDC authentication"
  type        = string
}

variable "role_description" {
  description = "Description of the IAM role"
  type        = string
  default     = "Role for OIDC authentication"
}

variable "github_org" {
  description = "GitHub organization name (required for GitHub Actions OIDC)"
  type        = string
  default     = null
}

variable "github_repo" {
  description = "GitHub repository name (required for GitHub Actions OIDC). Use '*' to allow all repos in the organization"
  type        = string
  default     = null
}

variable "github_branch" {
  description = "GitHub branch name. Use '*' to allow all branches. If not specified, allows all branches"
  type        = string
  default     = "*"
}

variable "oidc_subjects" {
  description = "List of OIDC subject claims for custom providers. Used when not using GitHub Actions"
  type        = list(string)
  default     = []
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds for the IAM role"
  type        = number
  default     = 3600
}

variable "policy_arns" {
  description = "List of IAM policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "inline_policy_statements" {
  description = "List of inline policy statements to attach to the role"
  type = list(object({
    sid       = string
    effect    = string
    actions   = list(string)
    resources = list(string)
    condition = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })))
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
