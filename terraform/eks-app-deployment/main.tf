# -----------------------------------------------------------------------------
# EKS App Deployment (Kubernetes resources)
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

resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app.metadata[0].name

    labels = {
      app = var.app_name
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        container {
          name  = "app"
          image = var.image

          port {
            container_port = var.container_port
            name           = "http"
          }

          liveness_probe {
            http_get {
              path = var.healthcheck_path
              port = var.container_port
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = var.healthcheck_path
              port = var.container_port
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name      = var.service_name
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    selector = {
      app = var.app_name
    }

    port {
      port        = var.service_port
      target_port = var.container_port
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "app" {
  metadata {
    name      = var.ingress_name
    namespace = kubernetes_namespace.app.metadata[0].name

    annotations = {
      "kubernetes.io/ingress.class"                       = var.ingress_class
      "alb.ingress.kubernetes.io/scheme"                  = var.alb_scheme
      "alb.ingress.kubernetes.io/target-type"             = var.alb_target_type
      "alb.ingress.kubernetes.io/healthcheck-path"        = var.alb_healthcheck_path
      "alb.ingress.kubernetes.io/healthcheck-protocol"    = var.alb_healthcheck_protocol
      "alb.ingress.kubernetes.io/listen-ports"            = var.alb_listen_ports_json
      "alb.ingress.kubernetes.io/target-group-attributes" = var.alb_target_group_attributes
    }
  }

  spec {
    ingress_class_name = var.ingress_class

    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.app.metadata[0].name
              port {
                number = var.service_port
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.app]
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "app" {
  metadata {
    name      = var.hpa_name
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    min_replicas = var.hpa_min_replicas
    max_replicas = var.hpa_max_replicas

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.app.metadata[0].name
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = var.hpa_cpu_utilization
        }
      }
    }

    behavior {
      scale_down {
        select_policy                = var.hpa_scale_down_select_policy
        stabilization_window_seconds = var.hpa_scale_down_stabilization_window_seconds
        policy {
          type           = "Percent"
          value          = var.hpa_scale_down_percent
          period_seconds = var.hpa_scale_down_period_seconds
        }
      }
      scale_up {
        select_policy                = var.hpa_scale_up_select_policy
        stabilization_window_seconds = var.hpa_scale_up_stabilization_window_seconds
        policy {
          type           = "Percent"
          value          = var.hpa_scale_up_percent
          period_seconds = var.hpa_scale_up_period_seconds
        }
      }
    }
  }
}
