# DynamoDB Table Module

Production-ready Terraform module for creating and managing AWS DynamoDB tables with comprehensive features.

## Features

- **Flexible Billing**: Support for both PAY_PER_REQUEST (on-demand) and PROVISIONED billing modes
- **Auto Scaling**: Automatic capacity scaling for PROVISIONED mode (table and GSI)
- **Security**: Server-side encryption with AWS owned or customer-managed KMS keys
- **Data Protection**: Point-in-time recovery (PITR) enabled by default
- **Streams**: Optional DynamoDB Streams for change data capture
- **TTL**: Optional Time To Live for automatic item expiration
- **Indexes**: Support for Global Secondary Indexes (GSI) and Local Secondary Indexes (LSI)
- **Table Classes**: Support for STANDARD and STANDARD_INFREQUENT_ACCESS storage classes

## Usage

### Basic Table (PAY_PER_REQUEST)

```hcl
module "dynamodb_table" {
  source = "github.com/llamandcoco/infra-modules//terraform/dynamodb"

  table_name = "my-table"
  hash_key   = "id"

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}
```

### Table with Range Key and Streams

```hcl
module "dynamodb_table" {
  source = "github.com/llamandcoco/infra-modules//terraform/dynamodb"

  table_name = "my-table"
  hash_key   = "user_id"
  range_key  = "timestamp"

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  tags = {
    Environment = "production"
  }
}
```

### Provisioned Capacity with Auto Scaling

```hcl
module "dynamodb_table" {
  source = "github.com/llamandcoco/infra-modules//terraform/dynamodb"

  table_name   = "my-table"
  hash_key     = "id"
  billing_mode = "PROVISIONED"

  read_capacity  = 5
  write_capacity = 5

  enable_autoscaling             = true
  autoscaling_read_min_capacity  = 5
  autoscaling_read_max_capacity  = 100
  autoscaling_write_min_capacity = 5
  autoscaling_write_max_capacity = 100

  tags = {
    Environment = "production"
  }
}
```

### Table with Global Secondary Index

```hcl
module "dynamodb_table" {
  source = "github.com/llamandcoco/infra-modules//terraform/dynamodb"

  table_name = "my-table"
  hash_key   = "id"

  # Define additional attributes for GSI
  attributes = [
    {
      name = "email"
      type = "S"
    }
  ]

  # Create GSI
  global_secondary_indexes = [
    {
      name            = "email-index"
      hash_key        = "email"
      projection_type = "ALL"
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

### Table with TTL and Customer-Managed KMS Key

```hcl
module "dynamodb_table" {
  source = "github.com/llamandcoco/infra-modules//terraform/dynamodb"

  table_name = "my-table"
  hash_key   = "id"

  # Enable TTL
  ttl_enabled        = true
  ttl_attribute_name = "expires_at"

  # Use customer-managed KMS key
  kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  tags = {
    Environment = "production"
  }
}
```

## Security Best Practices

This module implements several security best practices by default:

1. **Encryption at Rest**: Server-side encryption is always enabled (AWS owned key by default)
2. **Point-in-Time Recovery**: Enabled by default for data protection
3. **Secure Defaults**: PAY_PER_REQUEST billing mode to prevent over-provisioning

## Testing

The module includes test configurations in `tests/basic/` that can be run without AWS credentials:

```bash
cd tests/basic
terraform init -backend=false
terraform plan
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## License

See [LICENSE](../../LICENSE) file for details.
