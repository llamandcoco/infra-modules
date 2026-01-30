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
  description = "Kubernetes namespace for the app."
  default     = "app"
}

variable "app_name" {
  type        = string
  description = "Application name label for deployment and pods."
  default     = "lab-app"
}

variable "service_name" {
  type        = string
  description = "Kubernetes service name."
  default     = "lab-app-service"
}

variable "ingress_name" {
  type        = string
  description = "Kubernetes ingress name."
  default     = "lab-app-ingress"
}

variable "hpa_name" {
  type        = string
  description = "HPA resource name."
  default     = "lab-app-hpa"
}

variable "image" {
  type        = string
  description = "Container image to deploy."
}

variable "replicas" {
  type        = number
  description = "Initial replica count."
  default     = 2
}

variable "container_port" {
  type        = number
  description = "Container port exposed by the app."
  default     = 8080
}

variable "service_port" {
  type        = number
  description = "Service port exposed internally."
  default     = 80
}

variable "healthcheck_path" {
  type        = string
  description = "HTTP path for liveness/readiness probes."
  default     = "/healthz"
}

variable "ingress_class" {
  type        = string
  description = "Ingress class name."
  default     = "alb"
}

variable "alb_scheme" {
  type        = string
  description = "ALB scheme (internet-facing or internal)."
  default     = "internet-facing"
}

variable "alb_target_type" {
  type        = string
  description = "ALB target type."
  default     = "ip"
}

variable "alb_healthcheck_path" {
  type        = string
  description = "ALB healthcheck path."
  default     = "/healthz"
}

variable "alb_healthcheck_protocol" {
  type        = string
  description = "ALB healthcheck protocol."
  default     = "HTTP"
}

variable "alb_listen_ports_json" {
  type        = string
  description = "ALB listen ports annotation value as JSON string."
  default     = "[{\"HTTP\":80}]"
}

variable "alb_target_group_attributes" {
  type        = string
  description = "ALB target group attributes annotation value."
  default     = "deregistration_delay.timeout_seconds=30,slow_start.duration_seconds=0"
}

variable "hpa_min_replicas" {
  type        = number
  description = "Minimum HPA replicas."
  default     = 1
}

variable "hpa_max_replicas" {
  type        = number
  description = "Maximum HPA replicas."
  default     = 6
}

variable "hpa_cpu_utilization" {
  type        = number
  description = "Target CPU utilization percentage for HPA."
  default     = 60
}

variable "hpa_scale_down_stabilization_window_seconds" {
  type        = number
  description = "Scale down stabilization window seconds."
  default     = 300
}

variable "hpa_scale_down_select_policy" {
  type        = string
  description = "Select policy for scale down when multiple policies exist (Disabled, Max, Min)."
  default     = "Max"
}

variable "hpa_scale_down_percent" {
  type        = number
  description = "Scale down percent policy value."
  default     = 50
}

variable "hpa_scale_down_period_seconds" {
  type        = number
  description = "Scale down policy period seconds."
  default     = 60
}

variable "hpa_scale_up_stabilization_window_seconds" {
  type        = number
  description = "Scale up stabilization window seconds."
  default     = 60
}

variable "hpa_scale_up_select_policy" {
  type        = string
  description = "Select policy for scale up when multiple policies exist (Disabled, Max, Min)."
  default     = "Max"
}

variable "hpa_scale_up_percent" {
  type        = number
  description = "Scale up percent policy value."
  default     = 100
}

variable "hpa_scale_up_period_seconds" {
  type        = number
  description = "Scale up policy period seconds."
  default     = 60
}
