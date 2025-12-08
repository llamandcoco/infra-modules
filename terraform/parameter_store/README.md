# AWS SSM Parameter Store Terraform Module

This module creates AWS Systems Manager (SSM) Parameter Store parameters with support for encryption, validation, and multiple parameter types.

## Features

- **Multiple Parameter Types**: String, StringList, and SecureString
- **KMS Encryption**: Optional customer-managed KMS keys for SecureString parameters
- **Flexible Tiers**: Support for Standard, Advanced, and Intelligent-Tiering
- **Data Validation**: Optional allowed patterns and data types
- **Secure by Default**: Uses SecureString type by default for sensitive data
- **Tag Support**: Comprehensive tagging for resource organization

## Usage

### Basic SecureString Parameter (Recommended)

```hcl
module "database_password" {
  source = "github.com/your-org/infra-modules//terraform/parameter_store?ref=v1.0.0"

  parameter_name = "/app/production/database/password"
  value          = var.db_password
  description    = "Production database password"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### String Parameter (Non-Sensitive Data)

```hcl
module "api_endpoint" {
  source = "github.com/your-org/infra-modules//terraform/parameter_store?ref=v1.0.0"

  parameter_name = "/app/production/config/api-endpoint"
  value          = "https://api.example.com"
  type           = "String"
  description    = "API endpoint URL"

  tags = {
    Environment = "production"
  }
}
```

### StringList Parameter

```hcl
module "allowed_ips" {
  source = "github.com/your-org/infra-modules//terraform/parameter_store?ref=v1.0.0"

  parameter_name = "/app/production/security/allowed-ips"
  value          = "10.0.0.1,10.0.0.2,10.0.0.3"
  type           = "StringList"
  description    = "Comma-separated list of allowed IP addresses"

  tags = {
    Environment = "production"
  }
}
```

### SecureString with Custom KMS Key

```hcl
module "api_key" {
  source = "github.com/your-org/infra-modules//terraform/parameter_store?ref=v1.0.0"

  parameter_name = "/app/production/api/key"
  value          = var.api_key
  type           = "SecureString"
  kms_key_id     = aws_kms_key.app.arn
  description    = "API key encrypted with custom KMS key"
  tier           = "Standard"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### Advanced Tier with Validation

```hcl
module "large_config" {
  source = "github.com/your-org/infra-modules//terraform/parameter_store?ref=v1.0.0"

  parameter_name  = "/app/production/config/large-json"
  value           = jsonencode(var.large_config)
  type            = "String"
  tier            = "Advanced"  # Supports up to 8KB
  description     = "Large configuration file"
  allowed_pattern = "^\\{.*\\}$"  # Ensures valid JSON structure

  tags = {
    Environment = "production"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| parameter_name | Name of the SSM parameter. Must start with forward slash (/) | `string` | n/a | yes |
| value | Value of the parameter (sensitive for SecureString) | `string` | n/a | yes |
| type | Parameter type: String, StringList, or SecureString | `string` | `"SecureString"` | no |
| kms_key_id | KMS key for SecureString encryption (uses AWS-managed key if null) | `string` | `null` | no |
| description | Description of the parameter | `string` | `null` | no |
| tier | Parameter tier: Standard, Advanced, or Intelligent-Tiering | `string` | `"Standard"` | no |
| overwrite | Whether to overwrite existing parameter | `bool` | `true` | no |
| data_type | Data type for validation (text or aws:ec2:image) | `string` | `null` | no |
| allowed_pattern | Regex pattern to validate parameter values | `string` | `null` | no |
| tags | Map of tags to add to the parameter | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| parameter_name | The name of the SSM parameter |
| parameter_arn | The ARN of the SSM parameter |
| parameter_type | The type of the parameter |
| parameter_tier | The tier of the parameter |
| parameter_version | The version number of the parameter |
| kms_key_id | The KMS key ID used for encryption |
| data_type | The data type of the parameter |
| tags | All tags applied to the parameter |

## Parameter Types

### String
- **Use Case**: Non-sensitive configuration values
- **Encryption**: None
- **Examples**: API endpoints, feature flags, version numbers

### StringList
- **Use Case**: Comma-separated lists of values
- **Encryption**: None
- **Examples**: IP whitelists, allowed regions, environment names

### SecureString (Default)
- **Use Case**: Sensitive data requiring encryption
- **Encryption**: KMS (AWS-managed or customer-managed)
- **Examples**: Passwords, API keys, tokens, certificates

## Parameter Tiers

### Standard
- **Size Limit**: 4 KB
- **Cost**: Free
- **Use Case**: Most parameters

### Advanced
- **Size Limit**: 8 KB
- **Cost**: Charges apply
- **Use Case**: Large configuration files

### Intelligent-Tiering
- **Size Limit**: Automatic selection
- **Cost**: Variable
- **Use Case**: Parameters with changing size requirements

## Security Best Practices

1. **Use SecureString for Sensitive Data**: Always use `type = "SecureString"` for passwords, tokens, and keys
2. **Custom KMS Keys**: Use customer-managed KMS keys for enhanced control and audit capabilities
3. **Least Privilege Access**: Grant IAM permissions only to specific parameter paths
4. **Parameter Naming**: Use hierarchical naming like `/app/environment/service/parameter`
5. **Rotation**: Regularly rotate sensitive parameters
6. **Audit**: Enable CloudTrail logging for parameter access

## Examples

See the [tests/basic](./tests/basic/main.tf) directory for complete examples including:
- Basic SecureString parameter
- SecureString with custom KMS key
- String parameter for non-sensitive data
- StringList parameter for comma-separated values

## Notes

- Parameters names must start with `/` and can be up to 2048 characters
- Standard tier parameters are limited to 4 KB, use Advanced tier for larger values
- SecureString parameters are automatically encrypted (default AWS-managed key or custom KMS key)
- Parameter versions increment with each update
- Use `overwrite = false` to prevent accidental parameter overwrites

<!-- BEGIN_TF_DOCS -->
<!-- terraform-docs output will be inserted here by pre-commit hook -->
<!-- END_TF_DOCS -->
