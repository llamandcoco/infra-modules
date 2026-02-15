# IAM Policy Module

Creates a customer-managed IAM policy that can be attached to IAM roles, users, or groups.

## Features

- Create customer-managed IAM policies
- Support for JSON-formatted policy documents
- Support for Terraform policy document data sources
- Configurable policy name and description
- Tag support for policy organization
- Input validation for policy name and JSON format

## Quick Start

```hcl
module "s3_policy" {
  source = "github.com/llamandcoco/infra-modules//terraform/iam-policy?ref=<commit-sha>"

  name        = "my-s3-read-policy"
  description = "Allows read access to S3 bucket"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = ["arn:aws:s3:::my-bucket", "arn:aws:s3:::my-bucket/*"]
      }
    ]
  })
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic S3 Policy | [`tests/basic/main.tf`](tests/basic/main.tf) |
| With Policy Document | [`tests/with_policy_document/main.tf`](tests/with_policy_document/main.tf) |

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | Description of the IAM policy | `string` | `"IAM policy created by Terraform"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the IAM policy | `string` | n/a | yes |
| <a name="input_policy"></a> [policy](#input\_policy) | JSON-formatted IAM policy document | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the IAM policy | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policy_arn"></a> [policy\_arn](#output\_policy\_arn) | ARN of the IAM policy |
| <a name="output_policy_id"></a> [policy\_id](#output\_policy\_id) | ID of the IAM policy |
| <a name="output_policy_name"></a> [policy\_name](#output\_policy\_name) | Name of the IAM policy |
<!-- END_TF_DOCS -->
</details>
