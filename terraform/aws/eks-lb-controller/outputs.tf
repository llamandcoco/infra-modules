output "release_name" {
  description = "Helm release name for the AWS Load Balancer Controller."
  value       = helm_release.aws_lb_controller.name
}

output "release_status" {
  description = "Helm release status for the AWS Load Balancer Controller."
  value       = helm_release.aws_lb_controller.status
}
