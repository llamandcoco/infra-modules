# RDS Proxy Module

A Terraform module for creating and managing AWS RDS Proxy, which provides connection pooling, improved availability, and IAM-based authentication for RDS and Aurora databases.

## Features

- Connection Pooling to efficiently manage database connections and reduce overhead
- IAM Authentication support for passwordless database access using AWS IAM credentials
- TLS Enforcement to require encrypted connections between clients and the proxy
- Security Group Management with optional auto-created security group for access control
- Multi-Engine Support for MySQL, PostgreSQL, and SQL Server database families
- Flexible Auth Configuration with AWS Secrets Manager integration for credential management
- Session Pinning Control to optimize connection reuse and reduce unnecessary pinning
- Aurora and RDS Support for both RDS instances and Aurora clusters as proxy targets

## Quick Start

```hcl
module "rds_proxy" {
  source = "github.com/llamandcoco/infra-modules//terraform/aws/rds-proxy?ref=<commit-sha>"

  name          = "myapp-proxy"
  engine_family = "MYSQL"
  role_arn      = var.proxy_iam_role_arn

  auth = [
    {
      auth_scheme = "SECRETS"
      iam_auth    = "DISABLED"
      secret_arn  = var.db_secret_arn
    }
  ]

  vpc_id                        = var.vpc_id
  vpc_subnet_ids                = var.private_subnet_ids
  port                          = 3306
  target_db_instance_identifier = var.db_instance_id
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic MySQL Proxy | [`tests/basic/main.tf`](tests/basic/main.tf) |

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
| [aws_db_proxy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy) | resource |
| [aws_db_proxy_default_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy_default_target_group) | resource |
| [aws_db_proxy_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy_target) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | List of CIDR blocks allowed to connect to the proxy. | `list(string)` | `[]` | no |
| <a name="input_allowed_security_groups"></a> [allowed\_security\_groups](#input\_allowed\_security\_groups) | Map of security group IDs allowed to connect to the proxy. Key is a description, value is the security group ID. | `map(string)` | `{}` | no |
| <a name="input_auth"></a> [auth](#input\_auth) | List of authentication mechanisms for the proxy. Each item can contain auth\_scheme, client\_password\_auth\_type, description, iam\_auth, secret\_arn, and username. | `list(object({...}))` | n/a | yes |
| <a name="input_connection_borrow_timeout"></a> [connection\_borrow\_timeout](#input\_connection\_borrow\_timeout) | Number of seconds to wait for a connection from the pool before returning a timeout error. Valid range: 0-3600. | `number` | `120` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Whether to create a security group for the RDS Proxy. | `bool` | `true` | no |
| <a name="input_debug_logging"></a> [debug\_logging](#input\_debug\_logging) | Whether to enable debug logging for the proxy. | `bool` | `false` | no |
| <a name="input_egress_cidr_blocks"></a> [egress\_cidr\_blocks](#input\_egress\_cidr\_blocks) | List of CIDR blocks for egress traffic from the proxy security group. | `list(string)` | `[]` | no |
| <a name="input_engine_family"></a> [engine\_family](#input\_engine\_family) | The kinds of databases that the proxy can connect to. Valid values: MYSQL, POSTGRESQL, SQLSERVER. | `string` | n/a | yes |
| <a name="input_idle_client_timeout"></a> [idle\_client\_timeout](#input\_idle\_client\_timeout) | Number of seconds a connection to the proxy can be inactive before it is closed. Valid range: 1-28800. | `number` | `1800` | no |
| <a name="input_init_query"></a> [init\_query](#input\_init\_query) | SQL statements for the proxy to run when opening a new connection to the database. | `string` | `null` | no |
| <a name="input_max_connections_percent"></a> [max\_connections\_percent](#input\_max\_connections\_percent) | Maximum percentage of max\_connections that RDS Proxy can open on a given DB instance. Valid range: 1-100. | `number` | `100` | no |
| <a name="input_max_idle_connections_percent"></a> [max\_idle\_connections\_percent](#input\_max\_idle\_connections\_percent) | Maximum percentage of max\_connections RDS Proxy can keep idle in the pool. Valid range: 0-100. | `number` | `50` | no |
| <a name="input_name"></a> [name](#input\_name) | The identifier for the RDS Proxy. Must be unique within the AWS account and region. | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | Port number the proxy listens on. Used for security group rules. | `number` | `null` | no |
| <a name="input_require_tls"></a> [require\_tls](#input\_require\_tls) | Whether to require TLS encryption for connections to the proxy. | `bool` | `true` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | ARN of the IAM role that allows RDS Proxy to access the database credentials in AWS Secrets Manager. | `string` | n/a | yes |
| <a name="input_session_pinning_filters"></a> [session\_pinning\_filters](#input\_session\_pinning\_filters) | List of SQL operations that cause the proxy to pin the client to a specific DB instance. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_target_db_cluster_identifier"></a> [target\_db\_cluster\_identifier](#input\_target\_db\_cluster\_identifier) | Aurora cluster identifier to associate with the proxy. Specify either this or target\_db\_instance\_identifier, not both. | `string` | `null` | no |
| <a name="input_target_db_instance_identifier"></a> [target\_db\_instance\_identifier](#input\_target\_db\_instance\_identifier) | DB instance identifier to associate with the proxy. Specify either this or target\_db\_cluster\_identifier, not both. | `string` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the security group will be created. Required if create\_security\_group is true. | `string` | `null` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | List of VPC security group IDs to associate with the proxy. If null and create\_security\_group is true, a security group will be created. | `list(string)` | `null` | no |
| <a name="input_vpc_subnet_ids"></a> [vpc\_subnet\_ids](#input\_vpc\_subnet\_ids) | List of VPC subnet IDs for the RDS Proxy. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_proxy_arn"></a> [proxy\_arn](#output\_proxy\_arn) | The ARN of the RDS Proxy. |
| <a name="output_proxy_endpoint"></a> [proxy\_endpoint](#output\_proxy\_endpoint) | The endpoint that you can use to connect to the proxy. |
| <a name="output_proxy_engine_family"></a> [proxy\_engine\_family](#output\_proxy\_engine\_family) | The engine family of the RDS Proxy. |
| <a name="output_proxy_id"></a> [proxy\_id](#output\_proxy\_id) | The Amazon Resource Name (ARN) for the proxy. |
| <a name="output_proxy_name"></a> [proxy\_name](#output\_proxy\_name) | The identifier of the RDS Proxy. |
| <a name="output_proxy_require_tls"></a> [proxy\_require\_tls](#output\_proxy\_require\_tls) | Whether the proxy requires TLS encryption. |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | The ARN of the security group created for the RDS Proxy (if create\_security\_group was true). |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group created for the RDS Proxy (if create\_security\_group was true). |
| <a name="output_tags"></a> [tags](#output\_tags) | All tags applied to the RDS Proxy. |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | The ARN of the default target group. |
| <a name="output_target_group_name"></a> [target\_group\_name](#output\_target\_group\_name) | The name of the default target group. |
<!-- END_TF_DOCS -->
</details>
