# RDS Replica Module

A Terraform module for creating a standalone AWS RDS read replica from an existing RDS primary instance, enabling horizontal scaling of read workloads across availability zones.

## Features

- Standalone Read Replica from any existing RDS primary instance
- Cross-AZ Placement for improved read performance and fault isolation
- Encryption configuration with optional override
- Security Group Management with configurable ingress rules
- Enhanced Monitoring via CloudWatch and Performance Insights
- Storage Autoscaling with configurable upper bounds
- Deletion Protection to prevent accidental removal
- Independent Instance Sizing to right-size replica compute and storage

## Quick Start

```hcl
module "rds_replica" {
  source = "github.com/llamandcoco/infra-modules//terraform/aws/rds-replica?ref=<commit-sha>"

  identifier                    = "myapp-db-replica"
  source_db_instance_identifier = "myapp-db"
  instance_class                = "db.t3.micro"

  vpc_id = var.vpc_id
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic Read Replica | [`tests/basic/main.tf`](tests/basic/main.tf) |

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
| [aws_db_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | The allocated storage in GiB for the replica. Must be >= the source instance's storage. If null, inherits from source. | `number` | `null` | no |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | List of CIDR blocks allowed to access the replica. Use sparingly for security reasons. | `list(string)` | `[]` | no |
| <a name="input_allowed_security_groups"></a> [allowed\_security\_groups](#input\_allowed\_security\_groups) | Map of security group IDs allowed to access the replica. Key is a description, value is the security group ID. | `map(string)` | `{}` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Whether to apply changes immediately or during the next maintenance window. | `bool` | `false` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Whether to automatically upgrade minor engine versions during maintenance windows. | `bool` | `true` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | The AZ for the replica instance. | `string` | `null` | no |
| <a name="input_copy_tags_to_snapshot"></a> [copy\_tags\_to\_snapshot](#input\_copy\_tags\_to\_snapshot) | Whether to copy all instance tags to snapshots. | `bool` | `true` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Whether to create a security group for the RDS replica. | `bool` | `true` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Whether to enable deletion protection. Prevents accidental deletion of the replica. | `bool` | `true` | no |
| <a name="input_egress_cidr_blocks"></a> [egress\_cidr\_blocks](#input\_egress\_cidr\_blocks) | List of CIDR blocks for egress traffic. Set to empty list to disable egress rules. | `list(string)` | `[]` | no |
| <a name="input_final_snapshot_identifier"></a> [final\_snapshot\_identifier](#input\_final\_snapshot\_identifier) | Custom identifier for the final snapshot when skip\_final\_snapshot is false. If null, a default is generated. | `string` | `null` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | The name of the RDS replica instance. Must be unique within the AWS account and region. | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | The instance type of the RDS replica instance. Examples:<br/>- db.t3.micro, db.t3.small: Burstable performance (dev/test)<br/>- db.t4g.micro, db.t4g.small: ARM-based burstable (cost-optimized)<br/>- db.m5.large, db.m5.xlarge: General purpose (production)<br/>- db.r5.large, db.r5.xlarge: Memory optimized (high-performance)<br/>See: https://aws.amazon.com/rds/instance-types/ | `string` | n/a | yes |
| <a name="input_iops"></a> [iops](#input\_iops) | The amount of provisioned IOPS. Required when storage\_type is io1 or io2. | `number` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN of the KMS key to use for replica encryption. If not specified, uses the default RDS KMS key. | `string` | `null` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | The upper limit of storage (GiB) for autoscaling. Set to 0 to disable storage autoscaling. | `number` | `0` | no |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | The interval in seconds between Enhanced Monitoring metric collection.<br/>Valid values: 0, 1, 5, 10, 15, 30, 60. Set to 0 to disable.<br/>Requires monitoring\_role\_arn when enabled. | `number` | `0` | no |
| <a name="input_monitoring_role_arn"></a> [monitoring\_role\_arn](#input\_monitoring\_role\_arn) | ARN of the IAM role for Enhanced Monitoring. Required when monitoring\_interval > 0. | `string` | `null` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Whether to enable Performance Insights on the replica. | `bool` | `false` | no |
| <a name="input_performance_insights_kms_key_id"></a> [performance\_insights\_kms\_key\_id](#input\_performance\_insights\_kms\_key\_id) | ARN of the KMS key to encrypt Performance Insights data. | `string` | `null` | no |
| <a name="input_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#input\_performance\_insights\_retention\_period) | Amount of time in days to retain Performance Insights data. Valid values: 7, 731 (2 years). | `number` | `7` | no |
| <a name="input_port"></a> [port](#input\_port) | The port on which the replica accepts connections. Inherits from source if null. | `number` | `null` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Whether the replica is publicly accessible. Set to false for production databases. | `bool` | `false` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Whether to skip the final snapshot when the replica is deleted. | `bool` | `false` | no |
| <a name="input_source_db_instance_identifier"></a> [source\_db\_instance\_identifier](#input\_source\_db\_instance\_identifier) | The identifier of the source RDS instance to replicate. Must have automated backups enabled (backup\_retention\_period > 0). | `string` | n/a | yes |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Whether to enable storage encryption on the replica. If null, uses AWS default behavior for replicas. | `bool` | `null` | no |
| <a name="input_storage_throughput"></a> [storage\_throughput](#input\_storage\_throughput) | Storage throughput value for gp3 storage type in MB/s. Valid range: 125-1000. | `number` | `null` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Storage type for the replica. Valid values:<br/>- gp2: General Purpose SSD<br/>- gp3: General Purpose SSD (baseline 3000 IOPS, configurable)<br/>- io1: Provisioned IOPS SSD<br/>- io2: Provisioned IOPS SSD (higher durability)<br/>- standard: Magnetic storage (legacy) | `string` | `"gp3"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the replica will be created. Required if create\_security\_group is true. | `string` | `null` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | List of VPC security group IDs to associate with the replica. If null and create\_security\_group is true, a security group will be created. | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_instance_address"></a> [db\_instance\_address](#output\_db\_instance\_address) | The hostname of the replica. Use this as the host in database connection strings. |
| <a name="output_db_instance_allocated_storage"></a> [db\_instance\_allocated\_storage](#output\_db\_instance\_allocated\_storage) | The allocated storage in GiB for the replica. |
| <a name="output_db_instance_arn"></a> [db\_instance\_arn](#output\_db\_instance\_arn) | The ARN of the RDS replica instance. |
| <a name="output_db_instance_availability_zone"></a> [db\_instance\_availability\_zone](#output\_db\_instance\_availability\_zone) | The availability zone of the replica. |
| <a name="output_db_instance_ca_cert_identifier"></a> [db\_instance\_ca\_cert\_identifier](#output\_db\_instance\_ca\_cert\_identifier) | The identifier of the CA certificate for the replica. |
| <a name="output_db_instance_endpoint"></a> [db\_instance\_endpoint](#output\_db\_instance\_endpoint) | The connection endpoint for the replica in address:port format. |
| <a name="output_db_instance_engine"></a> [db\_instance\_engine](#output\_db\_instance\_engine) | The database engine type of the replica. |
| <a name="output_db_instance_engine_version"></a> [db\_instance\_engine\_version](#output\_db\_instance\_engine\_version) | The running version of the database engine. |
| <a name="output_db_instance_hosted_zone_id"></a> [db\_instance\_hosted\_zone\_id](#output\_db\_instance\_hosted\_zone\_id) | The canonical hosted zone ID of the replica (for Route53 alias records). |
| <a name="output_db_instance_id"></a> [db\_instance\_id](#output\_db\_instance\_id) | The RDS replica instance identifier. |
| <a name="output_db_instance_monitoring_interval"></a> [db\_instance\_monitoring\_interval](#output\_db\_instance\_monitoring\_interval) | The Enhanced Monitoring collection interval in seconds. |
| <a name="output_db_instance_performance_insights_enabled"></a> [db\_instance\_performance\_insights\_enabled](#output\_db\_instance\_performance\_insights\_enabled) | Whether Performance Insights is enabled on the replica. |
| <a name="output_db_instance_port"></a> [db\_instance\_port](#output\_db\_instance\_port) | The port number on which the replica accepts connections. |
| <a name="output_db_instance_resource_id"></a> [db\_instance\_resource\_id](#output\_db\_instance\_resource\_id) | The unique resource ID of the replica. Used for CloudWatch metrics and Performance Insights. |
| <a name="output_db_instance_status"></a> [db\_instance\_status](#output\_db\_instance\_status) | The current status of the RDS replica instance. |
| <a name="output_db_instance_storage_encrypted"></a> [db\_instance\_storage\_encrypted](#output\_db\_instance\_storage\_encrypted) | Whether the replica storage is encrypted. |
| <a name="output_db_instance_storage_type"></a> [db\_instance\_storage\_type](#output\_db\_instance\_storage\_type) | The storage type of the replica. |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | The ARN of the security group created for the replica (if create\_security\_group was true). |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group created for the replica (if create\_security\_group was true). |
| <a name="output_tags"></a> [tags](#output\_tags) | All tags applied to the replica. |
<!-- END_TF_DOCS -->
</details>
