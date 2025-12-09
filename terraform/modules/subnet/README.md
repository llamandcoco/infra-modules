# Subnet Terraform Module

Creates public, private, and database subnets across multiple AZs with tagging and optional IPv6 assignment for public tiers.

## Usage

```hcl
module "subnets" {
  source = "github.com/your-org/infra-modules//terraform/modules/subnet"

  vpc_id               = module.vpc.vpc_id
  azs                  = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  database_subnet_cidrs = ["10.0.21.0/24", "10.0.22.0/24"]

  tags = {
    Environment = "prod"
  }
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
| [aws_subnet.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azs"></a> [azs](#input_azs) | List of availability zones to spread subnets across. | `list(string)` | n/a | yes |
| <a name="input_database_subnet_cidrs"></a> [database_subnet_cidrs](#input_database_subnet_cidrs) | CIDR blocks for database subnets. Length must match azs when provided. | `list(string)` | `[]` | no |
| <a name="input_enable_ipv6"></a> [enable_ipv6](#input_enable_ipv6) | Assign IPv6 addresses on creation for public subnets. | `bool` | `false` | no |
| <a name="input_map_public_ip_on_launch"></a> [map_public_ip_on_launch](#input_map_public_ip_on_launch) | Auto-assign public IPs for instances in public subnets. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name_prefix](#input_name_prefix) | Prefix used for subnet Name tags. | `string` | `"network"` | no |
| <a name="input_private_subnet_cidrs"></a> [private_subnet_cidrs](#input_private_subnet_cidrs) | CIDR blocks for private subnets. Length must match azs when provided. | `list(string)` | `[]` | no |
| <a name="input_public_subnet_cidrs"></a> [public_subnet_cidrs](#input_public_subnet_cidrs) | CIDR blocks for public subnets. Length must match azs when provided. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Common tags applied to all subnets. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id) | ID of the VPC where subnets will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_zones"></a> [availability_zones](#output_availability_zones) | Availability zones used for subnets. |
| <a name="output_database_subnet_ids"></a> [database_subnet_ids](#output_database_subnet_ids) | IDs of database subnets. |
| <a name="output_private_subnet_ids"></a> [private_subnet_ids](#output_private_subnet_ids) | IDs of private subnets. |
| <a name="output_public_subnet_ids"></a> [public_subnet_ids](#output_public_subnet_ids) | IDs of public subnets. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Testing

```
cd tests/basic
terraform init -backend=false
terraform plan
```
