# VPC Terraform Module

Creates a production-ready Amazon VPC with optional IPv6 support, DNS configuration, and tagging.

## Usage

```hcl
module "vpc" {
  source = "github.com/your-org/infra-modules//terraform/modules/vpc"

  name       = "core-vpc"
  cidr_block = "10.0.0.0/16"
  enable_ipv6 = false

  tags = {
    Environment = "prod"
    ManagedBy   = "terraform"
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
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr_block"></a> [cidr_block](#input_cidr_block) | CIDR block for the VPC. | `string` | n/a | yes |
| <a name="input_enable_dns_hostnames"></a> [enable_dns_hostnames](#input_enable_dns_hostnames) | Enable DNS hostnames for instances launched in the VPC. | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable_dns_support](#input_enable_dns_support) | Enable DNS resolution for the VPC. | `bool` | `true` | no |
| <a name="input_enable_ipv6"></a> [enable_ipv6](#input_enable_ipv6) | Assign an Amazon-provided IPv6 CIDR block to the VPC. | `bool` | `false` | no |
| <a name="input_enable_network_address_usage_metrics"></a> [enable_network_address_usage_metrics](#input_enable_network_address_usage_metrics) | Enable network address usage metrics for the VPC. | `bool` | `false` | no |
| <a name="input_instance_tenancy"></a> [instance_tenancy](#input_instance_tenancy) | The allowed tenancy of instances launched into the VPC. | `string` | `"default"` | no |
| <a name="input_name"></a> [name](#input_name) | Name tag for the VPC. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input_tags) | A map of tags to apply to the VPC. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cidr_block"></a> [cidr_block](#output_cidr_block) | IPv4 CIDR block of the VPC. |
| <a name="output_ipv6_cidr_block"></a> [ipv6_cidr_block](#output_ipv6_cidr_block) | Amazon provided IPv6 CIDR block of the VPC. |
| <a name="output_tags"></a> [tags](#output_tags) | Tags applied to the VPC. |
| <a name="output_vpc_arn"></a> [vpc_arn](#output_vpc_arn) | ARN of the VPC. |
| <a name="output_vpc_id"></a> [vpc_id](#output_vpc_id) | ID of the VPC. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Testing

```
cd tests/basic
terraform init -backend=false
terraform plan
```
