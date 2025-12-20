# NAT Gateway Terraform Module

## Quick Start

```hcl
module "nat_gateway" {
  source = "github.com/llamandcoco/infra-modules//terraform/nat_gateway?ref=<commit-sha>"

  # Add required variables here
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|----------|
| Basic | [`tests/basic/`](tests/basic/) |

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
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Availability zones corresponding to public\_subnet\_ids (used for naming). | `list(string)` | `[]` | no |
| <a name="input_create_per_az"></a> [create\_per\_az](#input\_create\_per\_az) | Create one NAT Gateway per provided subnet for high availability. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used for NAT Gateway resource names. | `string` | `"network"` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | List of public subnet IDs where NAT Gateways will be placed. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to NAT Gateways and EIPs. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_elastic_ip_ids"></a> [elastic\_ip\_ids](#output\_elastic\_ip\_ids) | Map of Elastic IP allocation IDs keyed by index. |
| <a name="output_elastic_ip_names"></a> [elastic\_ip\_names](#output\_elastic\_ip\_names) | Map of Elastic IP Name tags keyed by index. |
| <a name="output_nat_gateway_ids"></a> [nat\_gateway\_ids](#output\_nat\_gateway\_ids) | Map of NAT Gateway IDs keyed by index. |
| <a name="output_nat_gateway_names"></a> [nat\_gateway\_names](#output\_nat\_gateway\_names) | Map of NAT Gateway Name tags keyed by index. |
<!-- END_TF_DOCS -->
</details>
