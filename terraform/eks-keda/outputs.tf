output "release_name" {
  description = "Helm release name for KEDA."
  value       = helm_release.keda.name
}

output "release_status" {
  description = "Helm release status for KEDA."
  value       = helm_release.keda.status
}
