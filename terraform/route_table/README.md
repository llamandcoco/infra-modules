# Route Table Terraform Module

## Quick Start

```hcl
module "route_table" {
  source = "github.com/llamandcoco/infra-modules//terraform/route_table?ref=<commit-sha>"

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
cat tests/basic/main.tf

# Copy and adapt
cp -r tests/basic/ my-project/
```

## Testing

## Quick Start

```hcl
module "route_table" {
  source = "github.com/llamandcoco/infra-modules//terraform/route_table?ref=<commit-sha>"

  # Add required variables here
}
```

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
| [aws_route.database_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_internet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Availability zones corresponding to subnets (used for naming). | `list(string)` | `[]` | no |
| <a name="input_database_route_via_nat"></a> [database\_route\_via\_nat](#input\_database\_route\_via\_nat) | Route database subnets through the first NAT Gateway. | `bool` | `false` | no |
| <a name="input_database_subnet_ids"></a> [database\_subnet\_ids](#input\_database\_subnet\_ids) | List of database subnet IDs to associate with the database route table. | `list(string)` | `[]` | no |
| <a name="input_enable_private_default_route"></a> [enable\_private\_default\_route](#input\_enable\_private\_default\_route) | Create default routes for private subnets using NAT. | `bool` | `true` | no |
| <a name="input_enable_public_internet_route"></a> [enable\_public\_internet\_route](#input\_enable\_public\_internet\_route) | Create a default route for public subnets via the Internet Gateway. | `bool` | `true` | no |
| <a name="input_internet_gateway_id"></a> [internet\_gateway\_id](#input\_internet\_gateway\_id) | ID of the Internet Gateway for public route table. | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used for route table Name tags. | `string` | `"network"` | no |
| <a name="input_nat_gateway_ids"></a> [nat\_gateway\_ids](#input\_nat\_gateway\_ids) | Map of NAT Gateway IDs keyed by index. | `map(string)` | `{}` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of private subnet IDs to associate with private route tables. | `list(string)` | `[]` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | List of public subnet IDs to associate with the public route table. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all route tables. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_route_table_id"></a> [database\_route\_table\_id](#output\_database\_route\_table\_id) | ID of the database route table, if created. |
| <a name="output_database_route_table_name"></a> [database\_route\_table\_name](#output\_database\_route\_table\_name) | Name tag of the database route table, if created. |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | IDs of private route tables. |
| <a name="output_private_route_table_names"></a> [private\_route\_table\_names](#output\_private\_route\_table\_names) | Name tags of private route tables keyed by index. |
| <a name="output_public_route_table_id"></a> [public\_route\_table\_id](#output\_public\_route\_table\_id) | ID of the public route table. |
| <a name="output_public_route_table_name"></a> [public\_route\_table\_name](#output\_public\_route\_table\_name) | Name tag of the public route table. |
<!-- END_TF_DOCS -->
