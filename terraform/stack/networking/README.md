# Networking Stack

Reference composition that wires the networking modules into a complete multi-AZ VPC with public, private, and database tiers.

## Architecture

```mermaid
flowchart LR
  IGW["Internet Gateway"] --- RTpub["Public RT"]
  RTpub --- PubA["Public Subnet A"]
  RTpub --- PubB["Public Subnet B"]

  NATa["NAT GW A"] --- RTea["Private RT A"]
  NATb["NAT GW B"] --- RTeB["Private RT B"]

  RTea --- PrivA["Private Subnet A"]
  RTeB --- PrivB["Private Subnet B"]

  DBRT["Database RT"] --- DBA["DB Subnet A"]
  DBRT --- DBB["DB Subnet B"]
```

## Subnet Strategy
- One public, one private, and one database subnet per AZ.
- Public subnets optionally assign public IPs for ingress/egress via the Internet Gateway.
- Private subnets use NAT Gateways (one per AZ by default) for outbound-only access.
- Database subnets stay isolated; optional NAT routing is controllable via input.

## Route Behavior
- Public route table forwards `0.0.0.0/0` to the Internet Gateway.
- Private route tables forward `0.0.0.0/0` to NAT Gateways (HA optional).
- Database route table is isolated by default; can opt-in to NAT routing.

## Usage

```hcl
module "networking" {
  source = "github.com/your-org/infra-modules//terraform/stack/networking"

  name       = "core"
  cidr_block = "10.0.0.0/16"
  azs        = ["us-east-1a", "us-east-1b"]

  public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  database_subnet_cidrs = ["10.0.20.0/24", "10.0.21.0/24"]
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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_internet_gateway"></a> [internet_gateway](#module_internet_gateway) | ../../modules/internet_gateway | n/a |
| <a name="module_nat_gateway"></a> [nat_gateway](#module_nat_gateway) | ../../modules/nat_gateway | n/a |
| <a name="module_route_tables"></a> [route_tables](#module_route_tables) | ../../modules/route_table | n/a |
| <a name="module_security_group"></a> [security_group](#module_security_group) | ../../modules/security_group | n/a |
| <a name="module_subnets"></a> [subnets](#module_subnets) | ../../modules/subnet | n/a |
| <a name="module_vpc"></a> [vpc](#module_vpc) | ../../modules/vpc | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azs"></a> [azs](#input_azs) | Availability zones to span the network across. | `list(string)` | n/a | yes |
| <a name="input_cidr_block"></a> [cidr_block](#input_cidr_block) | CIDR block for the VPC. | `string` | n/a | yes |
| <a name="input_database_route_via_nat"></a> [database_route_via_nat](#input_database_route_via_nat) | Route database subnets to the internet via NAT. | `bool` | `false` | no |
| <a name="input_database_subnet_cidrs"></a> [database_subnet_cidrs](#input_database_subnet_cidrs) | CIDR blocks for database subnets. | `list(string)` | `[]` | no |
| <a name="input_enable_dns_hostnames"></a> [enable_dns_hostnames](#input_enable_dns_hostnames) | Enable DNS hostnames in the VPC. | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable_dns_support](#input_enable_dns_support) | Enable DNS resolution in the VPC. | `bool` | `true` | no |
| <a name="input_enable_ipv6"></a> [enable_ipv6](#input_enable_ipv6) | Enable IPv6 for the VPC and public subnets. | `bool` | `false` | no |
| <a name="input_enable_network_address_usage_metrics"></a> [enable_network_address_usage_metrics](#input_enable_network_address_usage_metrics) | Enable VPC IP address usage metrics. | `bool` | `false` | no |
| <a name="input_instance_tenancy"></a> [instance_tenancy](#input_instance_tenancy) | Instance tenancy for the VPC. | `string` | `"default"` | no |
| <a name="input_map_public_ip_on_launch"></a> [map_public_ip_on_launch](#input_map_public_ip_on_launch) | Auto-assign public IPs to instances in public subnets. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input_name) | Name prefix for networking resources. | `string` | n/a | yes |
| <a name="input_nat_per_az"></a> [nat_per_az](#input_nat_per_az) | Create one NAT Gateway per AZ for high availability. | `bool` | `true` | no |
| <a name="input_private_subnet_cidrs"></a> [private_subnet_cidrs](#input_private_subnet_cidrs) | CIDR blocks for private subnets. | `list(string)` | n/a | yes |
| <a name="input_public_subnet_cidrs"></a> [public_subnet_cidrs](#input_public_subnet_cidrs) | CIDR blocks for public subnets. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input_tags) | Common tags applied to all networking resources. | `map(string)` | `{}` | no |
| <a name="input_workload_security_group_egress"></a> [workload_security_group_egress](#input_workload_security_group_egress) | Egress rules for the default workload security group. | <pre>list(object({<br/>    description                   = optional(string)<br/>    from_port                     = number<br/>    to_port                       = number<br/>    protocol                      = string<br/>    cidr_blocks                   = optional(list(string), [])<br/>    ipv6_cidr_blocks              = optional(list(string), [])<br/>    destination_security_group_id = optional(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    description = "Allow all outbound"<br/>    from_port   = 0<br/>    to_port     = 0<br/>    protocol    = "-1"<br/>    cidr_blocks = ["0.0.0.0/0"]<br/>  }<br/>]</pre> | no |
| <a name="input_workload_security_group_ingress"></a> [workload_security_group_ingress](#input_workload_security_group_ingress) | Ingress rules for the default workload security group. | <pre>list(object({<br/>    description              = optional(string)<br/>    from_port                = number<br/>    to_port                  = number<br/>    protocol                 = string<br/>    cidr_blocks              = optional(list(string), [])<br/>    ipv6_cidr_blocks         = optional(list(string), [])<br/>    source_security_group_id = optional(string)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_subnet_ids"></a> [database_subnet_ids](#output_database_subnet_ids) | IDs of database subnets. |
| <a name="output_private_subnet_ids"></a> [private_subnet_ids](#output_private_subnet_ids) | IDs of private subnets. |
| <a name="output_public_subnet_ids"></a> [public_subnet_ids](#output_public_subnet_ids) | IDs of public subnets. |
| <a name="output_route_tables"></a> [route_tables](#output_route_tables) | Route table identifiers. |
| <a name="output_security_groups"></a> [security_groups](#output_security_groups) | Security groups created by the stack. |
| <a name="output_vpc_id"></a> [vpc_id](#output_vpc_id) | ID of the created VPC. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Testing

```
cd tests/basic
terraform init -backend=false
terraform plan
```
