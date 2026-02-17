# RDS Module

A Terraform module for creating and managing AWS RDS database instances with support for multiple database engines, high availability, read replicas, and comprehensive monitoring.

## Features

- Multi-Engine Support for MySQL, PostgreSQL, MariaDB, Oracle, and SQL Server
- High Availability with Multi-AZ deployments and automated failover
- Read Replicas for horizontal scaling of read workloads
- Storage Autoscaling to automatically increase storage capacity as needed
- Security with encryption at rest (KMS), IAM authentication, and security group management
- Monitoring via CloudWatch Logs, Enhanced Monitoring, and Performance Insights
- Automated Backups with configurable retention and point-in-time recovery
- Flexible Storage with support for gp2, gp3, io1, and io2 storage types

## Quick Start

```hcl
module "rds" {
  source = "github.com/llamandcoco/infra-modules//terraform/rds?ref=<commit-sha>"

  identifier        = "myapp-db"
  engine            = "postgres"
  engine_version    = "15.4"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  master_username = "dbadmin"
  master_password = var.db_password

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic MySQL Instance | [`tests/basic/main.tf`](tests/basic/main.tf) |
| Advanced PostgreSQL with Read Replicas | [`tests/advanced/main.tf`](tests/advanced/main.tf) |

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | The allocated storage in gibibytes (GiB).<br/>- General Purpose (gp2/gp3): 20 GiB to 64 TiB<br/>- Provisioned IOPS (io1): 100 GiB to 64 TiB<br/>- Magnetic: 5 GiB to 3 TiB | `number` | n/a | yes |
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | Whether to allow major version upgrades. Use with caution as this may cause downtime. | `bool` | `false` | no |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | List of CIDR blocks allowed to access the database. Use sparingly for security reasons. | `list(string)` | `[]` | no |
| <a name="input_allowed_security_groups"></a> [allowed\_security\_groups](#input\_allowed\_security\_groups) | Map of security group IDs allowed to access the database. Key is a description, value is the security group ID. | `map(string)` | `{}` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Whether to apply changes immediately or during the next maintenance window. Use with caution in production. | `bool` | `false` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Whether to automatically upgrade minor engine versions during maintenance windows. | `bool` | `true` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | The AZ for the RDS instance. Only used when multi\_az is false. | `string` | `null` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | The days to retain automated backups. Valid range: 0-35. Set to 0 to disable automated backups. | `number` | `7` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | The daily time range during which automated backups are created (UTC). Format: hh24:mi-hh24:mi. Must not overlap with maintenance\_window. | `string` | `null` | no |
| <a name="input_character_set_name"></a> [character\_set\_name](#input\_character\_set\_name) | The character set name for Oracle DB instances. Not applicable to other engines. | `string` | `null` | no |
| <a name="input_copy_tags_to_snapshot"></a> [copy\_tags\_to\_snapshot](#input\_copy\_tags\_to\_snapshot) | Whether to copy all instance tags to snapshots. | `bool` | `true` | no |
| <a name="input_create_db_subnet_group"></a> [create\_db\_subnet\_group](#input\_create\_db\_subnet\_group) | Whether to create a DB subnet group. Set to false if using an existing subnet group. | `bool` | `true` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Whether to create a security group for the RDS instance. | `bool` | `true` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | The name of the database to create when the DB instance is created. If null, no initial database is created. | `string` | `null` | no |
| <a name="input_db_subnet_group_name"></a> [db\_subnet\_group\_name](#input\_db\_subnet\_group\_name) | Name of DB subnet group. If null and create\_db\_subnet\_group is true, one will be created. | `string` | `null` | no |
| <a name="input_delete_automated_backups"></a> [delete\_automated\_backups](#input\_delete\_automated\_backups) | Whether to remove automated backups immediately after the DB instance is deleted. | `bool` | `true` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Whether to enable deletion protection. Prevents accidental deletion of the database. | `bool` | `true` | no |
| <a name="input_egress_cidr_blocks"></a> [egress\_cidr\_blocks](#input\_egress\_cidr\_blocks) | List of CIDR blocks for egress traffic. Defaults to VPC CIDR only for security. Set to empty list to disable egress. | `list(string)` | `[]` | no |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | List of log types to export to CloudWatch. Valid values depend on engine:<br/>- MySQL/MariaDB: audit, error, general, slowquery<br/>- PostgreSQL: postgresql, upgrade<br/>- Oracle: alert, audit, trace, listener<br/>- SQL Server: agent, error | `list(string)` | `[]` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | Database engine type. Common values:<br/>- mysql: MySQL Community Edition<br/>- postgres: PostgreSQL<br/>- mariadb: MariaDB<br/>- oracle-ee, oracle-se2: Oracle Database<br/>- sqlserver-ee, sqlserver-se, sqlserver-ex, sqlserver-web: SQL Server<br/>- aurora-mysql, aurora-postgresql: Aurora (use Aurora module instead for production) | `string` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Version number of the database engine to use. Refer to AWS documentation for available versions per engine. | `string` | n/a | yes |
| <a name="input_final_snapshot_identifier"></a> [final\_snapshot\_identifier](#input\_final\_snapshot\_identifier) | The name of the final snapshot when the DB instance is deleted. If not provided and skip\_final\_snapshot is false, a name will be auto-generated. | `string` | `null` | no |
| <a name="input_iam_database_authentication_enabled"></a> [iam\_database\_authentication\_enabled](#input\_iam\_database\_authentication\_enabled) | Whether to enable IAM database authentication. Allows authentication using AWS IAM credentials. | `bool` | `true` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | The name of the RDS instance. Must be unique within the AWS account and region. | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | The instance type of the RDS instance. Examples:<br/>- db.t3.micro, db.t3.small: Burstable performance (dev/test)<br/>- db.t4g.micro, db.t4g.small: ARM-based burstable (cost-optimized)<br/>- db.m5.large, db.m5.xlarge: General purpose (production)<br/>- db.r5.large, db.r5.xlarge: Memory optimized (high-performance)<br/>See: https://aws.amazon.com/rds/instance-types/ | `string` | n/a | yes |
| <a name="input_iops"></a> [iops](#input\_iops) | The amount of provisioned IOPS. Required when storage\_type is io1 or io2. | `number` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN of the KMS key to use for encryption. If not specified, uses the default RDS KMS key. | `string` | `null` | no |
| <a name="input_license_model"></a> [license\_model](#input\_license\_model) | License model for commercial databases. Values:<br/>- license-included: License is included (SQL Server)<br/>- bring-your-own-license: BYOL (Oracle, SQL Server)<br/>- general-public-license: Open source databases | `string` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | The window to perform maintenance (UTC). Format: ddd:hh24:mi-ddd:hh24:mi. Must not overlap with backup\_window. | `string` | `null` | no |
| <a name="input_master_password"></a> [master\_password](#input\_master\_password) | Password for the master DB user. Required unless using snapshot\_identifier. Must meet database engine requirements. | `string` | `null` | no |
| <a name="input_master_username"></a> [master\_username](#input\_master\_username) | Username for the master DB user. Required for new instance creation; not used when restoring from snapshot or point-in-time restore. | `string` | `null` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | The upper limit of storage (GiB) to which RDS can automatically scale.<br/>Set to 0 to disable storage autoscaling.<br/>When set to a value greater than allocated\_storage, automatic storage scaling is enabled.<br/>Recommended for production databases with growing data requirements. | `number` | `0` | no |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | The interval, in seconds, between points when Enhanced Monitoring metrics are collected.<br/>Valid values: 0, 1, 5, 10, 15, 30, 60. Set to 0 to disable.<br/>Requires monitoring\_role\_arn when enabled. | `number` | `0` | no |
| <a name="input_monitoring_role_arn"></a> [monitoring\_role\_arn](#input\_monitoring\_role\_arn) | ARN of the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch. Required when monitoring\_interval > 0. | `string` | `null` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Whether to enable Multi-AZ deployment for high availability. Recommended for production databases. | `bool` | `false` | no |
| <a name="input_option_group_name"></a> [option\_group\_name](#input\_option\_group\_name) | Name of the DB option group to associate with this instance. Only applicable for Oracle and SQL Server. | `string` | `null` | no |
| <a name="input_parameter_group_name"></a> [parameter\_group\_name](#input\_parameter\_group\_name) | Name of the DB parameter group to associate with this instance. If not specified, uses the default parameter group for the engine version. | `string` | `null` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Whether to enable Performance Insights. Provides advanced database performance monitoring. | `bool` | `false` | no |
| <a name="input_performance_insights_kms_key_id"></a> [performance\_insights\_kms\_key\_id](#input\_performance\_insights\_kms\_key\_id) | ARN of the KMS key to encrypt Performance Insights data. If not specified, uses the default RDS KMS key. | `string` | `null` | no |
| <a name="input_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#input\_performance\_insights\_retention\_period) | Amount of time in days to retain Performance Insights data. Valid values: 7, 731 (2 years). Default is 7. | `number` | `7` | no |
| <a name="input_port"></a> [port](#input\_port) | The port on which the DB accepts connections. Default ports: MySQL=3306, PostgreSQL=5432, Oracle=1521, SQL Server=1433. | `number` | `null` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Whether the DB instance is publicly accessible. Set to false for production databases. | `bool` | `false` | no |
| <a name="input_read_replicas"></a> [read\_replicas](#input\_read\_replicas) | Map of read replica configurations. Key is a unique identifier for the replica.<br/>Each replica can override the following settings from the primary instance:<br/>- instance\_class: Instance type for the replica<br/>- allocated\_storage: Storage size (must be >= primary)<br/>- max\_allocated\_storage: Max storage autoscaling limit<br/>- storage\_type: Storage type (gp2, gp3, io1, io2)<br/>- iops: Provisioned IOPS<br/>- storage\_throughput: Storage throughput for gp3<br/>- publicly\_accessible: Whether replica is publicly accessible<br/>- availability\_zone: AZ for the replica<br/>- monitoring\_interval: Enhanced monitoring interval<br/>- monitoring\_role\_arn: IAM role for enhanced monitoring<br/>- performance\_insights\_enabled: Enable Performance Insights<br/>- performance\_insights\_kms\_key\_id: KMS key for PI encryption<br/>- performance\_insights\_retention\_period: PI data retention period<br/>- auto\_minor\_version\_upgrade: Auto upgrade minor versions<br/>- apply\_immediately: Apply changes immediately<br/>- tags: Additional tags for the replica | <pre>map(object({<br/>    instance_class                        = optional(string)<br/>    allocated_storage                     = optional(number)<br/>    max_allocated_storage                 = optional(number)<br/>    storage_type                          = optional(string)<br/>    iops                                  = optional(number)<br/>    storage_throughput                    = optional(number)<br/>    publicly_accessible                   = optional(bool)<br/>    availability_zone                     = optional(string)<br/>    monitoring_interval                   = optional(number)<br/>    monitoring_role_arn                   = optional(string)<br/>    performance_insights_enabled          = optional(bool)<br/>    performance_insights_kms_key_id       = optional(string)<br/>    performance_insights_retention_period = optional(number)<br/>    auto_minor_version_upgrade            = optional(bool)<br/>    apply_immediately                     = optional(bool)<br/>    tags                                  = optional(map(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_restore_to_point_in_time"></a> [restore\_to\_point\_in\_time](#input\_restore\_to\_point\_in\_time) | Configuration block for restoring to a point in time. Used to create a new DB instance from an automated backup.<br/>Attributes:<br/>- source\_db\_instance\_identifier: Identifier of the source DB instance<br/>- restore\_time: The date and time to restore from (RFC3339 format)<br/>- use\_latest\_restorable\_time: Whether to restore to the latest restorable time (default: false) | <pre>object({<br/>    source_db_instance_identifier = optional(string)<br/>    restore_time                  = optional(string)<br/>    use_latest_restorable_time    = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Whether to skip the final snapshot when the DB instance is deleted. Set to false for production databases. | `bool` | `false` | no |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier) | Identifier of a DB snapshot to restore from. Used to create a new DB instance from a snapshot. | `string` | `null` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Whether to enable storage encryption. Highly recommended for production databases. | `bool` | `true` | no |
| <a name="input_storage_throughput"></a> [storage\_throughput](#input\_storage\_throughput) | Storage throughput value for gp3 storage type in MB/s. Valid range: 125-1000. | `number` | `null` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Storage type for the DB instance. Valid values:<br/>- gp2: General Purpose SSD (baseline 3 IOPS/GiB, burst to 3000 IOPS)<br/>- gp3: General Purpose SSD (baseline 3000 IOPS, configurable)<br/>- io1: Provisioned IOPS SSD (high performance, specify iops)<br/>- io2: Provisioned IOPS SSD (higher durability than io1)<br/>- standard: Magnetic storage (legacy, not recommended) | `string` | `"gp3"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of VPC subnet IDs for the DB subnet group. Required for Multi-AZ deployments. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Time zone of the DB instance. Only applicable for SQL Server. | `string` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the RDS instance will be created. Required if create\_security\_group is true. | `string` | `null` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | List of VPC security group IDs to associate with the instance. If null and create\_security\_group is true, a security group will be created. | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_instance_address"></a> [db\_instance\_address](#output\_db\_instance\_address) | The hostname of the RDS instance. Use this as the host parameter in database connection strings. |
| <a name="output_db_instance_allocated_storage"></a> [db\_instance\_allocated\_storage](#output\_db\_instance\_allocated\_storage) | The amount of allocated storage in gibibytes. |
| <a name="output_db_instance_arn"></a> [db\_instance\_arn](#output\_db\_instance\_arn) | The ARN of the RDS instance. Use this for IAM policies and cross-account access configurations. |
| <a name="output_db_instance_availability_zone"></a> [db\_instance\_availability\_zone](#output\_db\_instance\_availability\_zone) | The availability zone of the RDS instance. |
| <a name="output_db_instance_backup_retention_period"></a> [db\_instance\_backup\_retention\_period](#output\_db\_instance\_backup\_retention\_period) | The backup retention period in days. |
| <a name="output_db_instance_backup_window"></a> [db\_instance\_backup\_window](#output\_db\_instance\_backup\_window) | The daily time range during which automated backups are created. |
| <a name="output_db_instance_ca_cert_identifier"></a> [db\_instance\_ca\_cert\_identifier](#output\_db\_instance\_ca\_cert\_identifier) | The identifier of the CA certificate for the DB instance. |
| <a name="output_db_instance_cloudwatch_log_groups"></a> [db\_instance\_cloudwatch\_log\_groups](#output\_db\_instance\_cloudwatch\_log\_groups) | List of CloudWatch log groups for the RDS instance. |
| <a name="output_db_instance_endpoint"></a> [db\_instance\_endpoint](#output\_db\_instance\_endpoint) | The connection endpoint for the RDS instance in address:port format. Use this to connect applications to the database. |
| <a name="output_db_instance_engine"></a> [db\_instance\_engine](#output\_db\_instance\_engine) | The database engine type (e.g., mysql, postgres, mariadb). |
| <a name="output_db_instance_engine_version"></a> [db\_instance\_engine\_version](#output\_db\_instance\_engine\_version) | The running version of the database engine. |
| <a name="output_db_instance_hosted_zone_id"></a> [db\_instance\_hosted\_zone\_id](#output\_db\_instance\_hosted\_zone\_id) | The canonical hosted zone ID of the DB instance (for Route53 alias records). |
| <a name="output_db_instance_id"></a> [db\_instance\_id](#output\_db\_instance\_id) | The RDS instance identifier. Use this for resource references and CLI operations. |
| <a name="output_db_instance_latest_restorable_time"></a> [db\_instance\_latest\_restorable\_time](#output\_db\_instance\_latest\_restorable\_time) | The latest time to which a database can be restored with point-in-time restore. |
| <a name="output_db_instance_maintenance_window"></a> [db\_instance\_maintenance\_window](#output\_db\_instance\_maintenance\_window) | The window of time for system maintenance. |
| <a name="output_db_instance_monitoring_interval"></a> [db\_instance\_monitoring\_interval](#output\_db\_instance\_monitoring\_interval) | The interval, in seconds, between points when Enhanced Monitoring metrics are collected. |
| <a name="output_db_instance_multi_az"></a> [db\_instance\_multi\_az](#output\_db\_instance\_multi\_az) | Whether the RDS instance is multi-AZ. |
| <a name="output_db_instance_name"></a> [db\_instance\_name](#output\_db\_instance\_name) | The database name (if one was created when the instance was created). |
| <a name="output_db_instance_performance_insights_enabled"></a> [db\_instance\_performance\_insights\_enabled](#output\_db\_instance\_performance\_insights\_enabled) | Whether Performance Insights is enabled. |
| <a name="output_db_instance_port"></a> [db\_instance\_port](#output\_db\_instance\_port) | The port number on which the database accepts connections. |
| <a name="output_db_instance_resource_id"></a> [db\_instance\_resource\_id](#output\_db\_instance\_resource\_id) | The unique resource ID of the RDS instance. Used for CloudWatch metrics and performance insights. |
| <a name="output_db_instance_status"></a> [db\_instance\_status](#output\_db\_instance\_status) | The RDS instance status. |
| <a name="output_db_instance_storage_encrypted"></a> [db\_instance\_storage\_encrypted](#output\_db\_instance\_storage\_encrypted) | Whether the DB instance is encrypted. |
| <a name="output_db_instance_storage_type"></a> [db\_instance\_storage\_type](#output\_db\_instance\_storage\_type) | The storage type associated with the DB instance. |
| <a name="output_db_instance_username"></a> [db\_instance\_username](#output\_db\_instance\_username) | The master username for the database. |
| <a name="output_db_subnet_group_arn"></a> [db\_subnet\_group\_arn](#output\_db\_subnet\_group\_arn) | The ARN of the DB subnet group. |
| <a name="output_db_subnet_group_id"></a> [db\_subnet\_group\_id](#output\_db\_subnet\_group\_id) | The DB subnet group name. |
| <a name="output_read_replica_addresses"></a> [read\_replica\_addresses](#output\_read\_replica\_addresses) | Map of read replica hostnames. |
| <a name="output_read_replica_arns"></a> [read\_replica\_arns](#output\_read\_replica\_arns) | Map of read replica ARNs. |
| <a name="output_read_replica_endpoints"></a> [read\_replica\_endpoints](#output\_read\_replica\_endpoints) | Map of read replica endpoints in address:port format. |
| <a name="output_read_replica_ids"></a> [read\_replica\_ids](#output\_read\_replica\_ids) | Map of read replica identifiers. |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | The ARN of the security group created for the RDS instance (if create\_security\_group was true). |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group created for the RDS instance (if create\_security\_group was true). |
| <a name="output_tags"></a> [tags](#output\_tags) | All tags applied to the RDS instance. |
<!-- END_TF_DOCS -->
</details>
