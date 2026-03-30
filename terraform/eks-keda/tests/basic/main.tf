terraform {
  required_version = ">= 1.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

module "test_eks_keda" {
  source = "../../"

  cluster_endpoint       = "https://example.com"
  cluster_ca_certificate = "ZHVtbXk="
  cluster_name           = "test-cluster"
}

output "release_name" {
  description = "Helm release name"
  value       = module.test_eks_keda.release_name
}

output "release_status" {
  description = "Helm release status"
  value       = module.test_eks_keda.release_status
}
