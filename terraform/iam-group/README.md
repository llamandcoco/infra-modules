# IAM Group

Terraform module for creating and managing AWS IAM groups with policy attachments and user membership.

## Features

- IAM group with configurable name and path
- Managed policy attachments (AWS and customer managed)
- Inline policy support
- User membership management

## Quick Start

```hcl
module "iam_group" {
  source = "github.com/llamandcoco/infra-modules//terraform/iam-group?ref=<commit-sha>"

  name = "developers"
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic Configuration | [`tests/basic/main.tf`](tests/basic/main.tf) |
| Advanced (Inline Policies + Members) | [`tests/advanced/main.tf`](tests/advanced/main.tf) |

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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | resource |
| [aws_iam_group_membership.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_membership) | resource |
| [aws_iam_group_policy.inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy) | resource |
| [aws_iam_group_policy_attachment.managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_inline_policies"></a> [inline\_policies](#input\_inline\_policies) | Map of inline policy names to JSON policy documents | `map(string)` | `{}` | no |
| <a name="input_managed_policy_arns"></a> [managed\_policy\_arns](#input\_managed\_policy\_arns) | List of IAM managed policy ARNs to attach to the group | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the IAM group | `string` | n/a | yes |
| <a name="input_path"></a> [path](#input\_path) | Path for the IAM group | `string` | `"/"` | no |
| <a name="input_user_names"></a> [user\_names](#input\_user\_names) | List of IAM user names to add to the group | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_attached_policy_arns"></a> [attached\_policy\_arns](#output\_attached\_policy\_arns) | List of managed policy ARNs attached to the group |
| <a name="output_group_arn"></a> [group\_arn](#output\_group\_arn) | ARN of the IAM group |
| <a name="output_group_id"></a> [group\_id](#output\_group\_id) | ID of the IAM group |
| <a name="output_group_name"></a> [group\_name](#output\_group\_name) | Name of the IAM group |
| <a name="output_group_unique_id"></a> [group\_unique\_id](#output\_group\_unique\_id) | Unique ID of the IAM group |
| <a name="output_inline_policy_names"></a> [inline\_policy\_names](#output\_inline\_policy\_names) | List of inline policy names attached to the group |
| <a name="output_member_user_names"></a> [member\_user\_names](#output\_member\_user\_names) | List of user names that are members of the group |
<!-- END_TF_DOCS -->
</details>
