# Internet Gateway Terraform Module

Creates an Internet Gateway optionally attached to a VPC with tagging support.

## Usage

```hcl
module "igw" {
  source = "github.com/your-org/infra-modules//terraform/modules/internet_gateway"

  name   = "core-igw"
  vpc_id = module.vpc.vpc_id
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
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input_create) | Whether to create the Internet Gateway. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input_name) | Name tag for the Internet Gateway. | `string` | `"igw"` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Tags to apply to the Internet Gateway. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id) | VPC ID to attach the Internet Gateway. If null, the gateway is not created. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_internet_gateway_arn"></a> [internet_gateway_arn](#output_internet_gateway_arn) | ARN of the Internet Gateway. |
| <a name="output_internet_gateway_id"></a> [internet_gateway_id](#output_internet_gateway_id) | ID of the Internet Gateway. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Testing

```
cd tests/basic
terraform init -backend=false
terraform plan
```
