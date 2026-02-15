# RDS Parameter Group Module

A Terraform module for creating and managing AWS RDS DB parameter groups to customize database engine configurations.

## Features

- Custom Parameters Configure database-specific parameters (max_connections, memory settings, etc.)
- Multiple Engines Support for MySQL, PostgreSQL, MariaDB, Oracle, and SQL Server families
- Apply Methods Choose immediate or pending-reboot parameter application
- Lifecycle Management Automatic create_before_destroy to prevent downtime during updates
- Tagging Support Custom tags for resource organization and cost tracking

## Quick Start

```hcl
module "rds_params" {
  source = "github.com/llamandcoco/infra-modules//terraform/rds-parameter-group?ref=<commit-sha>"

  name   = "my-db-params"
  family = "mysql8.0"

  parameters = [
    {
      name  = "max_connections"
      value = "200"
    }
  ]
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic MySQL Configuration | [`tests/basic/main.tf`](tests/basic/main.tf) |
| Advanced PostgreSQL Setup | [`tests/advanced/main.tf`](tests/advanced/main.tf) |

**Usage:**
```bash
# View example
cat tests/basic/

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
| [aws_db_parameter_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | Description of the DB parameter group. | `string` | `null` | no |
| <a name="input_family"></a> [family](#input\_family) | The DB parameter group family (e.g., mysql8.0, postgres15, mariadb10.6).<br/>Must match the database engine family you plan to use.<br/>See AWS documentation for available families. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the DB parameter group. Must be unique within the region. | `string` | n/a | yes |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | List of database parameters to configure.<br/>Each parameter requires a name and value.<br/>Apply method can be 'immediate' (default) or 'pending-reboot'.<br/><br/>Example:<br/>[<br/>  {<br/>    name  = "max\_connections"<br/>    value = "200"<br/>    apply\_method = "immediate"<br/>  }<br/>] | <pre>list(object({<br/>    name         = string<br/>    value        = string<br/>    apply_method = optional(string, "immediate")<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to the parameter group. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the DB parameter group. |
| <a name="output_description"></a> [description](#output\_description) | The description of the DB parameter group. |
| <a name="output_family"></a> [family](#output\_family) | The DB parameter group family. |
| <a name="output_id"></a> [id](#output\_id) | The DB parameter group ID (same as name). |
| <a name="output_name"></a> [name](#output\_name) | The name of the DB parameter group. |
<!-- END_TF_DOCS -->
</details>
