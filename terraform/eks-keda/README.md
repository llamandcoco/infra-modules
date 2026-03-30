# EKS KEDA Module

Installs KEDA via Helm with optional IRSA integration.

## Features

- Helm release for KEDA
- Optional IRSA service account annotation
- Namespaced watch mode support

## Quick Start

```hcl
module "eks_keda" {
  source = "github.com/llamandcoco/infra-modules//terraform/eks-keda?ref=<commit-sha>"

  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_certificate_authority_data
  cluster_name           = module.eks.cluster_name
  service_account_role_arn = module.keda_iam_role.role_arn
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
| [helm_release.keda](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_chart_name"></a> [chart\_name](#input\_chart\_name) | Helm chart name. | `string` | `"keda"` | no |
| <a name="input_chart_repository"></a> [chart\_repository](#input\_chart\_repository) | Helm chart repository URL. | `string` | `"https://kedacore.github.io/charts"` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Helm chart version. | `string` | `"2.18.1"` | no |
| <a name="input_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#input\_cluster\_ca\_certificate) | Base64-encoded EKS cluster CA data. | `string` | n/a | yes |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | EKS cluster endpoint. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS cluster name. | `string` | n/a | yes |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Whether to create the namespace. | `bool` | `true` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace to install KEDA into. | `string` | `"keda"` | no |
| <a name="input_release_name"></a> [release\_name](#input\_release\_name) | Helm release name. | `string` | `"keda"` | no |
| <a name="input_service_account_create"></a> [service\_account\_create](#input\_service\_account\_create) | Whether to create the service account. | `bool` | `true` | no |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | Service account name used by KEDA operator. | `string` | `"keda-operator"` | no |
| <a name="input_service_account_role_arn"></a> [service\_account\_role\_arn](#input\_service\_account\_role\_arn) | IAM role ARN for IRSA (optional). | `string` | `null` | no |
| <a name="input_values"></a> [values](#input\_values) | Additional Helm values (YAML strings). | `list(string)` | `[]` | no |
| <a name="input_watch_namespace"></a> [watch\_namespace](#input\_watch\_namespace) | Namespace to watch for scaled objects (optional, namespaced mode). | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_release_name"></a> [release\_name](#output\_release\_name) | Helm release name for KEDA. |
| <a name="output_release_status"></a> [release\_status](#output\_release\_status) | Helm release status for KEDA. |
<!-- END_TF_DOCS -->

</details>
