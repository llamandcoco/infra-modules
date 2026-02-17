# ElastiCache Module

A comprehensive Terraform module for creating and managing AWS ElastiCache clusters with support for both Redis and Memcached engines.

## Features

- **Multi-Engine** - Support for both Redis and Memcached with engine-specific optimizations
- **High Availability** - Automatic failover and Multi-AZ support for Redis clusters
- **Security** - At-rest and in-transit encryption with optional auth tokens (Redis)
- **Backups** - Automated snapshots with configurable retention for Redis
- **Custom Parameters** - Flexible parameter group configuration for both engines
- **Subnet Groups** - Automatic subnet group creation or use existing groups
- **Logging** - Optional CloudWatch Logs and Kinesis Firehose integration for Redis
- **Maintenance** - Configurable maintenance windows and auto-upgrade settings

## Quick Start

```hcl
module "elasticache" {
  source = "github.com/llamandcoco/infra-modules//terraform/elasticache?ref=<commit-sha>"

  cluster_id         = "my-redis-cluster"
  engine             = "redis"
  node_type          = "cache.t3.micro"
  subnet_ids         = ["subnet-12345678", "subnet-87654321"]
  security_group_ids = ["sg-12345678"]
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic Redis Configuration | [`tests/basic/main.tf`](tests/basic/main.tf) |
| Advanced Redis HA & Memcached | [`tests/advanced/main.tf`](tests/advanced/main.tf) |

**Usage:**
```bash
# View example
ls tests/basic/

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
| [aws_elasticache_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_cluster) | resource |
| [aws_elasticache_parameter_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_parameter_group) | resource |
| [aws_elasticache_replication_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group) | resource |
| [aws_elasticache_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Apply changes immediately instead of during the next maintenance window.<br/>Use with caution as this may cause downtime. | `bool` | `false` | no |
| <a name="input_at_rest_encryption_enabled"></a> [at\_rest\_encryption\_enabled](#input\_at\_rest\_encryption\_enabled) | Enable encryption at rest for Redis data. <br/>Can only be enabled when creating a new cluster. | `bool` | `true` | no |
| <a name="input_auth_token"></a> [auth\_token](#input\_auth\_token) | Password used to access a password-protected Redis server.<br/>Only used when transit\_encryption\_enabled is true.<br/>Must be 16-128 alphanumeric characters. | `string` | `null` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Automatically upgrade to new minor versions during the maintenance window. | `bool` | `true` | no |
| <a name="input_automatic_failover_enabled"></a> [automatic\_failover\_enabled](#input\_automatic\_failover\_enabled) | Enable automatic failover for Redis. Requires at least 2 nodes and multi\_az\_enabled.<br/>Automatically promotes a replica to primary if the primary fails. | `bool` | `false` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones for Memcached cluster nodes. Only used when num\_cache\_nodes > 1 for Memcached. | `list(string)` | `[]` | no |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | Unique identifier for the ElastiCache cluster. Must be lowercase alphanumeric and hyphens only. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description for the replication group (Redis only). | `string` | `"Managed by Terraform"` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | Cache engine to use. Valid values: redis or memcached. | `string` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Version number of the cache engine. For Redis, use 6.x or 7.x. For Memcached, use 1.6.x. | `string` | `null` | no |
| <a name="input_final_snapshot_identifier"></a> [final\_snapshot\_identifier](#input\_final\_snapshot\_identifier) | Name of the final snapshot to create when the cluster is deleted (Redis only). If null, no final snapshot is created. | `string` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN of the KMS key to use for at-rest encryption.<br/>If not specified, uses the default AWS managed key for ElastiCache. | `string` | `null` | no |
| <a name="input_log_delivery_configuration"></a> [log\_delivery\_configuration](#input\_log\_delivery\_configuration) | Log delivery configuration for Redis slow log and engine log.<br/>Each configuration must specify destination, destination\_type, log\_format, and log\_type. | <pre>list(object({<br/>    destination      = string<br/>    destination_type = string<br/>    log_format       = string<br/>    log_type         = string<br/>  }))</pre> | `[]` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Weekly time range during which system maintenance can occur.<br/>Format: ddd:HH:MM-ddd:HH:MM in UTC (e.g., 'sun:05:00-sun:09:00').<br/>Must not overlap with snapshot\_window. | `string` | `"sun:05:00-sun:09:00"` | no |
| <a name="input_multi_az_enabled"></a> [multi\_az\_enabled](#input\_multi\_az\_enabled) | Enable Multi-AZ for Redis. Distributes replica nodes across multiple availability zones.<br/>Required for automatic failover. | `bool` | `false` | no |
| <a name="input_node_type"></a> [node\_type](#input\_node\_type) | Instance type for cache nodes (e.g., cache.t3.micro, cache.r6g.large). | `string` | n/a | yes |
| <a name="input_notification_topic_arn"></a> [notification\_topic\_arn](#input\_notification\_topic\_arn) | ARN of an SNS topic to send ElastiCache notifications to (cluster events, failures, etc.). | `string` | `null` | no |
| <a name="input_num_cache_nodes"></a> [num\_cache\_nodes](#input\_num\_cache\_nodes) | Number of cache nodes in the cluster.<br/>- For Redis: Number of replica nodes + 1 primary (minimum 2 for automatic failover)<br/>- For Memcached: Total number of nodes in the cluster | `number` | `1` | no |
| <a name="input_parameter_group_family"></a> [parameter\_group\_family](#input\_parameter\_group\_family) | Parameter group family for the cache engine (e.g., redis7, redis6.x, memcached1.6). If null, uses redis7 for Redis or memcached1.6 for Memcached. | `string` | `null` | no |
| <a name="input_parameter_group_name"></a> [parameter\_group\_name](#input\_parameter\_group\_name) | Name of an existing ElastiCache parameter group to use. If null, a new parameter group will be created. | `string` | `null` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | List of cache parameters to apply. Each parameter must have a name and value. | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_port"></a> [port](#input\_port) | Port number on which the cache accepts connections. Default: 6379 for Redis, 11211 for Memcached. | `number` | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs to associate with the ElastiCache cluster. | `list(string)` | `[]` | no |
| <a name="input_snapshot_retention_limit"></a> [snapshot\_retention\_limit](#input\_snapshot\_retention\_limit) | Number of days to retain automatic snapshots (Redis only). <br/>Set to 0 to disable automated backups. Maximum: 35 days. | `number` | `7` | no |
| <a name="input_snapshot_window"></a> [snapshot\_window](#input\_snapshot\_window) | Daily time range during which ElastiCache begins taking daily snapshots (Redis only).<br/>Format: HH:MM-HH:MM in UTC (e.g., '03:00-05:00'). Must not overlap with maintenance\_window. | `string` | `"03:00-05:00"` | no |
| <a name="input_subnet_group_name"></a> [subnet\_group\_name](#input\_subnet\_group\_name) | Name of an existing ElastiCache subnet group to use. If null, a new subnet group will be created. | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of VPC subnet IDs for the cache subnet group. Required unless subnet\_group\_name is specified. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. Use this to add consistent tagging across your infrastructure. | `map(string)` | `{}` | no |
| <a name="input_transit_encryption_enabled"></a> [transit\_encryption\_enabled](#input\_transit\_encryption\_enabled) | Enable in-transit encryption (TLS) for Redis.<br/>Can only be enabled when creating a new cluster. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_at_rest_encryption_enabled"></a> [at\_rest\_encryption\_enabled](#output\_at\_rest\_encryption\_enabled) | Whether at-rest encryption is enabled (Redis only). |
| <a name="output_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#output\_auto\_minor\_version\_upgrade) | Whether automatic minor version upgrades are enabled. |
| <a name="output_automatic_failover_enabled"></a> [automatic\_failover\_enabled](#output\_automatic\_failover\_enabled) | Whether automatic failover is enabled (Redis only). |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | ID of the ElastiCache cluster (Redis or Memcached). |
| <a name="output_engine"></a> [engine](#output\_engine) | Cache engine being used (redis or memcached). |
| <a name="output_engine_version"></a> [engine\_version](#output\_engine\_version) | Version of the cache engine. |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | ARN of the KMS key used for at-rest encryption. |
| <a name="output_maintenance_window"></a> [maintenance\_window](#output\_maintenance\_window) | Weekly time range for system maintenance. |
| <a name="output_memcached_cache_nodes"></a> [memcached\_cache\_nodes](#output\_memcached\_cache\_nodes) | List of cache node addresses for the Memcached cluster. |
| <a name="output_memcached_cluster_address"></a> [memcached\_cluster\_address](#output\_memcached\_cluster\_address) | DNS name of the Memcached cluster configuration endpoint. |
| <a name="output_memcached_cluster_arn"></a> [memcached\_cluster\_arn](#output\_memcached\_cluster\_arn) | ARN of the ElastiCache Memcached cluster. Use this for IAM policies and cross-account access. |
| <a name="output_memcached_cluster_id"></a> [memcached\_cluster\_id](#output\_memcached\_cluster\_id) | ID of the ElastiCache Memcached cluster. Use this for resource references and configuration. |
| <a name="output_memcached_configuration_endpoint"></a> [memcached\_configuration\_endpoint](#output\_memcached\_configuration\_endpoint) | Configuration endpoint address for Memcached cluster. |
| <a name="output_multi_az_enabled"></a> [multi\_az\_enabled](#output\_multi\_az\_enabled) | Whether Multi-AZ is enabled (Redis only). |
| <a name="output_node_type"></a> [node\_type](#output\_node\_type) | Instance type of the cache nodes. |
| <a name="output_num_cache_nodes"></a> [num\_cache\_nodes](#output\_num\_cache\_nodes) | Number of cache nodes in the cluster. |
| <a name="output_parameter_group_id"></a> [parameter\_group\_id](#output\_parameter\_group\_id) | ID of the ElastiCache parameter group. |
| <a name="output_parameter_group_name"></a> [parameter\_group\_name](#output\_parameter\_group\_name) | Name of the ElastiCache parameter group. |
| <a name="output_port"></a> [port](#output\_port) | Port number on which the cache accepts connections. |
| <a name="output_redis_configuration_endpoint_address"></a> [redis\_configuration\_endpoint\_address](#output\_redis\_configuration\_endpoint\_address) | Configuration endpoint address for Redis cluster mode enabled clusters. |
| <a name="output_redis_member_clusters"></a> [redis\_member\_clusters](#output\_redis\_member\_clusters) | List of cluster IDs that are part of this Redis replication group. |
| <a name="output_redis_primary_endpoint_address"></a> [redis\_primary\_endpoint\_address](#output\_redis\_primary\_endpoint\_address) | Primary endpoint address for Redis cluster. Use this for write operations. |
| <a name="output_redis_reader_endpoint_address"></a> [redis\_reader\_endpoint\_address](#output\_redis\_reader\_endpoint\_address) | Reader endpoint address for Redis cluster. Use this for read operations to distribute load across replicas. |
| <a name="output_replication_group_arn"></a> [replication\_group\_arn](#output\_replication\_group\_arn) | ARN of the ElastiCache Redis replication group. Use this for IAM policies and cross-account access. |
| <a name="output_replication_group_id"></a> [replication\_group\_id](#output\_replication\_group\_id) | ID of the ElastiCache Redis replication group. Use this for resource references and configuration. |
| <a name="output_snapshot_retention_limit"></a> [snapshot\_retention\_limit](#output\_snapshot\_retention\_limit) | Number of days to retain automatic snapshots (Redis only). |
| <a name="output_snapshot_window"></a> [snapshot\_window](#output\_snapshot\_window) | Daily time range for automated snapshots (Redis only). |
| <a name="output_subnet_group_id"></a> [subnet\_group\_id](#output\_subnet\_group\_id) | ID of the ElastiCache subnet group. |
| <a name="output_subnet_group_name"></a> [subnet\_group\_name](#output\_subnet\_group\_name) | Name of the ElastiCache subnet group. |
| <a name="output_tags"></a> [tags](#output\_tags) | All tags applied to the cluster resources. |
| <a name="output_transit_encryption_enabled"></a> [transit\_encryption\_enabled](#output\_transit\_encryption\_enabled) | Whether in-transit encryption is enabled (Redis only). |
<!-- END_TF_DOCS -->
</details>
