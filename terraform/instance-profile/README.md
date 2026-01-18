# IAM Instance Profile

Minimal module to create an EC2 IAM Role and Instance Profile with optional permissions for ECR image pull, SSM GetParameter, and CloudWatch Logs.

## Features
- EC2-assumable IAM Role
- Instance Profile
- Optional inline policies:
  - ECR (DescribeImages, GetAuthorizationToken, BatchGetImage)
  - SSM (GetParameter, GetParameters)
  - CloudWatch Logs (CreateLogGroup, CreateLogStream, PutLogEvents)

## Testing
```
terraform init -backend=false
terraform plan
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
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
| [aws_iam_policy.cw_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.cw_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cw_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cw_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.assume_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cw_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cw_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_cw_agent"></a> [enable\_cw\_agent](#input\_enable\_cw\_agent) | Attach CloudWatch Agent permissions (required for memory/disk metrics) | `bool` | `false` | no |
| <a name="input_enable_cw_logs"></a> [enable\_cw\_logs](#input\_enable\_cw\_logs) | Attach CloudWatch Logs permissions | `bool` | `true` | no |
| <a name="input_enable_ecr"></a> [enable\_ecr](#input\_enable\_ecr) | Attach ECR pull permissions | `bool` | `true` | no |
| <a name="input_enable_ssm"></a> [enable\_ssm](#input\_enable\_ssm) | Attach SSM GetParameter permissions | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for role and instance profile | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_profile_name"></a> [instance\_profile\_name](#output\_instance\_profile\_name) | Instance profile name |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | IAM role name |
<!-- END_TF_DOCS -->
