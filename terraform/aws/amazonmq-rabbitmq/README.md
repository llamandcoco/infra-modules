# Amazon MQ RabbitMQ Configuration Module

A production-ready Terraform module for creating and managing Amazon MQ RabbitMQ broker configurations with customizable settings for memory, disk, logging, and advanced broker parameters.

## Features

- **RabbitMQ Configuration:** Support for RabbitMQ versions supported by Amazon MQ in your region
- **Memory Management:** Configurable memory high watermark and disk free limits
- **Queue Settings:** Custom queue policies, message TTL, and delivery modes
- **Connection Limits:** Control heartbeat intervals, channel max, and connection settings
- **Logging Configuration:** Flexible logging levels for file and console outputs
- **Tagging Support:** Consistent resource tagging for organization and compliance
- **Validation:** Built-in validation for configuration name format and Base64 Cuttlefish payloads
- **Version Flexibility:** Support for multiple RabbitMQ engine versions

## Quick Start

```hcl
module "rabbitmq_config" {
  source = "github.com/llamandcoco/infra-modules//terraform/amazonmq-rabbitmq?ref=<commit-sha>"

  configuration_name = "my-rabbitmq-config"
  engine_version     = "3.13"
  
  configuration_data = base64encode(<<-EOT
    vm_memory_high_watermark.relative = 0.4
    disk_free_limit.relative = 1.0
  EOT
  )
}
```

Attach this configuration to a broker module:

```hcl
module "broker" {
  source = "github.com/llamandcoco/infra-modules//terraform/amazonmq?ref=<commit-sha>"

  # ... broker inputs ...
  configuration_id       = module.rabbitmq_config.configuration_id
  configuration_revision = module.rabbitmq_config.configuration_revision
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic Configuration | [`tests/basic/main.tf`](tests/basic/main.tf) |

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
| [aws_mq_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/mq_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_configuration_data"></a> [configuration\_data](#input\_configuration\_data) | The RabbitMQ configuration data in Base64-encoded format.<br/><br/>This should be a Base64-encoded RabbitMQ Cuttlefish configuration (rabbitmq.conf format).<br/>The configuration allows you to customize RabbitMQ broker settings such as:<br/>- Memory limits and thresholds<br/>- Disk space limits<br/>- Queue and message policies<br/>- Connection limits<br/>- Authentication mechanisms<br/>- Logging levels<br/><br/>Example (before Base64 encoding):<br/>vm\_memory\_high\_watermark.relative = 0.4<br/>disk\_free\_limit.relative = 1.0<br/><br/>Use the base64encode() function to encode your configuration:<br/>configuration\_data = base64encode(file("path/to/rabbitmq.conf"))<br/><br/>For configuration reference, see:<br/>https://www.rabbitmq.com/configure.html | `string` | n/a | yes |
| <a name="input_configuration_name"></a> [configuration\_name](#input\_configuration\_name) | Name of the Amazon MQ RabbitMQ configuration.<br/>Must be unique within the AWS account and region. | `string` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | The version of the RabbitMQ broker engine.<br/><br/>Use major.minor format (for example: 3.13).<br/><br/>Refer to AWS documentation for the latest supported versions:<br/>https://docs.aws.amazon.com/amazon-mq/latest/developer-guide/rabbitmq-version-management.html | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of the RabbitMQ configuration.<br/>Helps identify the purpose and scope of the configuration. | `string` | `"RabbitMQ configuration managed by Terraform"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. Use this to add consistent tagging across your infrastructure. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_configuration_arn"></a> [configuration\_arn](#output\_configuration\_arn) | The ARN of the Amazon MQ configuration. Use this for IAM policies and resource tagging. |
| <a name="output_configuration_id"></a> [configuration\_id](#output\_configuration\_id) | The unique ID of the Amazon MQ configuration. Use this to reference the configuration in broker resources. |
| <a name="output_configuration_name"></a> [configuration\_name](#output\_configuration\_name) | The name of the Amazon MQ configuration. |
| <a name="output_configuration_revision"></a> [configuration\_revision](#output\_configuration\_revision) | Revision number to pass to broker modules when attaching this configuration. |
| <a name="output_description"></a> [description](#output\_description) | The description of the Amazon MQ configuration. |
| <a name="output_engine_type"></a> [engine\_type](#output\_engine\_type) | The type of broker engine (always 'RABBITMQ' for this module). |
| <a name="output_engine_version"></a> [engine\_version](#output\_engine\_version) | The version of the RabbitMQ broker engine. |
| <a name="output_latest_revision"></a> [latest\_revision](#output\_latest\_revision) | The latest revision number of the configuration. |
| <a name="output_tags"></a> [tags](#output\_tags) | All tags applied to the configuration, including default and custom tags. |
<!-- END_TF_DOCS -->
</details>
