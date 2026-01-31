# -----------------------------------------------------------------------------
# KEDA IAM Role Variables
# -----------------------------------------------------------------------------

variable "role_name" {
  description = "Name of the KEDA IAM role"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-_]*$", var.role_name)) && length(var.role_name) <= 64
    error_message = "Role name must start with a letter, contain only alphanumeric characters, hyphens, and underscores, and be up to 64 characters long."
  }
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider"
  type        = string
}

variable "oidc_provider" {
  description = "OIDC provider URL (without https://)"
  type        = string
}

variable "service_account_namespace" {
  description = "Kubernetes namespace for the KEDA service account"
  type        = string
  default     = "keda"
}

variable "service_account_name" {
  description = "Kubernetes service account name for KEDA operator"
  type        = string
  default     = "keda-operator"
}

variable "cloudwatch_actions" {
  description = "CloudWatch API actions allowed for the KEDA scaler"
  type        = list(string)
  default     = ["cloudwatch:GetMetricData", "cloudwatch:GetMetricStatistics", "cloudwatch:ListMetrics"]
}

variable "cloudwatch_resources" {
  description = "CloudWatch resource ARNs for the KEDA scaler"
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Tags to apply to the IAM role and policy"
  type        = map(string)
  default     = {}
}
