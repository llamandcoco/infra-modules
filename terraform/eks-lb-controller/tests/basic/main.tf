terraform {
  required_version = ">= 1.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

module "test_eks_lb_controller" {
  source = "../../"

  cluster_endpoint         = "https://example.com"
  cluster_ca_certificate   = "ZHVtbXk="
  cluster_name             = "test-cluster"
  region                   = "us-east-1"
  vpc_id                   = "vpc-12345678"
  service_account_role_arn = "arn:aws:iam::123456789012:role/test-lb-controller"
}

output "release_name" {
  description = "Helm release name"
  value       = module.test_eks_lb_controller.release_name
}

output "release_status" {
  description = "Helm release status"
  value       = module.test_eks_lb_controller.release_status
}
