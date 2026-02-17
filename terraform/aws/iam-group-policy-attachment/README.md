# IAM Group Policy Attachment

Attaches an AWS managed or customer-managed IAM policy to an IAM group.

## Features

- Attach AWS managed policies to IAM groups
- Attach customer-managed policies to IAM groups
- Simple and straightforward policy attachment
- No credentials required for testing

## Quick Start

```hcl
module "group_policy" {
  source = "github.com/llamandcoco/infra-modules//terraform/iam-group-policy-attachment?ref=<commit-sha>"

  group_name = "developers"
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic Configuration | [`tests/basic/main.tf`](tests/basic/main.tf) |

**Usage:**
```bash
# View example
cat tests/basic/

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

## Resources

| Name | Type |
|------|------|
| [aws_iam_group_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_group_name"></a> [group\_name](#input\_group\_name) | Name of the IAM group to attach the policy to | `string` | n/a | yes |
| <a name="input_policy_arn"></a> [policy\_arn](#input\_policy\_arn) | ARN of the IAM policy to attach to the group | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_group_name"></a> [group\_name](#output\_group\_name) | Name of the IAM group |
| <a name="output_id"></a> [id](#output\_id) | ID of the policy attachment |
| <a name="output_policy_arn"></a> [policy\_arn](#output\_policy\_arn) | ARN of the attached IAM policy |
<!-- END_TF_DOCS -->
</details>
