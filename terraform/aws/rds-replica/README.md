# RDS Replica Module

A Terraform module for managing standalone RDS read replicas with explicit identifiers, designed for importing existing replicas that do not follow the default naming convention.

## Features

- Explicit replica identifier for imports
- Supports storage autoscaling and gp3 throughput
- Optional parameter group overrides
- VPC security group attachment
- Performance Insights and monitoring options
- Tagging support

## Quick Start

```hcl
module "rds_replica" {
  source = "github.com/llamandcoco/infra-modules//terraform/aws/rds-replica?ref=<commit-sha>"

  identifier          = "my-read-replica"
  source_db_identifier = "my-primary-db"
  instance_class      = "db.t3.micro"

  vpc_security_group_ids = ["sg-12345678"]
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic Replica | [`tests/basic/main.tf`](tests/basic/main.tf) |

## Testing

```bash
cd tests/basic && terraform init -backend=false && terraform plan
```

## Terraform Docs

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
| [aws_db_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | Allocated storage (GiB). Optional for replicas; set to null to inherit from primary. | `number` | `null` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Apply changes immediately or during maintenance window. | `bool` | `false` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Auto minor version upgrades. | `bool` | `true` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Availability zone for the replica. | `string` | `null` | no |
| <a name="input_copy_tags_to_snapshot"></a> [copy\_tags\_to\_snapshot](#input\_copy\_tags\_to\_snapshot) | Copy tags to snapshots. | `bool` | `true` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Enable deletion protection. | `bool` | `true` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Replica identifier. Must match the existing DB instance identifier when importing. | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | DB instance class for the read replica. | `string` | n/a | yes |
| <a name="input_iops"></a> [iops](#input\_iops) | Provisioned IOPS (required for io1/io2). | `number` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key ARN for encryption. | `string` | `null` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | Max allocated storage for autoscaling (0 = disabled). | `number` | `0` | no |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | Enhanced monitoring interval (0, 1, 5, 10, 15, 30, 60). | `number` | `0` | no |
| <a name="input_monitoring_role_arn"></a> [monitoring\_role\_arn](#input\_monitoring\_role\_arn) | IAM role ARN for enhanced monitoring. | `string` | `null` | no |
| <a name="input_parameter_group_name"></a> [parameter\_group\_name](#input\_parameter\_group\_name) | Parameter group name for the replica. | `string` | `null` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Enable Performance Insights. | `bool` | `false` | no |
| <a name="input_performance_insights_kms_key_id"></a> [performance\_insights\_kms\_key\_id](#input\_performance\_insights\_kms\_key\_id) | KMS key ARN for Performance Insights. | `string` | `null` | no |
| <a name="input_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#input\_performance\_insights\_retention\_period) | Performance Insights retention period (7 or 731). | `number` | `7` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Whether the replica is publicly accessible. | `bool` | `false` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Skip final snapshot on destroy. | `bool` | `true` | no |
| <a name="input_source_db_identifier"></a> [source\_db\_identifier](#input\_source\_db\_identifier) | Identifier of the primary DB instance to replicate from. | `string` | n/a | yes |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Whether storage is encrypted. | `bool` | `true` | no |
| <a name="input_storage_throughput"></a> [storage\_throughput](#input\_storage\_throughput) | Storage throughput (MB/s) for gp3. | `number` | `null` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Storage type (gp2, gp3, io1, io2, standard). | `string` | `"gp3"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the replica. | `map(string)` | `{}` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | Security group IDs for the replica. | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address"></a> [address](#output\_address) | Address of the replica instance. |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the replica instance. |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Endpoint of the replica instance. |
| <a name="output_hosted_zone_id"></a> [hosted\_zone\_id](#output\_hosted\_zone\_id) | Hosted zone ID of the replica endpoint. |
| <a name="output_id"></a> [id](#output\_id) | ID of the replica instance. |
| <a name="output_identifier"></a> [identifier](#output\_identifier) | Identifier of the replica instance. |
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | Resource ID of the replica instance. |
| <a name="output_status"></a> [status](#output\_status) | Status of the replica instance. |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags assigned to the replica. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | All tags assigned to the replica. |
<!-- END_TF_DOCS -->
