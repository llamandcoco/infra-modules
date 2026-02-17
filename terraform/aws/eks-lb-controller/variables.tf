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

variable "region" {
  type        = string
  description = "AWS region."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the cluster."
}

variable "service_account_role_arn" {
  type        = string
  description = "IAM role ARN for the AWS Load Balancer Controller service account."
}

variable "release_name" {
  type        = string
  description = "Helm release name."
  default     = "aws-load-balancer-controller"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace to install the controller into."
  default     = "kube-system"
}

variable "chart_repository" {
  type        = string
  description = "Helm chart repository URL."
  default     = "https://aws.github.io/eks-charts"
}

variable "chart_name" {
  type        = string
  description = "Helm chart name."
  default     = "aws-load-balancer-controller"
}

variable "chart_version" {
  type        = string
  description = "Helm chart version."
  default     = "1.7.0"
}

variable "service_account_name" {
  type        = string
  description = "Service account name used by the controller."
  default     = "aws-load-balancer-controller"
}

variable "service_account_create" {
  type        = bool
  description = "Whether to create the service account."
  default     = true
}
