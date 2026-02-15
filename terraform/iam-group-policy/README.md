# IAM Group Policy

Create IAM groups with built-in and custom policies for user access management.

## Features

- IAM group creation with configurable path
- Built-in inline policies for common AWS services (S3, EC2, DynamoDB, CloudWatch Logs, SSM)
- Support for AWS managed policy attachments
- Support for custom inline policy statements
- Automatic group membership management
- Flexible permission toggles for granular access control

## Quick Start

```hcl
module "developers" {
  source = "github.com/llamandcoco/infra-modules//terraform/iam-group-policy?ref=<commit-sha>"

  name = "developers"
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic (Read-only permissions) | [`tests/basic/main.tf`](tests/basic/main.tf) |
| Advanced (Multiple policies, users) | [`tests/advanced/main.tf`](tests/advanced/main.tf) |

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | resource |
| [aws_iam_group_membership.members](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_membership) | resource |
| [aws_iam_group_policy.inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy) | resource |
| [aws_iam_group_policy_attachment.managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |
| [aws_iam_policy_document.inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_policy_statements"></a> [custom\_policy\_statements](#input\_custom\_policy\_statements) | Custom IAM policy statements to attach as inline policies | <pre>list(object({<br/>    sid       = optional(string)<br/>    actions   = list(string)<br/>    resources = list(string)<br/>    effect    = optional(string, "Allow")<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_dynamodb_read"></a> [enable\_dynamodb\_read](#input\_enable\_dynamodb\_read) | Attach DynamoDB read permissions | `bool` | `false` | no |
| <a name="input_enable_dynamodb_write"></a> [enable\_dynamodb\_write](#input\_enable\_dynamodb\_write) | Attach DynamoDB write permissions | `bool` | `false` | no |
| <a name="input_enable_ec2_read"></a> [enable\_ec2\_read](#input\_enable\_ec2\_read) | Attach EC2 read-only permissions | `bool` | `false` | no |
| <a name="input_enable_logs_read"></a> [enable\_logs\_read](#input\_enable\_logs\_read) | Attach CloudWatch Logs read permissions | `bool` | `false` | no |
| <a name="input_enable_s3_read"></a> [enable\_s3\_read](#input\_enable\_s3\_read) | Attach S3 read permissions | `bool` | `false` | no |
| <a name="input_enable_s3_write"></a> [enable\_s3\_write](#input\_enable\_s3\_write) | Attach S3 write permissions | `bool` | `false` | no |
| <a name="input_enable_ssm_read"></a> [enable\_ssm\_read](#input\_enable\_ssm\_read) | Attach SSM Parameter Store read permissions | `bool` | `false` | no |
| <a name="input_managed_policy_arns"></a> [managed\_policy\_arns](#input\_managed\_policy\_arns) | List of managed IAM policy ARNs to attach to the group | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the IAM group | `string` | n/a | yes |
| <a name="input_path"></a> [path](#input\_path) | Path for the IAM group | `string` | `"/"` | no |
| <a name="input_users"></a> [users](#input\_users) | List of IAM users to add to the group | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_group_arn"></a> [group\_arn](#output\_group\_arn) | IAM group ARN |
| <a name="output_group_id"></a> [group\_id](#output\_group\_id) | IAM group ID |
| <a name="output_group_name"></a> [group\_name](#output\_group\_name) | IAM group name |
| <a name="output_inline_policy_names"></a> [inline\_policy\_names](#output\_inline\_policy\_names) | Map of inline policy names attached to the group |
| <a name="output_managed_policy_arns"></a> [managed\_policy\_arns](#output\_managed\_policy\_arns) | List of managed policy ARNs attached to the group |
| <a name="output_users"></a> [users](#output\_users) | List of users in the group |
<!-- END_TF_DOCS -->
</details>
