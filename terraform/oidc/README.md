# AWS OIDC Provider for GitHub Actions

A Terraform module for creating AWS IAM OIDC providers and roles for secure GitHub Actions authentication without long-lived credentials.

## Features

- **Secure Authentication** - OIDC-based authentication, no AWS credentials stored in GitHub
- **Automatic Thumbprint** - Retrieves OIDC provider thumbprint automatically
- **Fine-Grained Control** - Repository and branch-level access restrictions
- **Flexible Permissions** - Support for managed policies and inline policy statements
- **Least Privilege** - Explicit subject claims prevent wildcard access
- **Configurable Sessions** - Customizable session duration (default 1 hour)

## Quick Start

```hcl
module "github_oidc" {
  source = "github.com/llamandcoco/infra-modules//terraform/oidc?ref=<commit-sha>"

  role_name = "github-actions-deploy"

  # Explicit control - no wildcards
  github_org    = null
  github_repo   = null
  github_branch = null

  oidc_subjects = [
    "repo:my-org/my-repo:ref:refs/heads/main"
  ]

  policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]
}
```

## Examples

Complete, tested configurations in [`examples/`](examples/):

| Example | Directory | Description |
|---------|-----------|-------------|
| Basic GitHub Actions | [`examples/github-actions/`](examples/github-actions/) | Single repository, specific branches |
| Custom OIDC Provider | [`examples/custom/`](examples/custom/) | Non-GitHub OIDC provider configuration |

**Usage:**
```bash
# View example
cat examples/github-actions/main.tf

# Copy and adapt
cp -r examples/github-actions/ my-project/
```

## GitHub Actions Workflow

After deploying this module, configure your GitHub Actions workflow:

```yaml
name: Deploy
on:
  push:
    branches: [main]

permissions:
  id-token: write   # Required for OIDC
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/github-actions-deploy
          aws-region: us-east-1

      - name: Verify AWS identity
        run: aws sts get-caller-identity
```

## Security Best Practices

### ✅ DO: Use Explicit Subject Claims

```hcl
# Good - Explicit control
github_org    = null
github_repo   = null
github_branch = null

oidc_subjects = [
  "repo:my-org/my-repo:ref:refs/heads/main",
  "repo:my-org/my-repo:ref:refs/heads/develop"
]
```

### ❌ DON'T: Use Wildcards

```hcl
# Bad - Allows any branch
github_org    = "my-org"
github_repo   = "my-repo"
github_branch = "*"  # ⚠️ This creates a wildcard subject!
```

### ✅ DO: Use Principle of Least Privilege

```hcl
inline_policy_statements = [
  {
    sid    = "AllowS3SpecificBucket"
    effect = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "arn:aws:s3:::my-bucket/*"  # Specific bucket
    ]
    condition = null
  }
]
```

### ❌ DON'T: Use Overly Broad Permissions

```hcl
# Bad - Too permissive
policy_arns = [
  "arn:aws:iam::aws:policy/AdministratorAccess"  # ⚠️ Too broad!
]
```

## OIDC Subject Format

GitHub Actions OIDC subjects follow this format:

```
repo:ORGANIZATION/REPOSITORY:CLAIM_TYPE:CLAIM_VALUE
```

### Common Subject Examples

```hcl
# Specific branch
"repo:my-org/my-repo:ref:refs/heads/main"

# Pull requests
"repo:my-org/my-repo:pull_request"

# Specific tag
"repo:my-org/my-repo:ref:refs/tags/v1.0.0"

# Environment
"repo:my-org/my-repo:environment:production"
```

## Testing

```bash
# Test basic example
cd examples/github-actions && terraform init && terraform plan

# Deploy
terraform apply
```

<details>
<summary>Terraform Documentation</summary>

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [tls_certificate.oidc](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_client_id_list"></a> [client\_id\_list](#input\_client\_id\_list) | List of client IDs (audiences) for the OIDC provider | `list(string)` | <pre>[<br/>  "sts.amazonaws.com"<br/>]</pre> | no |
| <a name="input_github_branch"></a> [github\_branch](#input\_github\_branch) | GitHub branch name. Use '*' to allow all branches. If not specified, allows all branches | `string` | `"*"` | no |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | GitHub organization name (required for GitHub Actions OIDC) | `string` | `null` | no |
| <a name="input_github_repo"></a> [github\_repo](#input\_github\_repo) | GitHub repository name (required for GitHub Actions OIDC). Use '*' to allow all repos in the organization | `string` | `null` | no |
| <a name="input_inline_policy_statements"></a> [inline\_policy\_statements](#input\_inline\_policy\_statements) | List of inline policy statements to attach to the role | <pre>list(object({<br/>    sid       = string<br/>    effect    = string<br/>    actions   = list(string)<br/>    resources = list(string)<br/>    condition = optional(list(object({<br/>      test     = string<br/>      variable = string<br/>      values   = list(string)<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_max_session_duration"></a> [max\_session\_duration](#input\_max\_session\_duration) | Maximum session duration in seconds for the IAM role | `number` | `3600` | no |
| <a name="input_oidc_subjects"></a> [oidc\_subjects](#input\_oidc\_subjects) | List of OIDC subject claims for custom providers. Used when not using GitHub Actions | `list(string)` | `[]` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | List of IAM policy ARNs to attach to the role | `list(string)` | `[]` | no |
| <a name="input_provider_url"></a> [provider\_url](#input\_provider\_url) | URL of the OIDC provider (e.g., token.actions.githubusercontent.com for GitHub Actions) | `string` | `"token.actions.githubusercontent.com"` | no |
| <a name="input_role_description"></a> [role\_description](#input\_role\_description) | Description of the IAM role | `string` | `"Role for OIDC authentication"` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name of the IAM role to create for OIDC authentication | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_thumbprint_list"></a> [thumbprint\_list](#input\_thumbprint\_list) | List of server certificate thumbprints. If not provided, will use GitHub Actions thumbprint | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | ARN of the OIDC provider |
| <a name="output_oidc_provider_url"></a> [oidc\_provider\_url](#output\_oidc\_provider\_url) | URL of the OIDC provider |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN of the IAM role for OIDC authentication |
| <a name="output_role_id"></a> [role\_id](#output\_role\_id) | Unique ID of the IAM role |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name of the IAM role |
<!-- END_TF_DOCS -->
</details>
