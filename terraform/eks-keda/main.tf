# -----------------------------------------------------------------------------
# EKS KEDA (Helm)
# -----------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        var.cluster_name
      ]
    }
  }
}

resource "helm_release" "keda" {
  name             = var.release_name
  repository       = var.chart_repository
  chart            = var.chart_name
  namespace        = var.namespace
  version          = var.chart_version
  create_namespace = var.create_namespace

  values = var.values

  set {
    name  = "serviceAccount.create"
    value = tostring(var.service_account_create)
  }

  set {
    name  = "serviceAccount.name"
    value = var.service_account_name
  }

  dynamic "set" {
    for_each = var.service_account_role_arn != null ? [var.service_account_role_arn] : []
    content {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = set.value
    }
  }

  dynamic "set" {
    for_each = var.watch_namespace != null ? [var.watch_namespace] : []
    content {
      name  = "watchNamespace"
      value = set.value
    }
  }
}
