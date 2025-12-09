# Route Table Terraform Module

Creates public, private, and database route tables with associations supporting Internet Gateway and NAT Gateway routing.

## Usage

```hcl
module "route_tables" {
  source = "github.com/your-org/infra-modules//terraform/modules/route_table"

  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.igw.internet_gateway_id
  nat_gateway_ids     = module.nat.nat_gateway_ids
  public_subnet_ids   = module.subnets.public_subnet_ids
  private_subnet_ids  = module.subnets.private_subnet_ids
  database_subnet_ids = module.subnets.database_subnet_ids
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider_aws) | 5.100.0 |

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
| <a name="input_database_route_via_nat"></a> [database_route_via_nat](#input_database_route_via_nat) | Route database subnets through the first NAT Gateway. | `bool` | `false` | no |
| <a name="input_database_subnet_ids"></a> [database_subnet_ids](#input_database_subnet_ids) | List of database subnet IDs to associate with the database route table. | `list(string)` | `[]` | no |
| <a name="input_enable_private_default_route"></a> [enable_private_default_route](#input_enable_private_default_route) | Create default routes for private subnets using NAT. | `bool` | `true` | no |
| <a name="input_enable_public_internet_route"></a> [enable_public_internet_route](#input_enable_public_internet_route) | Create a default route for public subnets via the Internet Gateway. | `bool` | `true` | no |
| <a name="input_internet_gateway_id"></a> [internet_gateway_id](#input_internet_gateway_id) | ID of the Internet Gateway for public route table. | `string` | `null` | no |
| <a name="input_nat_gateway_ids"></a> [nat_gateway_ids](#input_nat_gateway_ids) | Map of NAT Gateway IDs keyed by index. | `map(string)` | `{}` | no |
| <a name="input_name_prefix"></a> [name_prefix](#input_name_prefix) | Prefix used for route table Name tags. | `string` | `"network"` | no |
| <a name="input_private_subnet_ids"></a> [private_subnet_ids](#input_private_subnet_ids) | List of private subnet IDs to associate with private route tables. | `list(string)` | `[]` | no |
| <a name="input_public_subnet_ids"></a> [public_subnet_ids](#input_public_subnet_ids) | List of public subnet IDs to associate with the public route table. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Tags applied to all route tables. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id) | ID of the VPC. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_route_table_id"></a> [database_route_table_id](#output_database_route_table_id) | ID of the database route table, if created. |
| <a name="output_private_route_table_ids"></a> [private_route_table_ids](#output_private_route_table_ids) | IDs of private route tables. |
| <a name="output_public_route_table_id"></a> [public_route_table_id](#output_public_route_table_id) | ID of the public route table. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Testing

```
cd tests/basic
terraform init -backend=false
terraform plan
```
