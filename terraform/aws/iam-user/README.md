# IAM User

Creates and manages AWS IAM users with programmatic and console access, policy attachments, and group memberships.

## Features

- Programmatic access with access key generation
- Console access with login profile creation (PGP-encrypted password output)
- Managed policy attachments
- Custom inline policy statements
- IAM group membership management
- Configurable user path
- Force destroy option for cleanup
- Comprehensive tagging support

## Quick Start

```hcl
module "user" {
  source = "github.com/llamandcoco/infra-modules//terraform/iam-user?ref=<commit-sha>"

  name = "application-user"
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic User | [`tests/basic/main.tf`](tests/basic/main.tf) |
| Advanced Configuration | [`tests/advanced/main.tf`](tests/advanced/main.tf) |

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
| [aws_iam_access_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_user.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_group_membership.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_group_membership) | resource |
| [aws_iam_user_login_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_login_profile) | resource |
| [aws_iam_user_policy.inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [aws_iam_user_policy_attachment.managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | IAM user name | `string` | n/a | yes |
| <a name="input_access_key_status"></a> [access\_key\_status](#input\_access\_key\_status) | Access key status (Active or Inactive) | `string` | `"Active"` | no |
| <a name="input_create_access_key"></a> [create\_access\_key](#input\_create\_access\_key) | Create programmatic access key for the user | `bool` | `false` | no |
| <a name="input_create_login_profile"></a> [create\_login\_profile](#input\_create\_login\_profile) | Create console login profile for the user | `bool` | `false` | no |
| <a name="input_custom_policy_statements"></a> [custom\_policy\_statements](#input\_custom\_policy\_statements) | List of custom IAM policy statements to attach as inline policies | <pre>list(object({<br/>    sid       = optional(string)<br/>    effect    = optional(string, "Allow")<br/>    actions   = list(string)<br/>    resources = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Delete user even if it has non-Terraform managed access keys or policies | `bool` | `false` | no |
| <a name="input_group_names"></a> [group\_names](#input\_group\_names) | List of IAM group names to add the user to | `list(string)` | `[]` | no |
| <a name="input_password_reset_required"></a> [password\_reset\_required](#input\_password\_reset\_required) | Require password reset on first login | `bool` | `true` | no |
| <a name="input_path"></a> [path](#input\_path) | Path for the IAM user | `string` | `"/"` | no |
| <a name="input_pgp_key"></a> [pgp\_key](#input\_pgp\_key) | PGP key used to encrypt the generated console password. Required when create\_login\_profile is true. | `string` | `null` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | List of IAM policy ARNs to attach to the user | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the IAM user | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_key_id"></a> [access\_key\_id](#output\_access\_key\_id) | Access key ID (if created) |
| <a name="output_access_key_secret"></a> [access\_key\_secret](#output\_access\_key\_secret) | Access key secret (sensitive - store securely) |
| <a name="output_attached_policy_arns"></a> [attached\_policy\_arns](#output\_attached\_policy\_arns) | List of managed policy ARNs attached to the user |
| <a name="output_group_memberships"></a> [group\_memberships](#output\_group\_memberships) | List of IAM groups the user belongs to |
| <a name="output_inline_policy_names"></a> [inline\_policy\_names](#output\_inline\_policy\_names) | List of inline policy names attached to the user |
| <a name="output_login_profile_created"></a> [login\_profile\_created](#output\_login\_profile\_created) | Whether a login profile was created |
| <a name="output_login_profile_key_fingerprint"></a> [login\_profile\_key\_fingerprint](#output\_login\_profile\_key\_fingerprint) | PGP key fingerprint used for password encryption (if login profile is created). |
| <a name="output_login_profile_password"></a> [login\_profile\_password](#output\_login\_profile\_password) | PGP-encrypted console password for login profile (sensitive). Requires pgp\_key input. |
| <a name="output_user_arn"></a> [user\_arn](#output\_user\_arn) | IAM user ARN |
| <a name="output_user_name"></a> [user\_name](#output\_user\_name) | IAM user name |
| <a name="output_user_unique_id"></a> [user\_unique\_id](#output\_user\_unique\_id) | IAM user unique ID |
<!-- END_TF_DOCS -->
</details>
