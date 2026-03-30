variable "cluster_endpoint" {
  type        = string
  description = "EKS cluster endpoint."
}

variable "cluster_ca_certificate" {
  type        = string
  description = "Base64-encoded EKS cluster CA data."
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name."
}

variable "release_name" {
  type        = string
  description = "Helm release name."
  default     = "keda"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace to install KEDA into."
  default     = "keda"
}

variable "create_namespace" {
  type        = bool
  description = "Whether to create the namespace."
  default     = true
}

variable "chart_repository" {
  type        = string
  description = "Helm chart repository URL."
  default     = "https://kedacore.github.io/charts"
}

variable "chart_name" {
  type        = string
  description = "Helm chart name."
  default     = "keda"
}

variable "chart_version" {
  type        = string
  description = "Helm chart version."
  default     = "2.18.1"
}

variable "service_account_name" {
  type        = string
  description = "Service account name used by KEDA operator."
  default     = "keda-operator"
}

variable "service_account_create" {
  type        = bool
  description = "Whether to create the service account."
  default     = true
}

variable "service_account_role_arn" {
  type        = string
  description = "IAM role ARN for IRSA (optional)."
  default     = null
}

variable "watch_namespace" {
  type        = string
  description = "Namespace to watch for scaled objects (optional, namespaced mode)."
  default     = null
}

variable "values" {
  type        = list(string)
  description = "Additional Helm values (YAML strings)."
  default     = []
}
