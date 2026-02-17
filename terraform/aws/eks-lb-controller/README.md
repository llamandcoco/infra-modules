# EKS AWS Load Balancer Controller Module

Installs the AWS Load Balancer Controller via Helm with IRSA support.

## Features

- Helm release for aws-load-balancer-controller
- IRSA service account annotation
- Cluster and VPC configuration inputs

## Quick Start

```hcl
module "eks_lb_controller" {
  source = "github.com/llamandcoco/infra-modules//terraform/eks-lb-controller?ref=<commit-sha>"

  cluster_endpoint         = module.eks.cluster_endpoint
  cluster_ca_certificate   = module.eks.cluster_certificate_authority_data
  cluster_name             = module.eks.cluster_name
  region                   = var.aws_region
  vpc_id                   = module.vpc.vpc_id
  service_account_role_arn = module.aws_lb_controller_role.role_arn
}
```

## Notes

- This module configures the Helm provider with `aws eks get-token` for authentication.
- AWS CLI access is required where Terraform runs.

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
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.17.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.aws_lb_controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_chart_name"></a> [chart\_name](#input\_chart\_name) | Helm chart name. | `string` | `"aws-load-balancer-controller"` | no |
| <a name="input_chart_repository"></a> [chart\_repository](#input\_chart\_repository) | Helm chart repository URL. | `string` | `"https://aws.github.io/eks-charts"` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Helm chart version. | `string` | `"1.7.0"` | no |
| <a name="input_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#input\_cluster\_ca\_certificate) | Base64-encoded EKS cluster CA data. | `string` | n/a | yes |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | EKS cluster endpoint. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS cluster name. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace to install the controller into. | `string` | `"kube-system"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region. | `string` | n/a | yes |
| <a name="input_release_name"></a> [release\_name](#input\_release\_name) | Helm release name. | `string` | `"aws-load-balancer-controller"` | no |
| <a name="input_service_account_create"></a> [service\_account\_create](#input\_service\_account\_create) | Whether to create the service account. | `bool` | `true` | no |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | Service account name used by the controller. | `string` | `"aws-load-balancer-controller"` | no |
| <a name="input_service_account_role_arn"></a> [service\_account\_role\_arn](#input\_service\_account\_role\_arn) | IAM role ARN for the AWS Load Balancer Controller service account. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID for the cluster. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_release_name"></a> [release\_name](#output\_release\_name) | Helm release name for the AWS Load Balancer Controller. |
| <a name="output_release_status"></a> [release\_status](#output\_release\_status) | Helm release status for the AWS Load Balancer Controller. |
<!-- END_TF_DOCS -->

</details>
