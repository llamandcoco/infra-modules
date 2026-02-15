# IAM User Group Membership

Manages IAM user memberships in one or more IAM groups.

## Features

- Add IAM users to multiple groups
- Exclusive group membership management via Terraform
- Input validation for user and group names
- Simple and declarative configuration

## Quick Start

```hcl
module "user_groups" {
  source = "github.com/llamandcoco/infra-modules//terraform/iam-user-group-membership?ref=<commit-sha>"

  user_name   = "john.doe"
  group_names = ["developers", "admins"]
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic Configuration | [`tests/basic/main.tf`](tests/basic/main.tf) |
| Multiple Groups | [`tests/multiple-groups/main.tf`](tests/multiple-groups/main.tf) |

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
| [aws_iam_user_group_membership.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_group_membership) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_group_names"></a> [group\_names](#input\_group\_names) | List of IAM group names to add the user to | `list(string)` | n/a | yes |
| <a name="input_user_name"></a> [user\_name](#input\_user\_name) | Name of the IAM user | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_group_names"></a> [group\_names](#output\_group\_names) | List of IAM group names the user is a member of |
| <a name="output_membership_id"></a> [membership\_id](#output\_membership\_id) | ID of the IAM user group membership resource |
| <a name="output_user_name"></a> [user\_name](#output\_user\_name) | Name of the IAM user |
<!-- END_TF_DOCS -->
</details>
