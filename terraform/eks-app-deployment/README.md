# EKS App Deployment Module

Creates a Kubernetes namespace, Deployment, Service, Ingress (ALB), and HPA for a sample app on EKS.

## Features

- Namespace, Deployment, and Service
- Ingress configured for AWS Load Balancer Controller
- HPA with CPU-based scaling

## Quick Start

```hcl
module "eks_app" {
  source = "github.com/llamandcoco/infra-modules//terraform/eks-app-deployment?ref=<commit-sha>"

  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_certificate_authority_data
  cluster_name           = module.eks.cluster_name
  image                  = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest"
}
```

## Notes

- This module configures the Kubernetes provider with `aws eks get-token` for authentication.
- Ensure the AWS Load Balancer Controller is installed before applying the Ingress.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|----------|
| Basic | [`tests/basic/main.tf`](tests/basic/main.tf) |

## Testing

```bash
cd tests/basic
terraform init -backend=false
terraform validate
```

<details>
<summary>Terraform Documentation</summary>

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.38.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_deployment.app](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_horizontal_pod_autoscaler_v2.app](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/horizontal_pod_autoscaler_v2) | resource |
| [kubernetes_ingress_v1.app](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_namespace.app](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_service.app](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_healthcheck_path"></a> [alb\_healthcheck\_path](#input\_alb\_healthcheck\_path) | ALB healthcheck path. | `string` | `"/healthz"` | no |
| <a name="input_alb_healthcheck_protocol"></a> [alb\_healthcheck\_protocol](#input\_alb\_healthcheck\_protocol) | ALB healthcheck protocol. | `string` | `"HTTP"` | no |
| <a name="input_alb_listen_ports_json"></a> [alb\_listen\_ports\_json](#input\_alb\_listen\_ports\_json) | ALB listen ports annotation value as JSON string. | `string` | `"[{\"HTTP\":80}]"` | no |
| <a name="input_alb_scheme"></a> [alb\_scheme](#input\_alb\_scheme) | ALB scheme (internet-facing or internal). | `string` | `"internet-facing"` | no |
| <a name="input_alb_target_group_attributes"></a> [alb\_target\_group\_attributes](#input\_alb\_target\_group\_attributes) | ALB target group attributes annotation value. | `string` | `"deregistration_delay.timeout_seconds=30,slow_start.duration_seconds=0"` | no |
| <a name="input_alb_target_type"></a> [alb\_target\_type](#input\_alb\_target\_type) | ALB target type. | `string` | `"ip"` | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Application name label for deployment and pods. | `string` | `"lab-app"` | no |
| <a name="input_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#input\_cluster\_ca\_certificate) | Base64-encoded EKS cluster CA data. | `string` | n/a | yes |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | EKS cluster endpoint. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS cluster name. | `string` | n/a | yes |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Container port exposed by the app. | `number` | `8080` | no |
| <a name="input_healthcheck_path"></a> [healthcheck\_path](#input\_healthcheck\_path) | HTTP path for liveness/readiness probes. | `string` | `"/healthz"` | no |
| <a name="input_hpa_cpu_utilization"></a> [hpa\_cpu\_utilization](#input\_hpa\_cpu\_utilization) | Target CPU utilization percentage for HPA. | `number` | `60` | no |
| <a name="input_hpa_max_replicas"></a> [hpa\_max\_replicas](#input\_hpa\_max\_replicas) | Maximum HPA replicas. | `number` | `6` | no |
| <a name="input_hpa_min_replicas"></a> [hpa\_min\_replicas](#input\_hpa\_min\_replicas) | Minimum HPA replicas. | `number` | `1` | no |
| <a name="input_hpa_name"></a> [hpa\_name](#input\_hpa\_name) | HPA resource name. | `string` | `"lab-app-hpa"` | no |
| <a name="input_hpa_scale_down_percent"></a> [hpa\_scale\_down\_percent](#input\_hpa\_scale\_down\_percent) | Scale down percent policy value. | `number` | `50` | no |
| <a name="input_hpa_scale_down_period_seconds"></a> [hpa\_scale\_down\_period\_seconds](#input\_hpa\_scale\_down\_period\_seconds) | Scale down policy period seconds. | `number` | `60` | no |
| <a name="input_hpa_scale_down_select_policy"></a> [hpa\_scale\_down\_select\_policy](#input\_hpa\_scale\_down\_select\_policy) | Select policy for scale down when multiple policies exist (Disabled, Max, Min). | `string` | `"Max"` | no |
| <a name="input_hpa_scale_down_stabilization_window_seconds"></a> [hpa\_scale\_down\_stabilization\_window\_seconds](#input\_hpa\_scale\_down\_stabilization\_window\_seconds) | Scale down stabilization window seconds. | `number` | `300` | no |
| <a name="input_hpa_scale_up_percent"></a> [hpa\_scale\_up\_percent](#input\_hpa\_scale\_up\_percent) | Scale up percent policy value. | `number` | `100` | no |
| <a name="input_hpa_scale_up_period_seconds"></a> [hpa\_scale\_up\_period\_seconds](#input\_hpa\_scale\_up\_period\_seconds) | Scale up policy period seconds. | `number` | `60` | no |
| <a name="input_hpa_scale_up_select_policy"></a> [hpa\_scale\_up\_select\_policy](#input\_hpa\_scale\_up\_select\_policy) | Select policy for scale up when multiple policies exist (Disabled, Max, Min). | `string` | `"Max"` | no |
| <a name="input_hpa_scale_up_stabilization_window_seconds"></a> [hpa\_scale\_up\_stabilization\_window\_seconds](#input\_hpa\_scale\_up\_stabilization\_window\_seconds) | Scale up stabilization window seconds. | `number` | `60` | no |
| <a name="input_image"></a> [image](#input\_image) | Container image to deploy. | `string` | n/a | yes |
| <a name="input_ingress_class"></a> [ingress\_class](#input\_ingress\_class) | Ingress class name. | `string` | `"alb"` | no |
| <a name="input_ingress_name"></a> [ingress\_name](#input\_ingress\_name) | Kubernetes ingress name. | `string` | `"lab-app-ingress"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace for the app. | `string` | `"app"` | no |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Initial replica count. | `number` | `2` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Kubernetes service name. | `string` | `"lab-app-service"` | no |
| <a name="input_service_port"></a> [service\_port](#input\_service\_port) | Service port exposed internally. | `number` | `80` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_deployment_name"></a> [deployment\_name](#output\_deployment\_name) | Kubernetes Deployment name for the app. |
| <a name="output_ingress_hostname"></a> [ingress\_hostname](#output\_ingress\_hostname) | ALB hostname created by ingress |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Kubernetes namespace where the app is deployed. |
<!-- END_TF_DOCS -->

</details>
