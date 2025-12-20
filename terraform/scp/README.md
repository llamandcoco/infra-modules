# AWS Service Control Policy (SCP) - Region Restriction

## Outputs

## Features

- Enforces region restriction at the organization level
- Prevents resource creation outside allowed regions
- Optionally allows global services (IAM, CloudFront, etc.)
- Supports attachment to organizational units or accounts
- Configurable allowed regions list

## Quick Start

```hcl
module "scp" {
  source = "github.com/llamandcoco/infra-modules//terraform/scp?ref=<commit-sha>"

  # Add required variables here
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|----------|
| Basic | [`tests/basic/`](tests/basic/) |

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
