# AWS Cognito

Production-ready Terraform module for AWS Cognito User Pools and Identity Pools with comprehensive authentication and authorization features.

## Features

- User Pools User directory and authentication service
- Identity Pools Provide AWS credentials to authenticated users
- Hosted UI Pre-built authentication UI with OAuth 2.0 support
- MFA Support SMS and TOTP-based multi-factor authentication
- Advanced Security Adaptive authentication and compromised credentials detection
- Custom Attributes Extend user profiles with custom data
- Lambda Triggers Customize authentication flows with Lambda functions
- Comprehensive Outputs User pool IDs, client IDs, and authentication examples

## Quick Start

```hcl
module "cognito" {
  source = "github.com/llamandcoco/infra-modules//terraform/cognito?ref=<commit-sha>"

  user_pool_name           = "my-app-users"
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  mfa_configuration        = "OPTIONAL"

  user_pool_clients = [
    {
      name = "web-client"
    }
  ]
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|----------|
| Basic | [`tests/basic/main.tf`](tests/basic/main.tf) |
| Advanced | [`tests/advanced/main.tf`](tests/advanced/main.tf) |

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
