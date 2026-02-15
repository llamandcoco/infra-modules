# Launch Template

Terraform module for creating AWS EC2 Launch Templates with comprehensive configuration options.

## Features

- AMI selection via direct ID or SSM parameter lookup (AL2023 by default)
- IMDSv2 enforced by default for enhanced security
- Flexible network configuration with support for multiple network interfaces
- Block device mappings with encryption enabled by default
- Spot instance support with configurable interruption behavior
- Tag specifications for automatic resource tagging at launch
- CPU credits configuration for T2/T3/T4g instance families
- Placement controls for availability zones and tenancy

## Quick Start

```hcl
module "launch_template" {
  source = "github.com/llamandcoco/infra-modules//terraform/launch-template?ref=<commit-sha>"

  name          = "my-launch-template"
  instance_type = "t3.micro"
  image_id      = "ami-0c55b159cbfafe1f0"
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic Configuration | [`tests/basic/main.tf`](tests/basic/main.tf) |
| Advanced Features | [`tests/advanced/main.tf`](tests/advanced/main.tf) |

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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_ssm_parameter.al2023](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_ssm_parameter_name"></a> [ami\_ssm\_parameter\_name](#input\_ami\_ssm\_parameter\_name) | SSM parameter name for AL2023 AMI | `string` | `"/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"` | no |
| <a name="input_block_device_mappings"></a> [block\_device\_mappings](#input\_block\_device\_mappings) | Block device mappings for the launch template | <pre>list(object({<br>    device_name  = string<br>    no_device    = optional(string)<br>    virtual_name = optional(string)<br>    ebs = optional(object({<br>      delete_on_termination = optional(bool, true)<br>      encrypted             = optional(bool, true)<br>      iops                  = optional(number)<br>      kms_key_id            = optional(string)<br>      snapshot_id           = optional(string)<br>      throughput            = optional(number)<br>      volume_size           = optional(number)<br>      volume_type           = optional(string, "gp3")<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_cpu_credits"></a> [cpu\_credits](#input\_cpu\_credits) | Credit option for CPU usage (standard or unlimited). Only for T2/T3/T4g instances. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the launch template | `string` | `null` | no |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | Enable EC2 instance termination protection | `bool` | `false` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | Enable EBS optimization | `bool` | `null` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Enable detailed monitoring | `bool` | `false` | no |
| <a name="input_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#input\_iam\_instance\_profile\_name) | IAM instance profile name for EC2 instances | `string` | `null` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | AMI ID for instances (if provided, overrides SSM lookup) | `string` | `null` | no |
| <a name="input_instance_market_options"></a> [instance\_market\_options](#input\_instance\_market\_options) | Market (purchasing) option for the instances | <pre>object({<br>    market_type = string<br>    spot_options = optional(object({<br>      block_duration_minutes         = optional(number)<br>      instance_interruption_behavior = optional(string, "terminate")<br>      max_price                      = optional(string)<br>      spot_instance_type             = optional(string, "one-time")<br>      valid_until                    = optional(string)<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type | `string` | `null` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | SSH key name to use for instances | `string` | `null` | no |
| <a name="input_metadata_options"></a> [metadata\_options](#input\_metadata\_options) | Instance metadata service configuration | <pre>object({<br>    http_endpoint               = optional(string, "enabled")<br>    http_tokens                 = optional(string, "required")<br>    http_put_response_hop_limit = optional(number, 1)<br>    instance_metadata_tags      = optional(string, "disabled")<br>  })</pre> | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the launch template | `string` | n/a | yes |
| <a name="input_network_interfaces"></a> [network\_interfaces](#input\_network\_interfaces) | Network interface configuration for the launch template | <pre>list(object({<br>    associate_public_ip_address = optional(bool)<br>    delete_on_termination       = optional(bool, true)<br>    device_index                = number<br>    security_groups             = optional(list(string), [])<br>    subnet_id                   = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_placement"></a> [placement](#input\_placement) | Placement configuration for instances | <pre>object({<br>    availability_zone = optional(string)<br>    group_name        = optional(string)<br>    tenancy           = optional(string, "default")<br>  })</pre> | `null` | no |
| <a name="input_tag_specifications"></a> [tag\_specifications](#input\_tag\_specifications) | Resource types to tag at launch | <pre>list(object({<br>    resource_type = string<br>    tags          = map(string)<br>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the launch template resource | `map(string)` | `{}` | no |
| <a name="input_use_ssm_ami_lookup"></a> [use\_ssm\_ami\_lookup](#input\_use\_ssm\_ami\_lookup) | When true, use SSM parameter to lookup AL2023 AMI | `bool` | `true` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Plain user data script (will be base64-encoded) | `string` | `null` | no |
| <a name="input_user_data_base64"></a> [user\_data\_base64](#input\_user\_data\_base64) | Base64-encoded user data script | `string` | `null` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | List of security group IDs for instances | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the launch template |
| <a name="output_default_version"></a> [default\_version](#output\_default\_version) | The default version of the launch template |
| <a name="output_id"></a> [id](#output\_id) | The ID of the launch template |
| <a name="output_latest_version"></a> [latest\_version](#output\_latest\_version) | The latest version of the launch template |
| <a name="output_name"></a> [name](#output\_name) | The name of the launch template |
<!-- END_TF_DOCS -->
</details>
