# KEDA ScaledObject Module

Creates a KEDA ScaledObject using the Kubernetes provider. Designed for AWS
CloudWatch metrics (e.g., ALB RequestCountPerTarget) with IRSA.

## Features

- ScaledObject with AWS CloudWatch trigger
- Configurable polling/cooldown and target value
- Optional extra trigger metadata

## Quick Start

```hcl
module "keda_scaledobject" {
  source = "github.com/llamandcoco/infra-modules//terraform/keda-scaledobject?ref=<commit-sha>"

  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_certificate_authority_data
  cluster_name           = module.eks.cluster_name

  namespace         = "app"
  scale_target_name = "lab-app"
  region            = var.aws_region
  dimension_value   = "targetgroup/xxx/yyy"
}
```

## Notes

- Requires KEDA CRDs installed before apply.
- This module configures the Kubernetes provider with `aws eks get-token`.

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
| [kubernetes_manifest.scaledobject](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_trigger_metadata"></a> [additional\_trigger\_metadata](#input\_additional\_trigger\_metadata) | Additional metadata for the KEDA trigger. | `map(string)` | `{}` | no |
| <a name="input_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#input\_cluster\_ca\_certificate) | Base64-encoded EKS cluster CA data. | `string` | n/a | yes |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | EKS cluster endpoint. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS cluster name. | `string` | n/a | yes |
| <a name="input_cooldown_period"></a> [cooldown\_period](#input\_cooldown\_period) | Cooldown period in seconds. | `number` | `60` | no |
| <a name="input_dimension_name"></a> [dimension\_name](#input\_dimension\_name) | CloudWatch dimension name (optional). | `string` | `"TargetGroup"` | no |
| <a name="input_dimension_value"></a> [dimension\_value](#input\_dimension\_value) | CloudWatch dimension value (optional). | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether to create the ScaledObject. | `bool` | `true` | no |
| <a name="input_identity_owner"></a> [identity\_owner](#input\_identity\_owner) | KEDA identity owner (operator or trigger). | `string` | `"operator"` | no |
| <a name="input_max_replicas"></a> [max\_replicas](#input\_max\_replicas) | Maximum replica count. | `number` | `10` | no |
| <a name="input_metric_name"></a> [metric\_name](#input\_metric\_name) | CloudWatch metric name. | `string` | `"RequestCountPerTarget"` | no |
| <a name="input_metric_namespace"></a> [metric\_namespace](#input\_metric\_namespace) | CloudWatch metric namespace. | `string` | `"AWS/ApplicationELB"` | no |
| <a name="input_metric_statistic"></a> [metric\_statistic](#input\_metric\_statistic) | CloudWatch metric statistic. | `string` | `"Sum"` | no |
| <a name="input_min_replicas"></a> [min\_replicas](#input\_min\_replicas) | Minimum replica count. | `number` | `1` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the ScaledObject. | `string` | `"app"` | no |
| <a name="input_polling_interval"></a> [polling\_interval](#input\_polling\_interval) | Polling interval in seconds. | `number` | `15` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region for CloudWatch metric. | `string` | n/a | yes |
| <a name="input_scale_target_name"></a> [scale\_target\_name](#input\_scale\_target\_name) | Name of the Kubernetes Deployment to scale. | `string` | n/a | yes |
| <a name="input_scaledobject_name"></a> [scaledobject\_name](#input\_scaledobject\_name) | Name of the ScaledObject. | `string` | `"alb-rps"` | no |
| <a name="input_target_metric_value"></a> [target\_metric\_value](#input\_target\_metric\_value) | Target metric value for scaling. | `number` | `100` | no |
| <a name="input_trigger_type"></a> [trigger\_type](#input\_trigger\_type) | KEDA trigger type. | `string` | `"aws-cloudwatch"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_scaledobject_name"></a> [scaledobject\_name](#output\_scaledobject\_name) | Name of the KEDA ScaledObject. |
<!-- END_TF_DOCS -->

</details>
