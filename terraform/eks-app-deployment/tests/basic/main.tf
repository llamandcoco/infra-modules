terraform {
  required_version = ">= 1.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

module "test_eks_app_deployment" {
  source = "../../"

  cluster_endpoint       = "https://example.com"
  cluster_ca_certificate = "ZHVtbXk="
  cluster_name           = "test-cluster"
  image                  = "123456789012.dkr.ecr.us-east-1.amazonaws.com/test:latest"
}

output "ingress_hostname" {
  description = "ALB hostname created by ingress"
  value       = module.test_eks_app_deployment.ingress_hostname
}

output "namespace" {
  value = module.test_eks_app_deployment.namespace
}

output "deployment_name" {
  value = module.test_eks_app_deployment.deployment_name
}
