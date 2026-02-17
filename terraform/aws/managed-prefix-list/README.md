# Managed Prefix List Terraform Module

A Terraform module for creating and managing AWS EC2 Managed Prefix Lists for simplified CIDR block management across security groups and route tables.

## Features

- IPv4 and IPv6 Support
- CIDR Entry Management
- Entry Descriptions
- Version Tracking
- Tag Support
- Flexible Max Entries

## Quick Start

```hcl
module "prefix_list" {
  source = "github.com/llamandcoco/infra-modules//terraform/managed-prefix-list?ref=<commit-sha>"

  name           = "my-prefix-list"
  address_family = "IPv4"
  max_entries    = 10

  entries = [
    {
      cidr        = "10.0.0.0/8"
      description = "Private network"
    }
  ]
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
| [aws_ec2_managed_prefix_list.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_managed_prefix_list) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_family"></a> [address\_family](#input\_address\_family) | Address family (IPv4 or IPv6) for the managed prefix list. | `string` | `"IPv4"` | no |
| <a name="input_create"></a> [create](#input\_create) | Whether to create the managed prefix list. | `bool` | `true` | no |
| <a name="input_entries"></a> [entries](#input\_entries) | List of prefix list entries. Each entry should have 'cidr' and optional 'description'. | <pre>list(object({<br>    cidr        = string<br>    description = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_max_entries"></a> [max\_entries](#input\_max\_entries) | Maximum number of entries in the prefix list. | `number` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the managed prefix list. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the managed prefix list. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_prefix_list_arn"></a> [prefix\_list\_arn](#output\_prefix\_list\_arn) | ARN of the managed prefix list. |
| <a name="output_prefix_list_id"></a> [prefix\_list\_id](#output\_prefix\_list\_id) | ID of the managed prefix list. |
| <a name="output_prefix_list_owner_id"></a> [prefix\_list\_owner\_id](#output\_prefix\_list\_owner\_id) | Owner ID of the managed prefix list. |
| <a name="output_prefix_list_tags"></a> [prefix\_list\_tags](#output\_prefix\_list\_tags) | Tags applied to the managed prefix list. |
| <a name="output_prefix_list_version"></a> [prefix\_list\_version](#output\_prefix\_list\_version) | Version of the managed prefix list. |
<!-- END_TF_DOCS -->
</details>
