variable "enabled" {
  type        = bool
  description = "Whether to create the ScaledObject."
  default     = true
}

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

variable "namespace" {
  type        = string
  description = "Namespace for the ScaledObject."
  default     = "app"
}

variable "scaledobject_name" {
  type        = string
  description = "Name of the ScaledObject."
  default     = "alb-rps"
}

variable "scale_target_name" {
  type        = string
  description = "Name of the Kubernetes Deployment to scale."
}

variable "min_replicas" {
  type        = number
  description = "Minimum replica count."
  default     = 1
}

variable "max_replicas" {
  type        = number
  description = "Maximum replica count."
  default     = 10
}

variable "polling_interval" {
  type        = number
  description = "Polling interval in seconds."
  default     = 15
}

variable "cooldown_period" {
  type        = number
  description = "Cooldown period in seconds."
  default     = 60
}

variable "trigger_type" {
  type        = string
  description = "KEDA trigger type."
  default     = "aws-cloudwatch"
}

variable "metric_namespace" {
  type        = string
  description = "CloudWatch metric namespace."
  default     = "AWS/ApplicationELB"
}

variable "metric_name" {
  type        = string
  description = "CloudWatch metric name."
  default     = "RequestCountPerTarget"
}

variable "metric_statistic" {
  type        = string
  description = "CloudWatch metric statistic."
  default     = "Sum"
}

variable "target_metric_value" {
  type        = number
  description = "Target metric value for scaling."
  default     = 100
}

variable "region" {
  type        = string
  description = "AWS region for CloudWatch metric."
}

variable "identity_owner" {
  type        = string
  description = "KEDA identity owner (operator or trigger)."
  default     = "operator"
}

variable "dimension_name" {
  type        = string
  description = "CloudWatch dimension name (optional)."
  default     = "TargetGroup"
}

variable "dimension_value" {
  type        = string
  description = "CloudWatch dimension value (optional)."
  default     = null
}

variable "additional_trigger_metadata" {
  type        = map(string)
  description = "Additional metadata for the KEDA trigger."
  default     = {}
}
