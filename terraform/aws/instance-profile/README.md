# IAM Instance Profile Terraform Module

## Features

- EC2-assumable IAM role and instance profile
- Built-in inline policies for common AWS services:
  - ECR (Elastic Container Registry)
  - SSM Parameter Store
  - SSM Session Manager (interactive sessions)
  - CloudWatch Logs
  - CloudWatch Agent (metrics)
  - S3 (log storage)
  - KMS (encryption/decryption)
- Support for additional managed policy ARNs
- Support for custom inline policy statements
- Consistent tagging and naming convention for automated resources
- Lightweight companion module for EC2 instances and Auto Scaling Groups

## Quick Start

```hcl
module "instance_profile" {
  source = "github.com/llamandcoco/infra-modules//terraform/instance-profile?ref=<commit-sha>"

  name = "my-app"
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic | [`tests/basic/main.tf`](tests/basic/main.tf) |
| Advanced (Custom Policies) | [`tests/advanced/main.tf`](tests/advanced/main.tf) |

**Usage:**
```bash
# View example
cat tests/basic/main.tf

# Copy and adapt
cp -r tests/basic/ my-project/
```

## Testing

```bash
cd tests/basic && terraform init && terraform plan
```

<details>
<summary>Terraform Documentation</summary>

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.28.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.assume_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_policy_arns"></a> [additional\_policy\_arns](#input\_additional\_policy\_arns) | Additional managed IAM policy ARNs to attach to the role | `list(string)` | `[]` | no |
| <a name="input_custom_policy_statements"></a> [custom\_policy\_statements](#input\_custom\_policy\_statements) | Custom IAM policy statements to attach as inline policies | <pre>list(object({<br/>    sid       = optional(string)<br/>    actions   = list(string)<br/>    resources = list(string)<br/>    effect    = optional(string, "Allow")<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_cw_agent"></a> [enable\_cw\_agent](#input\_enable\_cw\_agent) | Attach CloudWatch Agent permissions (required for memory/disk metrics) | `bool` | `false` | no |
| <a name="input_enable_cw_logs"></a> [enable\_cw\_logs](#input\_enable\_cw\_logs) | Attach CloudWatch Logs permissions | `bool` | `true` | no |
| <a name="input_enable_ecr"></a> [enable\_ecr](#input\_enable\_ecr) | Attach ECR pull permissions | `bool` | `true` | no |
| <a name="input_enable_ssm"></a> [enable\_ssm](#input\_enable\_ssm) | Attach SSM GetParameter permissions | `bool` | `true` | no |
| <a name="input_enable_ssm_session_manager"></a> [enable\_ssm\_session\_manager](#input\_enable\_ssm\_session\_manager) | Attach SSM Session Manager permissions (for interactive sessions) | `bool` | `false` | no |
| <a name="input_kms_key_arns"></a> [kms\_key\_arns](#input\_kms\_key\_arns) | KMS key ARNs for decryption (ECR images, SSM parameters, S3 objects) | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for role and instance profile | `string` | n/a | yes |
| <a name="input_s3_log_buckets"></a> [s3\_log\_buckets](#input\_s3\_log\_buckets) | S3 bucket ARNs for log storage (session logs, CloudWatch logs export) | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_attached_policy_arns"></a> [attached\_policy\_arns](#output\_attached\_policy\_arns) | List of additional managed policy ARNs attached to the role |
| <a name="output_inline_policy_names"></a> [inline\_policy\_names](#output\_inline\_policy\_names) | Map of inline policy names attached to the role |
| <a name="output_instance_profile_arn"></a> [instance\_profile\_arn](#output\_instance\_profile\_arn) | Instance profile ARN |
| <a name="output_instance_profile_name"></a> [instance\_profile\_name](#output\_instance\_profile\_name) | Instance profile name |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | IAM role ARN |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | IAM role name |
<!-- END_TF_DOCS -->
</details>
