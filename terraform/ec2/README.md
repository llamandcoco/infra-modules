# EC2 Terraform Module

### Run EBS Test
```bash
cd tests/with_ebs
terraform init
terraform plan
```

## Features

- Flexible Instance Configuration Support for on-demand and spot instances
- Storage Options Configurable root volumes and additional EBS volumes with encryption
- Network Configuration VPC integration, security groups, Elastic IPs, and public/private networking
- IAM Integration Automatic IAM role and instance profile creation with policy attachment
- Security Best Practices IMDSv2 by default, EBS encryption, and security group management
- User Data Support Bootstrap instances with shell scripts or cloud-init
- Spot Instance Support Cost-effective compute for fault-tolerant workloads
- Comprehensive Outputs All resource IDs, ARNs, and configuration details

## Quick Start

```hcl
module "ec2" {
  source = "github.com/llamandcoco/infra-modules//terraform/ec2?ref=v1.0.0"

  # Add required variables here
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|--------|
| Basic | [`tests/basic/`](tests/basic/) |
| Spot Instance | [`tests/spot_instance/`](tests/spot_instance/) |
| User Data | [`tests/user_data/`](tests/user_data/) |
| With Ebs | [`tests/with_ebs/`](tests/with_ebs/) |
| With Eip | [`tests/with_eip/`](tests/with_eip/) |

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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.27.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ebs_volume.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_spot_instance_request.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/spot_instance_request) | resource |
| [aws_volume_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_instance.spot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instance) | data source |
| [aws_subnet.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | The AMI ID to use for the EC2 instance. Must start with 'ami-'. | `string` | n/a | yes |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Whether to associate a public IP address with the instance in a VPC. | `bool` | `false` | no |
| <a name="input_cpu_credits"></a> [cpu\_credits](#input\_cpu\_credits) | Credit option for CPU usage. Valid values: 'standard' or 'unlimited'.<br/>Only applicable for T2/T3/T4g instance types. | `string` | `"unlimited"` | no |
| <a name="input_create_eip"></a> [create\_eip](#input\_create\_eip) | Whether to create and associate an Elastic IP with the instance. | `bool` | `false` | no |
| <a name="input_create_iam_instance_profile"></a> [create\_iam\_instance\_profile](#input\_create\_iam\_instance\_profile) | Whether to create a new IAM instance profile and role for the instance. | `bool` | `false` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Whether to create a new security group for the instance. | `bool` | `false` | no |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | Enable EC2 instance termination protection. | `bool` | `false` | no |
| <a name="input_ebs_volumes"></a> [ebs\_volumes](#input\_ebs\_volumes) | List of additional EBS volumes to create and attach to the instance.<br/>Each volume requires device\_name, size, and type. Supports encryption and IOPS/throughput settings. | <pre>list(object({<br/>    device_name           = string<br/>    volume_size           = number<br/>    volume_type           = optional(string, "gp3")<br/>    iops                  = optional(number)<br/>    throughput            = optional(number)<br/>    encrypted             = optional(bool, true)<br/>    kms_key_id            = optional(string)<br/>    availability_zone     = optional(string)<br/>    delete_on_termination = optional(bool, true)<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_spot_instance"></a> [enable\_spot\_instance](#input\_enable\_spot\_instance) | Whether to launch the instance as a spot instance. | `bool` | `false` | no |
| <a name="input_fallback_availability_zone"></a> [fallback\_availability\_zone](#input\_fallback\_availability\_zone) | Availability zone to use when subnet data lookup is disabled. Required if EBS volumes need an AZ and lookup is false. | `string` | `null` | no |
| <a name="input_hibernation"></a> [hibernation](#input\_hibernation) | Enable hibernation for the instance. Requires encrypted root volume. | `bool` | `false` | no |
| <a name="input_iam_inline_policies"></a> [iam\_inline\_policies](#input\_iam\_inline\_policies) | List of inline IAM policies to attach to the role. Only used when create\_iam\_instance\_profile is true.<br/>Each policy requires a name and a JSON policy document. | <pre>list(object({<br/>    name   = string<br/>    policy = string<br/>  }))</pre> | `[]` | no |
| <a name="input_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#input\_iam\_instance\_profile\_name) | Name of an existing IAM instance profile to attach to the instance. Cannot be used with create\_iam\_instance\_profile. | `string` | `null` | no |
| <a name="input_iam_policy_arns"></a> [iam\_policy\_arns](#input\_iam\_policy\_arns) | List of IAM policy ARNs to attach to the IAM role. Only used when create\_iam\_instance\_profile is true. | `list(string)` | `[]` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Custom name for the IAM role when create\_iam\_instance\_profile is true. If not specified, will be auto-generated. | `string` | `null` | no |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance\_initiated\_shutdown\_behavior](#input\_instance\_initiated\_shutdown\_behavior) | Shutdown behavior for the instance when initiated from the OS. Valid values: 'stop' or 'terminate'. | `string` | `"stop"` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Name of the EC2 instance. Used for the Name tag and resource naming. | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The instance type to use for the EC2 instance.<br/>Common types: t3.micro, t3.small, t3.medium, c6i.large, r6i.large | `string` | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | The name of the SSH key pair to use for the instance. Key pair must already exist in AWS. | `string` | `null` | no |
| <a name="input_lookup_subnet_data"></a> [lookup\_subnet\_data](#input\_lookup\_subnet\_data) | Whether to lookup subnet details (availability zone) via data source. Disable for tests without AWS access. | `bool` | `true` | no |
| <a name="input_metadata_options"></a> [metadata\_options](#input\_metadata\_options) | Instance metadata service configuration. Controls access to instance metadata.<br/>Recommended to require IMDSv2 for enhanced security. | <pre>object({<br/>    http_endpoint               = optional(string, "enabled")<br/>    http_tokens                 = optional(string, "required")<br/>    http_put_response_hop_limit = optional(number, 1)<br/>    instance_metadata_tags      = optional(string, "disabled")<br/>  })</pre> | `{}` | no |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | Enable detailed monitoring (additional charges apply). | `bool` | `false` | no |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | Private IP address to associate with the instance in a VPC. If not specified, an IP will be automatically assigned. | `string` | `null` | no |
| <a name="input_root_block_device"></a> [root\_block\_device](#input\_root\_block\_device) | Configuration for the root block device.<br/>Supports volume size, type, IOPS, throughput, encryption, and deletion settings. | <pre>object({<br/>    volume_size           = optional(number, 8)<br/>    volume_type           = optional(string, "gp3")<br/>    iops                  = optional(number)<br/>    throughput            = optional(number)<br/>    encrypted             = optional(bool, true)<br/>    kms_key_id            = optional(string)<br/>    delete_on_termination = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | Description of the security group to create. | `string` | `"Security group managed by Terraform"` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name of the security group to create. Required if create\_security\_group is true. | `string` | `null` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | List of security group rules to create. Only used if create\_security\_group is true.<br/>Each rule should specify type (ingress/egress), ports, protocol, CIDR blocks, and description. | <pre>list(object({<br/>    type        = string<br/>    from_port   = number<br/>    to_port     = number<br/>    protocol    = string<br/>    cidr_blocks = list(string)<br/>    description = string<br/>  }))</pre> | `[]` | no |
| <a name="input_source_dest_check"></a> [source\_dest\_check](#input\_source\_dest\_check) | Enable source/destination checking. Should be disabled for NAT instances or routers. | `bool` | `true` | no |
| <a name="input_spot_instance_interruption_behavior"></a> [spot\_instance\_interruption\_behavior](#input\_spot\_instance\_interruption\_behavior) | Behavior when a spot instance is interrupted. Valid values: 'terminate', 'stop', or 'hibernate'. | `string` | `"terminate"` | no |
| <a name="input_spot_instance_type"></a> [spot\_instance\_type](#input\_spot\_instance\_type) | Type of spot request. Valid values: 'one-time' or 'persistent'. | `string` | `"one-time"` | no |
| <a name="input_spot_price"></a> [spot\_price](#input\_spot\_price) | Maximum price to pay for spot instance (per hour). If not specified, uses on-demand price as max. | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The VPC subnet ID to launch the instance in. Must start with 'subnet-'. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_tenancy"></a> [tenancy](#input\_tenancy) | Tenancy of the instance. Valid values: 'default', 'dedicated', or 'host'.<br/>- default: Shared hardware (most cost-effective)<br/>- dedicated: Runs on single-tenant hardware<br/>- host: Runs on a Dedicated Host | `string` | `"default"` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | User data script to run at instance launch. Will be automatically base64 encoded.<br/>Cannot be used with user\_data\_base64. | `string` | `null` | no |
| <a name="input_user_data_base64"></a> [user\_data\_base64](#input\_user\_data\_base64) | Base64-encoded user data script. Use this if you need to provide pre-encoded data.<br/>Cannot be used with user\_data. | `string` | `null` | no |
| <a name="input_user_data_replace_on_change"></a> [user\_data\_replace\_on\_change](#input\_user\_data\_replace\_on\_change) | When true, changes to user\_data will trigger instance replacement instead of stop/start. | `bool` | `false` | no |
| <a name="input_volume_tags"></a> [volume\_tags](#input\_volume\_tags) | A map of tags to add to all EBS volumes (root and additional volumes). | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the security group will be created. Required if create\_security\_group is true. | `string` | `null` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | List of security group IDs to attach to the instance.<br/>Can be empty if create\_security\_group is true. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_zone"></a> [availability\_zone](#output\_availability\_zone) | The availability zone where the instance is running. |
| <a name="output_ebs_volume_arns"></a> [ebs\_volume\_arns](#output\_ebs\_volume\_arns) | Map of device names to EBS volume ARNs for additional volumes. |
| <a name="output_ebs_volume_ids"></a> [ebs\_volume\_ids](#output\_ebs\_volume\_ids) | Map of device names to EBS volume IDs for additional volumes. |
| <a name="output_eip_allocation_id"></a> [eip\_allocation\_id](#output\_eip\_allocation\_id) | The allocation ID of the Elastic IP. |
| <a name="output_eip_association_id"></a> [eip\_association\_id](#output\_eip\_association\_id) | The ID of the EIP association. |
| <a name="output_eip_id"></a> [eip\_id](#output\_eip\_id) | The ID of the Elastic IP created by this module, if any. |
| <a name="output_eip_public_ip"></a> [eip\_public\_ip](#output\_eip\_public\_ip) | The Elastic IP address. |
| <a name="output_iam_instance_profile_arn"></a> [iam\_instance\_profile\_arn](#output\_iam\_instance\_profile\_arn) | The ARN of the IAM instance profile created by this module, if any. |
| <a name="output_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#output\_iam\_instance\_profile\_name) | The name of the IAM instance profile created by this module, if any. |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | The ARN of the IAM role created by this module, if any. |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | The name of the IAM role created by this module, if any. |
| <a name="output_instance_arn"></a> [instance\_arn](#output\_instance\_arn) | The ARN of the EC2 instance. |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | The ID of the EC2 instance (or spot instance ID if using spot). |
| <a name="output_instance_state"></a> [instance\_state](#output\_instance\_state) | The state of the instance (running, stopped, etc.). |
| <a name="output_primary_network_interface_id"></a> [primary\_network\_interface\_id](#output\_primary\_network\_interface\_id) | The ID of the primary network interface. |
| <a name="output_private_dns"></a> [private\_dns](#output\_private\_dns) | The private DNS name assigned to the instance. |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | The private IP address assigned to the instance. |
| <a name="output_public_dns"></a> [public\_dns](#output\_public\_dns) | The public DNS name assigned to the instance. |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | The public IP address assigned to the instance, if applicable. |
| <a name="output_root_block_device_volume_id"></a> [root\_block\_device\_volume\_id](#output\_root\_block\_device\_volume\_id) | The volume ID of the root block device. |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | The ARN of the security group created by this module, if any. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group created by this module, if any. |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name) | The name of the security group created by this module, if any. |
| <a name="output_spot_bid_status"></a> [spot\_bid\_status](#output\_spot\_bid\_status) | The bid status of the spot instance request. |
| <a name="output_spot_request_id"></a> [spot\_request\_id](#output\_spot\_request\_id) | The ID of the spot instance request, if using spot instances. |
| <a name="output_spot_request_state"></a> [spot\_request\_state](#output\_spot\_request\_state) | The state of the spot instance request (active, cancelled, etc.). |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of all tags applied to the instance. |
<!-- END_TF_DOCS -->

## Security Best Practices

### IMDSv2 (Instance Metadata Service v2)

Always require IMDSv2 for enhanced security:

```hcl
metadata_options = {
  http_endpoint = "enabled"
  http_tokens   = "required"  # Requires IMDSv2
}
```

### EBS Encryption

Enable encryption for all volumes:

```hcl
root_block_device = {
  encrypted = true
  # Optional: Use customer-managed key
  # kms_key_id = "arn:aws:kms:region:account:key/key-id"
}

ebs_volumes = [
  {
    device_name = "/dev/sdf"
    volume_size = 100
    encrypted   = true
  }
]
```

### Termination Protection

Enable for production instances:

```hcl
disable_api_termination = true
```

## Testing

The module includes comprehensive test scenarios:

### Run Basic Test
```bash
cd tests/basic
terraform init
terraform plan
```

### Run EBS Test
```bash
cd tests/with_ebs
terraform init
terraform plan
```

### Run All Tests
```bash
for test in tests/*/; do
  echo "Testing $test"
  cd "$test"
  terraform init && terraform plan
  cd ../..
done
```

