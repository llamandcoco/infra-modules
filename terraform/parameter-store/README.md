# AWS SSM Parameter Store Terraform Module

## Testing

## Features

- Multiple Parameter Types String, StringList, and SecureString
- KMS Encryption Optional customer-managed KMS keys for SecureString parameters
- Flexible Tiers Support for Standard, Advanced, and Intelligent-Tiering
- Data Validation Optional allowed patterns and data types
- Secure by Default Uses SecureString type by default for sensitive data
- Tag Support Comprehensive tagging for resource organization

## Quick Start

```hcl
module "parameter-store" {
  source = "github.com/llamandcoco/infra-modules//terraform/parameter-store?ref=v1.0.0"

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
| [aws_ssm_parameter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags to add to all parameters. Use this for resource organization, cost allocation, and governance. Individual parameter tags will be merged with these. | `map(string)` | `{}` | no |
| <a name="input_default_kms_key_id"></a> [default\_kms\_key\_id](#input\_default\_kms\_key\_id) | Default KMS key ID for SecureString parameters if not specified per parameter. If not specified, uses the default AWS-managed key (alias/aws/ssm). | `string` | `null` | no |
| <a name="input_default_overwrite"></a> [default\_overwrite](#input\_default\_overwrite) | Default overwrite behavior if not specified per parameter. Set to true to update existing parameters, false to prevent accidental overwrites. | `bool` | `true` | no |
| <a name="input_default_tier"></a> [default\_tier](#input\_default\_tier) | Default parameter tier if not specified per parameter. Standard (up to 4KB, free), Advanced (up to 8KB, charges apply), Intelligent-Tiering (automatic tier selection). | `string` | `"Standard"` | no |
| <a name="input_default_type"></a> [default\_type](#input\_default\_type) | Default parameter type if not specified per parameter. String for plain text, SecureString for encrypted sensitive data (recommended), StringList for comma-separated values. | `string` | `"SecureString"` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | Map of SSM parameters to create. Key is the parameter name (must start with /),<br/>value is an object with parameter configuration.<br/><br/>Example:<br/>  parameters = {<br/>    "/app/db/host" = {<br/>      value       = "db.example.com"<br/>      type        = "String"<br/>      description = "Database hostname"<br/>    }<br/>    "/app/api/key" = {<br/>      value       = "secret-key"<br/>      type        = "SecureString"<br/>      kms\_key\_id  = "alias/app-secrets"<br/>      description = "API key for external service"<br/>    }<br/>  } | <pre>map(object({<br/>    value           = string<br/>    type            = optional(string)<br/>    description     = optional(string)<br/>    tier            = optional(string)<br/>    kms_key_id      = optional(string)<br/>    overwrite       = optional(bool)<br/>    data_type       = optional(string)<br/>    allowed_pattern = optional(string)<br/>    tags            = optional(map(string))<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_parameter_arns"></a> [parameter\_arns](#output\_parameter\_arns) | Map of parameter ARNs. Use this for IAM policies, cross-account access, and resource tagging. |
| <a name="output_parameter_names"></a> [parameter\_names](#output\_parameter\_names) | Map of parameter names. Use this to reference parameters in other resources or data sources. |
| <a name="output_parameter_types"></a> [parameter\_types](#output\_parameter\_types) | Map of parameter types (String, StringList, or SecureString). Useful for validation and documentation. |
| <a name="output_parameter_versions"></a> [parameter\_versions](#output\_parameter\_versions) | Map of parameter versions. Increments with each update, useful for change tracking and rollback scenarios. |
| <a name="output_parameters"></a> [parameters](#output\_parameters) | Complete map of all parameter details including name, ARN, type, version, etc. |
<!-- END_TF_DOCS -->
