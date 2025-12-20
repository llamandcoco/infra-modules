# Security Group Terraform Module

## Testing

## Quick Start

```hcl
module "security_group" {
  source = "github.com/llamandcoco/infra-modules//terraform/security_group?ref=v1.0.0"

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
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | Description of the security group. | `string` | `"Managed by terraform"` | no |
| <a name="input_egress_rules"></a> [egress\_rules](#input\_egress\_rules) | List of custom egress rules to apply. Empty list denies all outbound traffic. | <pre>list(object({<br/>    description              = optional(string)<br/>    from_port                = number<br/>    to_port                  = number<br/>    protocol                 = string<br/>    cidr_blocks              = optional(list(string), [])<br/>    ipv6_cidr_blocks         = optional(list(string), [])<br/>    source_security_group_id = optional(string)<br/>    prefix_list_ids          = optional(list(string), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_default_egress_rule"></a> [enable\_default\_egress\_rule](#input\_enable\_default\_egress\_rule) | Enable default egress rule allowing all outbound traffic. | `bool` | `true` | no |
| <a name="input_ingress_rules"></a> [ingress\_rules](#input\_ingress\_rules) | List of custom ingress rules to apply. Empty list denies all inbound traffic. | <pre>list(object({<br/>    description              = optional(string)<br/>    from_port                = number<br/>    to_port                  = number<br/>    protocol                 = string<br/>    cidr_blocks              = optional(list(string), [])<br/>    ipv6_cidr_blocks         = optional(list(string), [])<br/>    source_security_group_id = optional(string)<br/>    prefix_list_ids          = optional(list(string), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the security group. | `string` | n/a | yes |
| <a name="input_predefined_ingress_rules"></a> [predefined\_ingress\_rules](#input\_predefined\_ingress\_rules) | List of predefined ingress rule names to apply (http, https, ssh, mysql, postgres, redis, mongodb, etc.). | `list(string)` | `[]` | no |
| <a name="input_predefined_rule_cidr_blocks"></a> [predefined\_rule\_cidr\_blocks](#input\_predefined\_rule\_cidr\_blocks) | CIDR blocks to apply to predefined ingress rules. | `list(string)` | `[]` | no |
| <a name="input_predefined_rule_ipv6_cidr_blocks"></a> [predefined\_rule\_ipv6\_cidr\_blocks](#input\_predefined\_rule\_ipv6\_cidr\_blocks) | IPv6 CIDR blocks to apply to predefined ingress rules. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the security group. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the security group will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | Name of the security group. |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | ARN of the security group. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group. |
<!-- END_TF_DOCS -->
