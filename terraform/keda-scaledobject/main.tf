# -----------------------------------------------------------------------------
# KEDA ScaledObject (AWS CloudWatch)
# -----------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
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

locals {
  base_metadata = {
    namespace         = var.metric_namespace
    metricName        = var.metric_name
    statistic         = var.metric_statistic
    targetMetricValue = tostring(var.target_metric_value)
    region            = var.region
    identityOwner     = var.identity_owner
  }

  dimension_metadata = var.dimension_name != null && var.dimension_value != null ? {
    dimensionName  = var.dimension_name
    dimensionValue = var.dimension_value
  } : {}

  trigger_metadata = merge(local.base_metadata, local.dimension_metadata, var.additional_trigger_metadata)
}

resource "kubernetes_manifest" "scaledobject" {
  count = var.enabled ? 1 : 0

  manifest = {
    apiVersion = "keda.sh/v1alpha1"
    kind       = "ScaledObject"
    metadata = {
      name      = var.scaledobject_name
      namespace = var.namespace
    }
    spec = {
      scaleTargetRef = {
        name = var.scale_target_name
      }
      minReplicaCount = var.min_replicas
      maxReplicaCount = var.max_replicas
      pollingInterval = var.polling_interval
      cooldownPeriod  = var.cooldown_period
      triggers = [
        {
          type     = var.trigger_type
          metadata = local.trigger_metadata
        }
      ]
    }
  }
}
