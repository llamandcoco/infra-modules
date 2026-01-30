output "ingress_hostname" {
  description = "ALB hostname created by ingress"
  value       = try(kubernetes_ingress_v1.app.status[0].load_balancer[0].ingress[0].hostname, "pending")
}

output "namespace" {
  description = "Kubernetes namespace where the app is deployed."
  value       = kubernetes_namespace.app.metadata[0].name
}

output "deployment_name" {
  description = "Kubernetes Deployment name for the app."
  value       = kubernetes_deployment.app.metadata[0].name
}
