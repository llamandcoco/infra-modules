# Security Groups Terraform Module

## Features

- Multi-Group Creation Define multiple security groups in a single configuration
- Cross-Group References Rules can reference other security groups by key name
- Self-Referencing Groups Support for `self = true` rules
- Flexible Rule Definition Support for CIDR blocks, IPv6, prefix lists, and source security groups
- Zero Egress by Default Explicit egress rules required for better security control
- DRY Configuration Eliminates duplicate security group definitions

## Quick Start

```hcl
module "security_groups" {
  source = "github.com/llamandcoco/infra-modules//terraform/security_groups?ref=<commit-sha>"

  vpc_id = "vpc-12345678"

  security_groups = {
    # Define your security groups here
  }
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Description |
|---------|-------------|
| [Basic](tests/basic/main.tf) | Cross-group references and self-referencing rules |

**Usage:**
```bash
# View example
cat tests/basic/main.tf

# Test example
cd tests/basic && terraform init && terraform plan

# Copy and adapt
cp -r tests/basic/ my-project/
```

## Testing

```bash
cd tests/basic && terraform init && terraform plan
```

<details>
<summary>Terraform Documentation</summary>

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
| [aws_security_group.sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | Map of security groups to create keyed by an arbitrary name | <pre>map(object({<br/>    name        = string<br/>    description = optional(string, "Managed security group")<br/>    tags        = optional(map(string), {})<br/><br/>    ingress_rules = optional(list(object({<br/>      description      = optional(string)<br/>      from_port        = number<br/>      to_port          = number<br/>      protocol         = string<br/>      cidr_blocks      = optional(list(string))<br/>      ipv6_cidr_blocks = optional(list(string))<br/>      prefix_list_ids  = optional(list(string))<br/>      source_sg_key    = optional(string)<br/>      self             = optional(bool)<br/>    })), [])<br/><br/>    egress_rules = optional(list(object({<br/>      description      = optional(string)<br/>      from_port        = number<br/>      to_port          = number<br/>      protocol         = string<br/>      cidr_blocks      = optional(list(string))<br/>      ipv6_cidr_blocks = optional(list(string))<br/>      prefix_list_ids  = optional(list(string))<br/>      source_sg_key    = optional(string)<br/>      self             = optional(bool)<br/>    })), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where security groups will be created | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | Map of security group IDs keyed by the provided security\_groups map keys |
<!-- END_TF_DOCS -->
</details>
