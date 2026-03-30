# KEDA IAM Role Module

Creates an IRSA IAM role for KEDA to read CloudWatch metrics (RPS-based scaling).

## Features

- OIDC trust policy for KEDA service account
- CloudWatch read permissions (default: GetMetricData)
- Taggable IAM resources

## Quick Start

```hcl
module "keda_iam_role" {
  source = "github.com/llamandcoco/infra-modules//terraform/keda-iam-role?ref=<commit-sha>"

  role_name         = "my-keda-role"
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider     = module.eks.oidc_provider_url
}
```

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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_actions"></a> [cloudwatch\_actions](#input\_cloudwatch\_actions) | CloudWatch API actions allowed for the KEDA scaler | `list(string)` | <pre>[<br/>  "cloudwatch:GetMetricData",<br/>  "cloudwatch:GetMetricStatistics",<br/>  "cloudwatch:ListMetrics"<br/>]</pre> | no |
| <a name="input_cloudwatch_resources"></a> [cloudwatch\_resources](#input\_cloudwatch\_resources) | CloudWatch resource ARNs for the KEDA scaler | `list(string)` | <pre>[<br/>  "*"<br/>]</pre> | no |
| <a name="input_oidc_provider"></a> [oidc\_provider](#input\_oidc\_provider) | OIDC provider URL (without https://) | `string` | n/a | yes |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | ARN of the EKS OIDC provider | `string` | n/a | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name of the KEDA IAM role | `string` | n/a | yes |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | Kubernetes service account name for KEDA operator | `string` | `"keda-operator"` | no |
| <a name="input_service_account_namespace"></a> [service\_account\_namespace](#input\_service\_account\_namespace) | Kubernetes namespace for the KEDA service account | `string` | `"keda"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the IAM role and policy | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policy_arn"></a> [policy\_arn](#output\_policy\_arn) | ARN of the KEDA IAM policy |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN of the KEDA IAM role |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name of the KEDA IAM role |
<!-- END_TF_DOCS -->

</details>
