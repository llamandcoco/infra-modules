# IAM Policy Module

Creates a customer-managed IAM policy that can be attached to IAM roles, users, or groups.

## Features

- Create customer-managed IAM policies
- Support for JSON-formatted policy documents
- Support for Terraform policy document data sources
- Configurable policy name and description
- Tag support for policy organization
- Input validation for policy name and JSON format

## Quick Start

```hcl
module "s3_policy" {
  source = "github.com/llamandcoco/infra-modules//terraform/iam-policy?ref=<commit-sha>"

  name        = "my-s3-read-policy"
  description = "Allows read access to S3 bucket"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = ["arn:aws:s3:::my-bucket", "arn:aws:s3:::my-bucket/*"]
      }
    ]
  })
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic S3 Policy | [`tests/basic/main.tf`](tests/basic/main.tf) |
| With Policy Document | [`tests/with_policy_document/main.tf`](tests/with_policy_document/main.tf) |

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
