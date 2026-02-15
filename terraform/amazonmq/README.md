# AmazonMQ Module

A production-ready Terraform module for creating and managing AWS AmazonMQ message brokers with support for ActiveMQ and RabbitMQ engines, high availability deployments, KMS encryption, and CloudWatch logging.

## Features

- **Multiple Engines:** Support for both ActiveMQ and RabbitMQ message brokers
- **High Availability:** SINGLE_INSTANCE, ACTIVE_STANDBY_MULTI_AZ, and CLUSTER_MULTI_AZ deployment modes
- **Security:** KMS encryption, VPC isolation, security groups, and LDAP authentication (ActiveMQ)
- **Monitoring:** CloudWatch Logs integration for general and audit logs
- **Storage Options:** EBS or EFS storage with configurable capacity
- **Custom Configurations:** Support for broker-specific XML configurations
- **Maintenance Windows:** Configurable maintenance windows with auto minor version upgrades
- **User Management:** Supports single broker user configuration

## Quick Start

```hcl
module "amazonmq" {
  source = "github.com/llamandcoco/infra-modules//terraform/amazonmq?ref=<commit-sha>"

  broker_name        = "my-broker"
  engine_type        = "ActiveMQ"
  engine_version     = "5.18.3"
  host_instance_type = "mq.m5.large"

  subnet_ids      = ["subnet-12345678"]
  security_groups = ["sg-12345678"]

  users = [
    {
      username       = "admin"
      password       = "SecurePassword123!"
      console_access = true
    }
  ]
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic | [`tests/basic/main.tf`](tests/basic/main.tf) |

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
| [aws_mq_broker.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/mq_broker) | resource |
| [aws_mq_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/mq_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authentication_strategy"></a> [authentication\_strategy](#input\_authentication\_strategy) | Authentication strategy for the broker.<br><br>Valid values:<br>- SIMPLE: Simple username/password authentication (default)<br>- LDAP: LDAP-based authentication (ActiveMQ only, requires ldap\_server\_metadata)<br><br>RabbitMQ only supports SIMPLE authentication. | `string` | `"SIMPLE"` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Enable automatic minor version upgrades during maintenance windows.<br><br>- true: Automatically upgrade to newer minor versions (recommended)<br>- false: Manual control over version upgrades<br><br>Minor version upgrades include bug fixes and security patches. | `bool` | `true` | no |
| <a name="input_broker_name"></a> [broker\_name](#input\_broker\_name) | Name of the AmazonMQ broker.<br>Must be unique within your AWS account and region.<br><br>Constraints:<br>- Must be between 1 and 50 characters<br>- Can only contain alphanumeric characters, dashes, and underscores | `string` | n/a | yes |
| <a name="input_configuration_data"></a> [configuration\_data](#input\_configuration\_data) | XML configuration data for the broker.<br>Only used when create\_configuration = true.<br><br>For ActiveMQ, this is an ActiveMQ XML configuration.<br>For RabbitMQ, this is a base64-encoded RabbitMQ configuration.<br><br>Example (ActiveMQ):<br><?xml version="1.0" encoding="UTF-8" standalone="yes"?><br><broker xmlns="http://activemq.apache.org/schema/core"><br>  <plugins><br>    <forcePersistencyModeBrokerPlugin persistenceFlag="true"/><br>  </plugins><br></broker> | `string` | `null` | no |
| <a name="input_configuration_description"></a> [configuration\_description](#input\_configuration\_description) | Description of the configuration.<br>Only used when create\_configuration = true. | `string` | `"Managed by Terraform"` | no |
| <a name="input_configuration_id"></a> [configuration\_id](#input\_configuration\_id) | ID of an existing broker configuration to apply.<br><br>If specified, the broker will use this configuration instead of defaults.<br>Cannot be used with create\_configuration = true. | `string` | `null` | no |
| <a name="input_configuration_name"></a> [configuration\_name](#input\_configuration\_name) | Name of the configuration to create.<br>Only used when create\_configuration = true.<br><br>If not specified, defaults to '{broker\_name}-config'. | `string` | `null` | no |
| <a name="input_configuration_revision"></a> [configuration\_revision](#input\_configuration\_revision) | Revision number of the configuration to use.<br><br>Only used when configuration\_id is specified.<br>If not specified, uses the latest revision. | `number` | `null` | no |
| <a name="input_create_configuration"></a> [create\_configuration](#input\_create\_configuration) | Create a broker configuration resource.<br><br>- true: Creates a configuration with custom broker settings<br>- false: No configuration is created (uses broker defaults)<br><br>Configurations allow you to customize broker behavior with XML settings. | `bool` | `false` | no |
| <a name="input_deployment_mode"></a> [deployment\_mode](#input\_deployment\_mode) | Deployment mode for the broker.<br><br>Valid values:<br>- SINGLE\_INSTANCE: Single broker in one AZ (dev/test, not HA)<br>- ACTIVE\_STANDBY\_MULTI\_AZ: Active/Standby pair across 2 AZs (HA for ActiveMQ)<br>- CLUSTER\_MULTI\_AZ: Cluster of 3 nodes across 3 AZs (HA for RabbitMQ only)<br><br>ActiveMQ supports: SINGLE\_INSTANCE, ACTIVE\_STANDBY\_MULTI\_AZ<br>RabbitMQ supports: SINGLE\_INSTANCE, CLUSTER\_MULTI\_AZ | `string` | `"SINGLE_INSTANCE"` | no |
| <a name="input_enable_audit_log"></a> [enable\_audit\_log](#input\_enable\_audit\_log) | Enable audit logging to CloudWatch Logs (ActiveMQ only).<br><br>Audit logs track management actions and user authentication.<br>Recommended for compliance and security monitoring. | `bool` | `false` | no |
| <a name="input_enable_general_log"></a> [enable\_general\_log](#input\_enable\_general\_log) | Enable general logging to CloudWatch Logs.<br><br>General logs contain informational messages about the broker's operation.<br>Useful for troubleshooting and monitoring. | `bool` | `false` | no |
| <a name="input_engine_type"></a> [engine\_type](#input\_engine\_type) | Type of broker engine.<br><br>Valid values:<br>- ActiveMQ: Apache ActiveMQ message broker<br>- RabbitMQ: RabbitMQ message broker | `string` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Version of the broker engine.<br><br>ActiveMQ versions: 5.15.x, 5.16.x, 5.17.x, 5.18.x<br>RabbitMQ versions: 3.8.x, 3.9.x, 3.10.x, 3.11.x, 3.12.x, 3.13.x<br><br>For latest supported versions, check AWS documentation. | `string` | n/a | yes |
| <a name="input_host_instance_type"></a> [host\_instance\_type](#input\_host\_instance\_type) | Instance type of the broker.<br><br>ActiveMQ instance types:<br>- mq.t3.micro: 2 vCPU, 1 GiB RAM (dev/test only, not for production)<br>- mq.m5.large: 2 vCPU, 8 GiB RAM<br>- mq.m5.xlarge: 4 vCPU, 16 GiB RAM<br>- mq.m5.2xlarge: 8 vCPU, 32 GiB RAM<br>- mq.m5.4xlarge: 16 vCPU, 64 GiB RAM<br><br>RabbitMQ instance types:<br>- mq.t3.micro: 2 vCPU, 1 GiB RAM (dev/test only, not for production)<br>- mq.m5.large: 2 vCPU, 8 GiB RAM<br>- mq.m5.xlarge: 4 vCPU, 16 GiB RAM<br>- mq.m5.2xlarge: 8 vCPU, 32 GiB RAM<br>- mq.m5.4xlarge: 16 vCPU, 64 GiB RAM | `string` | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN of AWS KMS key for encryption at rest.<br><br>- If specified: Uses customer-managed KMS key<br>- If null: Uses AWS-owned key (default, no additional cost)<br><br>Customer-managed KMS keys provide:<br>- Control over key policies and rotation<br>- CloudTrail audit logs of key usage<br>- Required for compliance scenarios | `string` | `null` | no |
| <a name="input_ldap_server_metadata"></a> [ldap\_server\_metadata](#input\_ldap\_server\_metadata) | LDAP server configuration for authentication (ActiveMQ only).<br>Only used when authentication\_strategy = "LDAP".<br><br>Required fields:<br>- hosts: List of LDAP server hosts (e.g., ["ldap://example.com:389"])<br>- role\_base: Base DN for role search<br>- role\_search\_matching: LDAP search filter for roles<br>- service\_account\_username: DN of service account<br>- service\_account\_password: Password for service account<br>- user\_base: Base DN for user search<br>- user\_search\_matching: LDAP search filter for users<br><br>Optional fields:<br>- role\_name: Attribute for role name<br>- role\_search\_subtree: Search role subtree (default: false)<br>- user\_role\_name: Attribute for user role name<br>- user\_search\_subtree: Search user subtree (default: false) | <pre>object({<br>    hosts                    = list(string)<br>    role_base                = string<br>    role_search_matching     = string<br>    service_account_password = string<br>    service_account_username = string<br>    user_base                = string<br>    user_search_matching     = string<br>    role_name                = optional(string)<br>    role_search_subtree      = optional(bool)<br>    user_role_name           = optional(string)<br>    user_search_subtree      = optional(bool)<br>  })</pre> | `null` | no |
| <a name="input_maintenance_day_of_week"></a> [maintenance\_day\_of\_week](#input\_maintenance\_day\_of\_week) | Day of the week for maintenance window.<br><br>Valid values: MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY<br><br>If null, AWS chooses a random day/time.<br>Recommended: Set to a low-traffic period. | `string` | `null` | no |
| <a name="input_maintenance_time_of_day"></a> [maintenance\_time\_of\_day](#input\_maintenance\_time\_of\_day) | Time of day for maintenance window in HH:MM format (24-hour clock).<br><br>Example: "03:00" for 3:00 AM<br><br>Only used when maintenance\_day\_of\_week is set. | `string` | `"03:00"` | no |
| <a name="input_maintenance_time_zone"></a> [maintenance\_time\_zone](#input\_maintenance\_time\_zone) | Time zone for the maintenance window.<br><br>Example: "America/New\_York", "UTC", "Europe/London"<br><br>Only used when maintenance\_day\_of\_week is set.<br>For valid time zones, see IANA Time Zone Database. | `string` | `"UTC"` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Enable public accessibility for the broker.<br><br>- true: Broker endpoints are accessible from the internet (requires public subnets)<br>- false: Broker endpoints are only accessible from within the VPC (recommended)<br><br>For production workloads, set to false and access via VPC/VPN/Direct Connect. | `bool` | `false` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | List of security group IDs to assign to the broker.<br><br>The security groups must allow inbound traffic on the appropriate ports:<br>- ActiveMQ: 61617 (OpenWire), 8162 (Web Console), 5671 (AMQP), 61614 (STOMP), 1883 (MQTT)<br>- RabbitMQ: 5671 (AMQP), 15671 (Web Console)<br><br>Security groups must be in the same VPC as the subnets. | `list(string)` | n/a | yes |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Storage type for the broker.<br><br>Valid values:<br>- EBS: Elastic Block Store (default, recommended for most use cases)<br>- EFS: Elastic File System (ActiveMQ only, for shared storage in multi-AZ)<br><br>RabbitMQ only supports EBS. | `string` | `"EBS"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for the broker.<br><br>- SINGLE\_INSTANCE deployment: Provide 1 subnet<br>- ACTIVE\_STANDBY\_MULTI\_AZ deployment: Provide 2 subnets in different AZs<br>- CLUSTER\_MULTI\_AZ deployment: Provide 3 subnets in different AZs (RabbitMQ only)<br><br>Subnets must be in a VPC with DNS resolution and DNS hostnames enabled. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. Use this for consistent resource tagging across your infrastructure. | `map(string)` | `{}` | no |
| <a name="input_users"></a> [users](#input\_users) | List of broker users. Currently, only the first user in the list is used due to AWS provider limitations.<br><br>Each user must have:<br>- username: User login name<br>- password: User password (stored securely, use sensitive variable)<br><br>Optional fields:<br>- console\_access: Enable web console access (ActiveMQ only)<br>- groups: List of groups for the user (ActiveMQ with LDAP only)<br>- replication\_user: Whether this user is for replication (ActiveMQ only)<br><br>Example:<br>[<br>  {<br>    username       = "admin"<br>    password       = "MySecurePassword123!"<br>    console\_access = true<br>  }<br>] | <pre>list(object({<br>    username         = string<br>    password         = string<br>    console_access   = optional(bool)<br>    groups           = optional(list(string))<br>    replication_user = optional(bool)<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_authentication_strategy"></a> [authentication\_strategy](#output\_authentication\_strategy) | Authentication strategy used by the broker (SIMPLE or LDAP). |
| <a name="output_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#output\_auto\_minor\_version\_upgrade) | Whether automatic minor version upgrades are enabled. |
| <a name="output_broker_arn"></a> [broker\_arn](#output\_broker\_arn) | ARN of the AmazonMQ broker. Use this for IAM policies and resource-based policies. |
| <a name="output_broker_id"></a> [broker\_id](#output\_broker\_id) | Unique ID of the AmazonMQ broker. |
| <a name="output_broker_name"></a> [broker\_name](#output\_broker\_name) | Name of the AmazonMQ broker. |
| <a name="output_configuration_arn"></a> [configuration\_arn](#output\_configuration\_arn) | ARN of the created broker configuration. Returns null if create\_configuration is false. |
| <a name="output_configuration_id"></a> [configuration\_id](#output\_configuration\_id) | ID of the broker configuration. Returns the created configuration ID if create\_configuration is true, otherwise returns the provided configuration\_id. |
| <a name="output_configuration_latest_revision"></a> [configuration\_latest\_revision](#output\_configuration\_latest\_revision) | Latest revision number of the created configuration. Returns null if create\_configuration is false. |
| <a name="output_console_url"></a> [console\_url](#output\_console\_url) | URL of the broker's web console. Returns null if console is not enabled. |
| <a name="output_deployment_mode"></a> [deployment\_mode](#output\_deployment\_mode) | Deployment mode of the broker (SINGLE\_INSTANCE, ACTIVE\_STANDBY\_MULTI\_AZ, or CLUSTER\_MULTI\_AZ). |
| <a name="output_encryption_use_aws_owned_key"></a> [encryption\_use\_aws\_owned\_key](#output\_encryption\_use\_aws\_owned\_key) | Whether the broker uses AWS-owned encryption key. |
| <a name="output_endpoints"></a> [endpoints](#output\_endpoints) | List of broker endpoints for client connections. Returns null if not available. |
| <a name="output_engine_type"></a> [engine\_type](#output\_engine\_type) | Type of broker engine (ActiveMQ or RabbitMQ). |
| <a name="output_engine_version"></a> [engine\_version](#output\_engine\_version) | Version of the broker engine. |
| <a name="output_host_instance_type"></a> [host\_instance\_type](#output\_host\_instance\_type) | Instance type of the broker. |
| <a name="output_instances"></a> [instances](#output\_instances) | List of broker instances with endpoint information. |
| <a name="output_ip_address"></a> [ip\_address](#output\_ip\_address) | IP address of the broker instance. Returns null for multi-AZ deployments. |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | ARN of the KMS key used for encryption. Returns null if using AWS-owned key. |
| <a name="output_logs_audit_enabled"></a> [logs\_audit\_enabled](#output\_logs\_audit\_enabled) | Whether audit logging is enabled (ActiveMQ only). |
| <a name="output_logs_general_enabled"></a> [logs\_general\_enabled](#output\_logs\_general\_enabled) | Whether general logging is enabled. |
| <a name="output_maintenance_window_start_time"></a> [maintenance\_window\_start\_time](#output\_maintenance\_window\_start\_time) | Configured maintenance window start time. |
| <a name="output_publicly_accessible"></a> [publicly\_accessible](#output\_publicly\_accessible) | Whether the broker is publicly accessible. |
| <a name="output_security_groups"></a> [security\_groups](#output\_security\_groups) | List of security group IDs attached to the broker. |
| <a name="output_storage_type"></a> [storage\_type](#output\_storage\_type) | Storage type used by the broker (EBS or EFS). |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | List of subnet IDs where the broker is deployed. |
| <a name="output_tags"></a> [tags](#output\_tags) | All tags applied to the broker, including default and custom tags. |
<!-- END_TF_DOCS --></details>
