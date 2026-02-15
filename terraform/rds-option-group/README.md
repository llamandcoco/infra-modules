# AWS RDS Option Group Terraform Module

A Terraform module for managing RDS DB option groups with support for engine-specific features and comprehensive configuration options.

## Features

- **Multiple DB Engines** - Support for MySQL, Oracle, PostgreSQL, SQL Server, and MariaDB
- **Flexible Options** - Configure engine-specific options with custom settings
- **Security Integration** - VPC security group and DB security group support
- **Port Configuration** - Specify custom ports for options that require them
- **Version Control** - Pin specific option versions when needed
- **Lifecycle Management** - Create-before-destroy strategy for safe updates
- **Comprehensive Tagging** - Full tag support for resource organization
- **Validation** - Built-in validation for names and engine types

## Quick Start

```hcl
module "rds-option-group" {
  source = "github.com/llamandcoco/infra-modules//terraform/rds-option-group?ref=<commit-sha>"

  name                 = "mysql-option-group"
  engine_name          = "mysql"
  major_engine_version = "8.0"
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic Usage (MySQL, Oracle, SQL Server) | [`tests/basic/main.tf`](tests/basic/main.tf) |

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_option_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_option_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | Description of the option group. Defaults to 'Option group for {engine\_name} {major\_engine\_version}'. | `string` | `null` | no |
| <a name="input_engine_name"></a> [engine\_name](#input\_engine\_name) | Database engine name (e.g., mysql, oracle-ee, oracle-se2, postgres, sqlserver-ee, sqlserver-se, sqlserver-ex, sqlserver-web). | `string` | n/a | yes |
| <a name="input_major_engine_version"></a> [major\_engine\_version](#input\_major\_engine\_version) | Major version of the database engine (e.g., 5.7 for MySQL 5.7.x, 19 for Oracle 19c). | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the option group. Must be lowercase alphanumeric characters or hyphens. | `string` | n/a | yes |
| <a name="input_options"></a> [options](#input\_options) | List of options to apply to the option group. Each option can have settings, port, version, and security groups.<br><br>Example:<br>  options = [<br>    {<br>      option\_name = "MEMCACHED"<br>      port        = 11211<br>      vpc\_security\_group\_memberships = ["sg-12345678"]<br>      option\_settings = [<br>        {<br>          name  = "CHUNK\_SIZE"<br>          value = "32"<br>        }<br>      ]<br>    }<br>  ] | <pre>list(object({<br>    option_name                    = string<br>    port                           = optional(number)<br>    version                        = optional(string)<br>    vpc_security_group_memberships = optional(list(string))<br>    db_security_group_memberships  = optional(list(string))<br>    option_settings = optional(list(object({<br>      name  = string<br>      value = string<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to the option group. Use for resource organization, cost allocation, and governance. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the option group. Use for IAM policies, cross-account access, and resource tagging. |
| <a name="output_engine_name"></a> [engine\_name](#output\_engine\_name) | Database engine name for this option group. |
| <a name="output_id"></a> [id](#output\_id) | ID of the option group. Use this to reference the option group in RDS instance or cluster configurations. |
| <a name="output_major_engine_version"></a> [major\_engine\_version](#output\_major\_engine\_version) | Major engine version for this option group. |
| <a name="output_name"></a> [name](#output\_name) | Name of the option group. |
| <a name="output_option_group"></a> [option\_group](#output\_option\_group) | Complete option group details including all configured options and settings. |
<!-- END_TF_DOCS -->
</details>
