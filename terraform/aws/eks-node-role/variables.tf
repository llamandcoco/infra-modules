# -----------------------------------------------------------------------------
# EKS Node IAM Role Variables
# -----------------------------------------------------------------------------

variable "role_name" {
  description = "Name of the EKS node IAM role"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-_]*$", var.role_name)) && length(var.role_name) <= 64
    error_message = "Role name must start with a letter, contain only alphanumeric characters, hyphens, and underscores, and be up to 64 characters long."
  }
}

variable "enable_ssm" {
  description = "Enable SSM for node access (AmazonSSMManagedInstanceCore policy)"
  type        = bool
  default     = true
}

variable "enable_cloudwatch" {
  description = "Enable CloudWatch agent permissions (CloudWatchAgentServerPolicy)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the IAM role"
  type        = map(string)
  default     = {}
}
