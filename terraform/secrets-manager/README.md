# AWS Secrets Manager Terraform Module

A flexible Terraform module for creating and managing AWS Secrets Manager secrets with support for automatic rotation, KMS encryption, and comprehensive tagging.

## Features

- Secret Management: Create and manage secrets with JSON or plain text values
- KMS Encryption: Optional customer-managed KMS keys for encryption at rest
- Automatic Rotation: Support for Lambda-based secret rotation with configurable schedules
- Recovery Protection: Configurable recovery windows to prevent accidental deletion
- Version Control: Track secret versions and updates automatically
- Secure by Default: Uses AWS-managed encryption by default
- Tag Support: Comprehensive tagging for resource organization and cost allocation
- Binary Secrets: Support for binary secret values in addition to strings

## Quick Start

```hcl
module "secrets-manager" {
  source = "github.com/llamandcoco/infra-modules//terraform/secrets-manager?ref=<commit-sha>"

  secrets = {
    "prod/database/password" = {
      secret_string = jsonencode({
        username = "admin"
        password = "super-secret-password"
      })
      description = "Database credentials"
    }
  }
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
| [aws_secretsmanager_secret.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_rotation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_rotation) | resource |
| [aws_secretsmanager_secret_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags to add to all secrets. Use this for resource organization, cost allocation, and governance. Individual secret tags will be merged with these. | `map(string)` | `{}` | no |
| <a name="input_default_kms_key_id"></a> [default\_kms\_key\_id](#input\_default\_kms\_key\_id) | Default KMS key ID for secret encryption if not specified per secret. If not specified, uses the AWS managed key (aws/secretsmanager). | `string` | `null` | no |
| <a name="input_default_recovery_window_in_days"></a> [default\_recovery\_window\_in\_days](#input\_default\_recovery\_window\_in\_days) | Default recovery window in days for deleted secrets if not specified per secret. Must be between 7 and 30 days. Set to 0 for immediate deletion (not recommended for production). | `number` | `30` | no |
| <a name="input_default_rotation_days"></a> [default\_rotation\_days](#input\_default\_rotation\_days) | Default number of days between automatic rotations if not specified per secret. Must be between 1 and 365 days. | `number` | `30` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Map of secrets to create in AWS Secrets Manager. Key is the secret name,<br>value is an object with secret configuration.<br><br>Example:<br>  secrets = {<br>    "prod/database/password" = {<br>      secret\_string = jsonencode({<br>        username = "admin"<br>        password = "super-secret-password"<br>      })<br>      description             = "Database credentials"<br>      kms\_key\_id              = "alias/app-secrets"<br>      rotation\_enabled        = true<br>      rotation\_lambda\_arn     = "arn:aws:lambda:us-east-1:123456789012:function:SecretsManagerRotation"<br>      rotation\_days           = 30<br>    }<br>    "prod/api/key" = {<br>      secret\_string = "api-key-value"<br>      description   = "API key for external service"<br>    }<br>  } | <pre>map(object({<br>    secret_string           = optional(string)<br>    secret_binary           = optional(string)<br>    description             = optional(string)<br>    kms_key_id              = optional(string)<br>    recovery_window_in_days = optional(number)<br>    rotation_enabled        = optional(bool)<br>    rotation_lambda_arn     = optional(string)<br>    rotation_days           = optional(number)<br>    version_stages          = optional(list(string))<br>    tags                    = optional(map(string))<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret_arns"></a> [secret\_arns](#output\_secret\_arns) | Map of secret ARNs. Use this for IAM policies, cross-account access, and resource tagging. |
| <a name="output_secret_ids"></a> [secret\_ids](#output\_secret\_ids) | Map of secret IDs. Use this to reference secrets in other resources or data sources. |
| <a name="output_secret_versions"></a> [secret\_versions](#output\_secret\_versions) | Map of current secret version IDs. Useful for tracking secret updates and changes. |
| <a name="output_secrets"></a> [secrets](#output\_secrets) | Complete map of all secret details including ID, ARN, version, rotation status, etc. |
<!-- END_TF_DOCS -->
</details>
