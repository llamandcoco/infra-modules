# IAM User

Creates and manages AWS IAM users with programmatic and console access, policy attachments, and group memberships.

## Features

- Programmatic access with access key generation
- Console access with login profile creation
- Managed policy attachments
- Custom inline policy statements
- IAM group membership management
- Configurable user path
- Force destroy option for cleanup
- Comprehensive tagging support

## Quick Start

```hcl
module "user" {
  source = "github.com/llamandcoco/infra-modules//terraform/iam-user?ref=<commit-sha>"

  name = "application-user"
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic User | [`tests/basic/main.tf`](tests/basic/main.tf) |
| Advanced Configuration | [`tests/advanced/main.tf`](tests/advanced/main.tf) |

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
