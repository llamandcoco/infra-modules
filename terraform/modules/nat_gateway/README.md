# NAT Gateway Terraform Module

Creates NAT Gateways (optionally one per AZ) with Elastic IPs for private subnet outbound internet access.

## Usage

```hcl
module "nat" {
  source = "github.com/your-org/infra-modules//terraform/modules/nat_gateway"

  public_subnet_ids = module.subnets.public_subnet_ids
  create_per_az     = true
  name_prefix       = "core"
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
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_per_az"></a> [create_per_az](#input_create_per_az) | Create one NAT Gateway per provided subnet for high availability. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name_prefix](#input_name_prefix) | Prefix used for NAT Gateway resource names. | `string` | `"network"` | no |
| <a name="input_public_subnet_ids"></a> [public_subnet_ids](#input_public_subnet_ids) | List of public subnet IDs where NAT Gateways will be placed. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Tags to apply to NAT Gateways and EIPs. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_elastic_ip_ids"></a> [elastic_ip_ids](#output_elastic_ip_ids) | Map of Elastic IP allocation IDs keyed by index. |
| <a name="output_nat_gateway_ids"></a> [nat_gateway_ids](#output_nat_gateway_ids) | Map of NAT Gateway IDs keyed by index. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Testing

```
cd tests/basic
terraform init -backend=false
terraform plan
```
