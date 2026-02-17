# AWS AMI Terraform Module

A Terraform module for finding Amazon Machine Images (AMIs) using filters or a specific AMI ID.

## Features

- **AMI Lookup** Find AMIs using flexible filters (name, architecture, owner, etc.)
- **Most Recent Selection** Automatically select the latest AMI matching your criteria
- **Specific AMI Support** Use a specific AMI ID when you already know it
- **Flexible Filters** Filter by name, architecture, virtualization type, and more
- **Owner-based Search** Search AMIs by owner (amazon, self, account ID, etc.)
- **Comprehensive Outputs** Access all AMI metadata (ID, ARN, architecture, etc.)

## Quick Start

```hcl
module "ami" {
  source = "github.com/llamandcoco/infra-modules//terraform/ami?ref=<commit-sha>"

  # Find latest Amazon Linux 2 AMI
  owners = ["amazon"]

  filters = [
    {
      name   = "name"
      values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
  ]
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic AMI Lookup | [`tests/basic/main.tf`](tests/basic/main.tf) |

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
| [aws_ami.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | Specific AMI ID to use. If provided, AMI lookup will be skipped. Use this when you already know the exact AMI ID. | `string` | `null` | no |
| <a name="input_filter_tags"></a> [filter\_tags](#input\_filter\_tags) | Map of tags to filter AMIs. Only AMIs with all specified tags will be returned. | `map(string)` | `{}` | no |
| <a name="input_filters"></a> [filters](#input\_filters) | List of filters to narrow down AMI search results.<br/>Common filters:<br/>- name: AMI name pattern (e.g., 'amzn2-ami-hvm-*-x86\_64-gp2')<br/>- architecture: Architecture type (e.g., 'x86\_64', 'arm64')<br/>- virtualization-type: Virtualization type (e.g., 'hvm', 'paravirtual')<br/>- root-device-type: Root device type (e.g., 'ebs', 'instance-store')<br/>- state: AMI state (usually 'available') | <pre>list(object({<br/>    name   = string<br/>    values = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_most_recent"></a> [most\_recent](#input\_most\_recent) | Return the most recent AMI matching the filters. Recommended for automated deployments to get latest versions. | `bool` | `true` | no |
| <a name="input_owners"></a> [owners](#input\_owners) | List of AMI owner IDs or aliases (e.g., ['amazon', '099720109477'] or ['self', 'aws-marketplace']). Required for AMI lookup. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami_architecture"></a> [ami\_architecture](#output\_ami\_architecture) | The architecture of the AMI (e.g., x86\_64, arm64). |
| <a name="output_ami_arn"></a> [ami\_arn](#output\_ami\_arn) | The ARN of the selected AMI. Null when ami\_id is provided directly. |
| <a name="output_ami_description"></a> [ami\_description](#output\_ami\_description) | The description of the selected AMI. Null when ami\_id is provided directly. |
| <a name="output_ami_id"></a> [ami\_id](#output\_ami\_id) | The AMI ID. Uses ami\_id directly when provided, otherwise the lookup result. |
| <a name="output_ami_image_location"></a> [ami\_image\_location](#output\_ami\_image\_location) | The image location of the selected AMI. Null when ami\_id is provided directly. |
| <a name="output_ami_name"></a> [ami\_name](#output\_ami\_name) | The name of the selected AMI. Null when ami\_id is provided directly. |
| <a name="output_ami_owner_id"></a> [ami\_owner\_id](#output\_ami\_owner\_id) | The AWS account ID of the selected AMI owner. Null when ami\_id is provided directly. |
| <a name="output_ami_platform"></a> [ami\_platform](#output\_ami\_platform) | The platform of the AMI (e.g., windows). |
| <a name="output_ami_root_device_name"></a> [ami\_root\_device\_name](#output\_ami\_root\_device\_name) | The root device name of the selected AMI. Null when ami\_id is provided directly. |
| <a name="output_ami_root_device_type"></a> [ami\_root\_device\_type](#output\_ami\_root\_device\_type) | The root device type of the selected AMI. Null when ami\_id is provided directly. |
| <a name="output_ami_root_snapshot_id"></a> [ami\_root\_snapshot\_id](#output\_ami\_root\_snapshot\_id) | The root snapshot ID of the selected AMI. Null when ami\_id is provided directly. |
| <a name="output_ami_virtualization_type"></a> [ami\_virtualization\_type](#output\_ami\_virtualization\_type) | The virtualization type of the selected AMI. Null when ami\_id is provided directly. |
<!-- END_TF_DOCS -->
</details>
