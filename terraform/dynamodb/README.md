# DynamoDB Table Module

The module includes test configurations in `tests/basic/` that can be run without AWS credentials:

## Features

- Flexible Billing Support for both PAY_PER_REQUEST (on-demand) and PROVISIONED billing modes
- Auto Scaling Automatic capacity scaling for PROVISIONED mode (table and GSI)
- Security Server-side encryption with AWS owned or customer-managed KMS keys
- Data Protection Point-in-time recovery (PITR) enabled by default
- Streams Optional DynamoDB Streams for change data capture
- TTL Optional Time To Live for automatic item expiration
- Indexes Support for Global Secondary Indexes (GSI) and Local Secondary Indexes (LSI)
- Table Classes Support for STANDARD and STANDARD_INFREQUENT_ACCESS storage classes

## Quick Start

```hcl
module "dynamodb" {
  source = "github.com/llamandcoco/infra-modules//terraform/dynamodb?ref=<commit-sha>"

  # Add required variables here
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|----------|
| Advanced | [`tests/advanced/`](tests/advanced/) |
| Basic | [`tests/basic/`](tests/basic/) |

**Usage:**
```bash
# View example
cat tests/advanced/main.tf

# Copy and adapt
cp -r tests/advanced/ my-project/
```

## Testing

```bash
cd tests/advanced && terraform init && terraform plan
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
| [aws_appautoscaling_policy.gsi_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.gsi_write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.gsi_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_appautoscaling_target.gsi_write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_appautoscaling_target.read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_appautoscaling_target.write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_dynamodb_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes used for Global Secondary Indexes (GSI) or Local Secondary Indexes (LSI).<br/>Each attribute must have a name and type (S, N, or B).<br/>Note: Hash key and range key are automatically included and should not be listed here. | <pre>list(object({<br/>    name = string<br/>    type = string<br/>  }))</pre> | `[]` | no |
| <a name="input_autoscaling_read_max_capacity"></a> [autoscaling\_read\_max\_capacity](#input\_autoscaling\_read\_max\_capacity) | Maximum read capacity for auto-scaling. Only used when billing\_mode is PROVISIONED and enable\_autoscaling is true. | `number` | `100` | no |
| <a name="input_autoscaling_read_min_capacity"></a> [autoscaling\_read\_min\_capacity](#input\_autoscaling\_read\_min\_capacity) | Minimum read capacity for auto-scaling. Only used when billing\_mode is PROVISIONED and enable\_autoscaling is true. | `number` | `5` | no |
| <a name="input_autoscaling_read_target_value"></a> [autoscaling\_read\_target\_value](#input\_autoscaling\_read\_target\_value) | Target utilization percentage for read capacity auto-scaling (1-100). Only used when billing\_mode is PROVISIONED and enable\_autoscaling is true. | `number` | `70` | no |
| <a name="input_autoscaling_write_max_capacity"></a> [autoscaling\_write\_max\_capacity](#input\_autoscaling\_write\_max\_capacity) | Maximum write capacity for auto-scaling. Only used when billing\_mode is PROVISIONED and enable\_autoscaling is true. | `number` | `100` | no |
| <a name="input_autoscaling_write_min_capacity"></a> [autoscaling\_write\_min\_capacity](#input\_autoscaling\_write\_min\_capacity) | Minimum write capacity for auto-scaling. Only used when billing\_mode is PROVISIONED and enable\_autoscaling is true. | `number` | `5` | no |
| <a name="input_autoscaling_write_target_value"></a> [autoscaling\_write\_target\_value](#input\_autoscaling\_write\_target\_value) | Target utilization percentage for write capacity auto-scaling (1-100). Only used when billing\_mode is PROVISIONED and enable\_autoscaling is true. | `number` | `70` | no |
| <a name="input_billing_mode"></a> [billing\_mode](#input\_billing\_mode) | Billing mode for the table. Valid values: PROVISIONED or PAY\_PER\_REQUEST.<br/>- PROVISIONED: You specify read/write capacity units (supports auto-scaling)<br/>- PAY\_PER\_REQUEST: Pay only for what you use (on-demand pricing, no capacity planning needed) | `string` | `"PAY_PER_REQUEST"` | no |
| <a name="input_enable_autoscaling"></a> [enable\_autoscaling](#input\_enable\_autoscaling) | Enable auto-scaling for read and write capacity. Only applicable when billing\_mode is PROVISIONED. | `bool` | `true` | no |
| <a name="input_global_secondary_indexes"></a> [global\_secondary\_indexes](#input\_global\_secondary\_indexes) | List of Global Secondary Indexes (GSI) for the table.<br/>Each GSI allows querying the table using different key attributes.<br/>GSI can have different partition key (hash\_key) and optional sort key (range\_key) from the base table.<br/><br/>Required fields:<br/>- name: Name of the GSI<br/>- hash\_key: Partition key for the GSI (must be defined in attributes)<br/>- projection\_type: Attributes to project (KEYS\_ONLY, INCLUDE, or ALL)<br/><br/>Optional fields:<br/>- range\_key: Sort key for the GSI (must be defined in attributes if specified)<br/>- non\_key\_attributes: List of attributes to include when projection\_type is INCLUDE<br/>- read\_capacity: Read capacity for GSI (PROVISIONED mode only)<br/>- write\_capacity: Write capacity for GSI (PROVISIONED mode only)<br/>- enable\_autoscaling: Enable autoscaling for this GSI (default: true, PROVISIONED mode only)<br/>- autoscaling\_read\_min\_capacity: Min read capacity for autoscaling<br/>- autoscaling\_read\_max\_capacity: Max read capacity for autoscaling<br/>- autoscaling\_write\_min\_capacity: Min write capacity for autoscaling<br/>- autoscaling\_write\_max\_capacity: Max write capacity for autoscaling | <pre>list(object({<br/>    name                           = string<br/>    hash_key                       = string<br/>    range_key                      = optional(string)<br/>    projection_type                = string<br/>    non_key_attributes             = optional(list(string))<br/>    read_capacity                  = optional(number)<br/>    write_capacity                 = optional(number)<br/>    enable_autoscaling             = optional(bool, true)<br/>    autoscaling_read_min_capacity  = optional(number)<br/>    autoscaling_read_max_capacity  = optional(number)<br/>    autoscaling_write_min_capacity = optional(number)<br/>    autoscaling_write_max_capacity = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_hash_key"></a> [hash\_key](#input\_hash\_key) | The attribute to use as the hash (partition) key. Must be defined in attributes. | `string` | n/a | yes |
| <a name="input_hash_key_type"></a> [hash\_key\_type](#input\_hash\_key\_type) | Hash key attribute type. Valid values: S (string), N (number), B (binary). | `string` | `"S"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of the KMS key to use for server-side encryption.<br/>- If specified: Uses customer-managed KMS key (SSE-KMS)<br/>- If null: Uses AWS owned key (default encryption)<br/>Note: Using customer-managed KMS keys incurs additional costs. | `string` | `null` | no |
| <a name="input_local_secondary_indexes"></a> [local\_secondary\_indexes](#input\_local\_secondary\_indexes) | List of Local Secondary Indexes (LSI) for the table.<br/>LSI must have the same partition key as the base table but different sort key.<br/>LSI can only be created at table creation time and cannot be modified later.<br/><br/>Required fields:<br/>- name: Name of the LSI<br/>- range\_key: Sort key for the LSI (must be defined in attributes, different from table's range\_key)<br/>- projection\_type: Attributes to project (KEYS\_ONLY, INCLUDE, or ALL)<br/><br/>Optional fields:<br/>- non\_key\_attributes: List of attributes to include when projection\_type is INCLUDE | <pre>list(object({<br/>    name               = string<br/>    range_key          = string<br/>    projection_type    = string<br/>    non_key_attributes = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_point_in_time_recovery_enabled"></a> [point\_in\_time\_recovery\_enabled](#input\_point\_in\_time\_recovery\_enabled) | Enable point-in-time recovery (PITR) for the table. Recommended for production tables.<br/>PITR provides continuous backups for the last 35 days and allows restore to any point in that timeframe. | `bool` | `true` | no |
| <a name="input_range_key"></a> [range\_key](#input\_range\_key) | The attribute to use as the range (sort) key. Must be defined in attributes if specified. | `string` | `null` | no |
| <a name="input_range_key_type"></a> [range\_key\_type](#input\_range\_key\_type) | Range key attribute type. Valid values: S (string), N (number), B (binary). | `string` | `"S"` | no |
| <a name="input_read_capacity"></a> [read\_capacity](#input\_read\_capacity) | The number of read units for the table. Only used when billing\_mode is PROVISIONED. | `number` | `5` | no |
| <a name="input_stream_enabled"></a> [stream\_enabled](#input\_stream\_enabled) | Enable DynamoDB Streams for the table. Streams capture item-level changes.<br/>Useful for triggering Lambda functions, cross-region replication, or maintaining aggregates. | `bool` | `false` | no |
| <a name="input_stream_view_type"></a> [stream\_view\_type](#input\_stream\_view\_type) | Type of data written to the stream. Only used when stream\_enabled is true.<br/>Valid values:<br/>- KEYS\_ONLY: Only the key attributes of modified items<br/>- NEW\_IMAGE: Entire item after modification<br/>- OLD\_IMAGE: Entire item before modification<br/>- NEW\_AND\_OLD\_IMAGES: Both new and old images of the item | `string` | `"NEW_AND_OLD_IMAGES"` | no |
| <a name="input_table_class"></a> [table\_class](#input\_table\_class) | Storage class of the table. Valid values: STANDARD or STANDARD\_INFREQUENT\_ACCESS.<br/>- STANDARD: Default storage class for frequently accessed data<br/>- STANDARD\_INFREQUENT\_ACCESS: Lower storage cost for infrequently accessed data | `string` | `"STANDARD"` | no |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | Name of the DynamoDB table. Must be unique within the AWS account and region. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. Use this to add consistent tagging across your infrastructure. | `map(string)` | `{}` | no |
| <a name="input_ttl_attribute_name"></a> [ttl\_attribute\_name](#input\_ttl\_attribute\_name) | Name of the table attribute to use for TTL. Items with a timestamp in this attribute will be automatically deleted after expiration.<br/>The attribute must contain a Unix timestamp (in seconds). Set to null to disable TTL. | `string` | `null` | no |
| <a name="input_ttl_enabled"></a> [ttl\_enabled](#input\_ttl\_enabled) | Enable Time To Live (TTL) for automatic item expiration. Only used when ttl\_attribute\_name is specified. | `bool` | `true` | no |
| <a name="input_write_capacity"></a> [write\_capacity](#input\_write\_capacity) | The number of write units for the table. Only used when billing\_mode is PROVISIONED. | `number` | `5` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscaling_enabled"></a> [autoscaling\_enabled](#output\_autoscaling\_enabled) | Whether auto-scaling is enabled for the table (only applicable for PROVISIONED billing mode). |
| <a name="output_global_secondary_indexes"></a> [global\_secondary\_indexes](#output\_global\_secondary\_indexes) | List of Global Secondary Indexes configured on the table with their names and key attributes. |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | The ARN of the KMS key used for encryption. Null if using AWS owned key. |
| <a name="output_local_secondary_indexes"></a> [local\_secondary\_indexes](#output\_local\_secondary\_indexes) | List of Local Secondary Indexes configured on the table with their names and key attributes. |
| <a name="output_point_in_time_recovery_enabled"></a> [point\_in\_time\_recovery\_enabled](#output\_point\_in\_time\_recovery\_enabled) | Whether point-in-time recovery is enabled. Important for compliance and data protection verification. |
| <a name="output_read_capacity"></a> [read\_capacity](#output\_read\_capacity) | The provisioned read capacity units for the table (only applicable for PROVISIONED billing mode). |
| <a name="output_stream_arn"></a> [stream\_arn](#output\_stream\_arn) | The ARN of the DynamoDB stream. Use this to configure Lambda event source mappings or other stream consumers. |
| <a name="output_stream_enabled"></a> [stream\_enabled](#output\_stream\_enabled) | Whether DynamoDB Streams is enabled for the table. |
| <a name="output_stream_label"></a> [stream\_label](#output\_stream\_label) | The timestamp of the stream. Changes whenever the stream is enabled/disabled or the stream view type changes. |
| <a name="output_stream_view_type"></a> [stream\_view\_type](#output\_stream\_view\_type) | The type of data written to the stream (KEYS\_ONLY, NEW\_IMAGE, OLD\_IMAGE, or NEW\_AND\_OLD\_IMAGES). |
| <a name="output_table_arn"></a> [table\_arn](#output\_table\_arn) | The ARN of the DynamoDB table. Use this for IAM policies and cross-account access configurations. |
| <a name="output_table_billing_mode"></a> [table\_billing\_mode](#output\_table\_billing\_mode) | The billing mode of the table (PROVISIONED or PAY\_PER\_REQUEST). |
| <a name="output_table_class"></a> [table\_class](#output\_table\_class) | The storage class of the table (STANDARD or STANDARD\_INFREQUENT\_ACCESS). |
| <a name="output_table_hash_key"></a> [table\_hash\_key](#output\_table\_hash\_key) | The hash (partition) key attribute name of the table. |
| <a name="output_table_id"></a> [table\_id](#output\_table\_id) | The ID of the DynamoDB table (same as table\_name). Provided for consistency with other AWS resources. |
| <a name="output_table_name"></a> [table\_name](#output\_table\_name) | The name of the DynamoDB table. Use this for table references in application code and other resources. |
| <a name="output_table_range_key"></a> [table\_range\_key](#output\_table\_range\_key) | The range (sort) key attribute name of the table, if configured. |
| <a name="output_tags"></a> [tags](#output\_tags) | All tags applied to the table, including default and custom tags. |
| <a name="output_ttl_attribute_name"></a> [ttl\_attribute\_name](#output\_ttl\_attribute\_name) | The attribute name used for TTL, if configured. |
| <a name="output_ttl_enabled"></a> [ttl\_enabled](#output\_ttl\_enabled) | Whether Time To Live (TTL) is enabled on the table. |
| <a name="output_write_capacity"></a> [write\_capacity](#output\_write\_capacity) | The provisioned write capacity units for the table (only applicable for PROVISIONED billing mode). |
<!-- END_TF_DOCS -->
