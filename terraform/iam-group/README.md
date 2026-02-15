# IAM Group

Terraform module for creating and managing AWS IAM groups with policy attachments and user membership.

## Features

- IAM group with configurable name and path
- Managed policy attachments (AWS and customer managed)
- Inline policy support
- User membership management

## Quick Start

```hcl
module "iam_group" {
  source = "github.com/llamandcoco/infra-modules//terraform/iam-group?ref=<commit-sha>"

  name = "developers"
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic Configuration | [`tests/basic/main.tf`](tests/basic/main.tf) |
| Advanced (Inline Policies + Members) | [`tests/advanced/main.tf`](tests/advanced/main.tf) |

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
<!-- END_TF_DOCS -->
</details>
