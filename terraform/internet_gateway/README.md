# Internet Gateway Terraform Module

## Testing

## Quick Start

```hcl
module "internet_gateway" {
  source = "github.com/llamandcoco/infra-modules//terraform/internet_gateway?ref=v1.0.0"

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

```bash
cd tests/basic && terraform init && terraform plan
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
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | Whether to create the Internet Gateway. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name tag for the Internet Gateway. | `string` | `"igw"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the Internet Gateway. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to attach the Internet Gateway. Required if creating gateway. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_internet_gateway_arn"></a> [internet\_gateway\_arn](#output\_internet\_gateway\_arn) | ARN of the Internet Gateway. |
| <a name="output_internet_gateway_id"></a> [internet\_gateway\_id](#output\_internet\_gateway\_id) | ID of the Internet Gateway. |
| <a name="output_internet_gateway_tags"></a> [internet\_gateway\_tags](#output\_internet\_gateway\_tags) | Tags applied to the Internet Gateway. |
<!-- END_TF_DOCS -->
