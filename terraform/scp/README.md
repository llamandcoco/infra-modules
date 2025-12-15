# AWS Service Control Policy (SCP) - Region Restriction

Terraform module to create an AWS Organizations Service Control Policy (SCP) that restricts resource creation to specific AWS regions.

## Features

- Enforces region restriction at the organization level
- Prevents resource creation outside allowed regions
- Optionally allows global services (IAM, CloudFront, etc.)
- Supports attachment to organizational units or accounts
- Configurable allowed regions list

## Usage

### Basic Example

```hcl
module "region_restriction_scp" {
  source = "github.com/your-org/infra-modules//terraform/scp?ref=v1.0.0"

  policy_name     = "restrict-to-canada-korea"
  allowed_regions = ["ca-central-1", "ap-northeast-2"]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### With Policy Attachment

```hcl
module "region_restriction_scp" {
  source = "github.com/your-org/infra-modules//terraform/scp?ref=v1.0.0"

  policy_name     = "restrict-to-canada-korea"
  allowed_regions = ["ca-central-1", "ap-northeast-2"]

  # Attach to specific OUs or accounts
  target_ids = [
    "ou-xxxx-yyyyyyyy",  # Organizational Unit ID
    "123456789012",       # AWS Account ID
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### Custom Configuration

```hcl
module "region_restriction_scp" {
  source = "github.com/your-org/infra-modules//terraform/scp?ref=v1.0.0"

  policy_name             = "custom-region-policy"
  description             = "Custom region restriction for development"
  allowed_regions         = ["us-east-1", "us-west-2"]
  allow_global_services   = false  # Strict regional enforcement

  target_ids = ["ou-xxxx-yyyyyyyy"]

  tags = {
    Environment = "development"
    ManagedBy   = "terraform"
    CostCenter  = "engineering"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| aws_organizations_policy.region_restriction | resource |
| aws_organizations_policy_attachment.region_restriction | resource |
| aws_iam_policy_document.region_restriction | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| policy_name | Name of the Service Control Policy | `string` | `"region-restriction-policy"` | no |
| description | Description of the Service Control Policy | `string` | `"Restricts resource creation to allowed regions only"` | no |
| allowed_regions | List of AWS regions where resource creation is allowed | `list(string)` | `["ca-central-1", "ap-northeast-2"]` | no |
| allow_global_services | Whether to allow global AWS services (IAM, CloudFront, etc.) | `bool` | `true` | no |
| target_ids | List of organizational unit IDs or account IDs to attach the policy to | `list(string)` | `[]` | no |
| tags | A map of tags to add to the SCP | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| policy_id | The ID of the Service Control Policy |
| policy_arn | The ARN of the Service Control Policy |
| policy_name | The name of the Service Control Policy |
| policy_content | The JSON content of the Service Control Policy |
| allowed_regions | List of allowed AWS regions |
| attachment_ids | Map of target IDs to their policy attachment IDs |

## Important Notes

### Prerequisites

- AWS Organizations must be enabled in your AWS account
- You must have permissions to create and manage SCPs
- The account applying this Terraform configuration should be the organization's management account

### Global Services

When `allow_global_services = true` (default), the following services are exempted from region restrictions:
- IAM (Identity and Access Management)
- AWS Organizations
- Route 53
- CloudFront
- Global Accelerator
- Import/Export
- Support
- Trusted Advisor

These services are global by nature and don't operate in specific regions.

### Policy Attachment

- If `target_ids` is empty, the policy will be created but not attached
- You can attach the policy manually later or through another Terraform configuration
- Valid target IDs include:
  - Root organization ID (r-xxxx)
  - Organizational Unit IDs (ou-xxxx-yyyyyyyy)
  - AWS Account IDs (123456789012)

### Testing

This module includes test cases that validate:
- Policy creation with default regions (ca-central-1, ap-northeast-2)
- Policy creation with custom regions
- Policy attachment to targets
- Global services exemption

## Examples

See the [tests](./tests) directory for complete working examples.

## Security Considerations

- **Review Before Applying**: SCPs can prevent critical operations. Test in non-production first.
- **Emergency Access**: Ensure you have a mechanism to detach SCPs if needed
- **Global Services**: Consider carefully whether to allow global services
- **Root Account**: SCPs don't affect the root account of member accounts

## License

See [LICENSE](../../LICENSE) file for details.

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
| [aws_organizations_policy.region_restriction](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) | resource |
| [aws_organizations_policy_attachment.region_restriction](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |
| [aws_iam_policy_document.region_restriction](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_global_services"></a> [allow\_global\_services](#input\_allow\_global\_services) | Whether to allow global AWS services (IAM, CloudFront, etc.) that don't operate in specific regions | `bool` | `true` | no |
| <a name="input_allowed_regions"></a> [allowed\_regions](#input\_allowed\_regions) | List of AWS regions where resource creation is allowed | `list(string)` | <pre>[<br/>  "ca-central-1",<br/>  "ap-northeast-2"<br/>]</pre> | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the Service Control Policy | `string` | `"Restricts resource creation to allowed regions only"` | no |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name) | Name of the Service Control Policy | `string` | `"region-restriction-policy"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to the SCP | `map(string)` | `{}` | no |
| <a name="input_target_ids"></a> [target\_ids](#input\_target\_ids) | List of organizational unit IDs or account IDs to attach the policy to. Leave empty to create policy without attachment. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_allowed_regions"></a> [allowed\_regions](#output\_allowed\_regions) | List of allowed AWS regions |
| <a name="output_attachment_ids"></a> [attachment\_ids](#output\_attachment\_ids) | Map of target IDs to their policy attachment IDs |
| <a name="output_policy_arn"></a> [policy\_arn](#output\_policy\_arn) | The ARN of the Service Control Policy |
| <a name="output_policy_content"></a> [policy\_content](#output\_policy\_content) | The JSON content of the Service Control Policy |
| <a name="output_policy_id"></a> [policy\_id](#output\_policy\_id) | The ID of the Service Control Policy |
| <a name="output_policy_name"></a> [policy\_name](#output\_policy\_name) | The name of the Service Control Policy |
<!-- END_TF_DOCS -->
