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
<!-- END_TF_DOCS -->
</details>
