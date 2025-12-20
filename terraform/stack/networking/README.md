# Networking Stack

## Quick Start

```hcl
module "networking" {
  source = "github.com/llamandcoco/infra-modules//terraform/stack/networking?ref=<commit-sha>"

  # Add required variables here
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|----------|
| Basic | [`tests/basic/`](tests/basic/) |
| No Nat | [`tests/no-nat/`](tests/no-nat/) |
| Single Nat | [`tests/single-nat/`](tests/single-nat/) |

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
module "networking" {
  source = "github.com/llamandcoco/infra-modules//terraform/stack/networking?ref=<commit-sha>"

  # Add required variables here
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_internet_gateway"></a> [internet\_gateway](#module\_internet\_gateway) | ../../internet_gateway | n/a |
| <a name="module_nat_gateway"></a> [nat\_gateway](#module\_nat\_gateway) | ../../nat_gateway | n/a |
| <a name="module_route_tables"></a> [route\_tables](#module\_route\_tables) | ../../route_table | n/a |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | ../../security_group | n/a |
| <a name="module_subnets"></a> [subnets](#module\_subnets) | ../../subnet | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../vpc | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azs"></a> [azs](#input\_azs) | Availability zones to span the network across. | `list(string)` | n/a | yes |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | CIDR block for the VPC. | `string` | n/a | yes |
| <a name="input_database_route_via_nat"></a> [database\_route\_via\_nat](#input\_database\_route\_via\_nat) | Route database subnets to the internet via NAT. | `bool` | `false` | no |
| <a name="input_database_subnet_cidrs"></a> [database\_subnet\_cidrs](#input\_database\_subnet\_cidrs) | CIDR blocks for database subnets. If null, automatically calculated from VPC CIDR. Use [] to disable database subnets. | `list(string)` | `null` | no |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Enable DNS hostnames in the VPC. | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Enable DNS resolution in the VPC. | `bool` | `true` | no |
| <a name="input_enable_ipv6"></a> [enable\_ipv6](#input\_enable\_ipv6) | Enable IPv6 for the VPC and public subnets. | `bool` | `false` | no |
| <a name="input_enable_network_address_usage_metrics"></a> [enable\_network\_address\_usage\_metrics](#input\_enable\_network\_address\_usage\_metrics) | Enable VPC IP address usage metrics. | `bool` | `false` | no |
| <a name="input_instance_tenancy"></a> [instance\_tenancy](#input\_instance\_tenancy) | Instance tenancy for the VPC. | `string` | `"default"` | no |
| <a name="input_internet_gateway_enabled"></a> [internet\_gateway\_enabled](#input\_internet\_gateway\_enabled) | Create an Internet Gateway. Automatically enabled if public subnets are configured. | `bool` | `true` | no |
| <a name="input_map_public_ip_on_launch"></a> [map\_public\_ip\_on\_launch](#input\_map\_public\_ip\_on\_launch) | Auto-assign public IPs to instances in public subnets. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for networking resources. | `string` | n/a | yes |
| <a name="input_nat_gateway_mode"></a> [nat\_gateway\_mode](#input\_nat\_gateway\_mode) | NAT Gateway deployment strategy: 'per\_az' (HA, one per AZ), 'single' (cost-optimized, one NAT), or 'none' (no NAT). | `string` | `"per_az"` | no |
| <a name="input_nat_per_az"></a> [nat\_per\_az](#input\_nat\_per\_az) | DEPRECATED: Use nat\_gateway\_mode instead. Create one NAT Gateway per AZ for high availability. | `bool` | `null` | no |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | CIDR blocks for private subnets. If null, automatically calculated from VPC CIDR. | `list(string)` | `null` | no |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | CIDR blocks for public subnets. If null, automatically calculated from VPC CIDR. | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Common tags applied to all networking resources. | `map(string)` | `{}` | no |
| <a name="input_workload_security_group_egress"></a> [workload\_security\_group\_egress](#input\_workload\_security\_group\_egress) | Egress rules for the default workload security group. | <pre>list(object({<br/>    description              = optional(string)<br/>    from_port                = number<br/>    to_port                  = number<br/>    protocol                 = string<br/>    cidr_blocks              = optional(list(string), [])<br/>    ipv6_cidr_blocks         = optional(list(string), [])<br/>    source_security_group_id = optional(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "cidr_blocks": [<br/>      "0.0.0.0/0"<br/>    ],<br/>    "description": "Allow all outbound",<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_workload_security_group_ingress"></a> [workload\_security\_group\_ingress](#input\_workload\_security\_group\_ingress) | Ingress rules for the default workload security group. | <pre>list(object({<br/>    description              = optional(string)<br/>    from_port                = number<br/>    to_port                  = number<br/>    protocol                 = string<br/>    cidr_blocks              = optional(list(string), [])<br/>    ipv6_cidr_blocks         = optional(list(string), [])<br/>    source_security_group_id = optional(string)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_computed_subnet_cidrs"></a> [computed\_subnet\_cidrs](#output\_computed\_subnet\_cidrs) | Computed or provided subnet CIDRs. |
| <a name="output_database_subnet_ids"></a> [database\_subnet\_ids](#output\_database\_subnet\_ids) | IDs of database subnets. |
| <a name="output_internet_gateway_id"></a> [internet\_gateway\_id](#output\_internet\_gateway\_id) | ID of the Internet Gateway (null if not created). |
| <a name="output_nat_gateway_ids"></a> [nat\_gateway\_ids](#output\_nat\_gateway\_ids) | IDs of NAT Gateways (empty map if not created). |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | IDs of private subnets. |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | IDs of public subnets. |
| <a name="output_resource_names"></a> [resource\_names](#output\_resource\_names) | Key resource Name tags for validation. |
| <a name="output_route_tables"></a> [route\_tables](#output\_route\_tables) | Route table identifiers. |
| <a name="output_security_groups"></a> [security\_groups](#output\_security\_groups) | Security groups created by the stack. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the created VPC. |
<!-- END_TF_DOCS -->
