terraform {
  required_version = ">= 1.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

module "test_keda_scaledobject" {
  source = "../../"

  cluster_endpoint       = "https://example.com"
  cluster_ca_certificate = "ZHVtbXk="
  cluster_name           = "test-cluster"

  scale_target_name = "lab-app"
  region            = "us-east-1"
  dimension_value   = "targetgroup/abc/123"
}

output "scaledobject_name" {
  description = "ScaledObject name"
  value       = module.test_keda_scaledobject.scaledobject_name
}
