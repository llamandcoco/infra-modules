# ECR Module

Terraform module for creating and managing AWS Elastic Container Registry (ECR) repositories.

## Features

- **Security by Default**: Encryption (AES256 or KMS), image scanning on push, and immutable tags
- **Lifecycle Management**: Optional image retention policies to reduce storage costs
- **Access Control**: Optional repository policies for cross-account access and CI/CD integration
- **Production Ready**: Follows AWS best practices and passes tfsec security checks

## Usage

### Basic Example

```hcl
module "ecr" {
  source = "github.com/your-org/infra-modules//terraform/ecr?ref=v1.0.0"

  repository_name = "my-application"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### With KMS Encryption

```hcl
module "ecr" {
  source = "github.com/your-org/infra-modules//terraform/ecr?ref=v1.0.0"

  repository_name = "my-application"
  kms_key_arn     = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### With Lifecycle Policy

```hcl
module "ecr" {
  source = "github.com/your-org/infra-modules//terraform/ecr?ref=v1.0.0"

  repository_name = "my-application"

  lifecycle_policy = [
    {
      description     = "Keep last 10 production images"
      tag_status      = "tagged"
      tag_prefix_list = ["prod-"]
      count_type      = "imageCountMoreThan"
      count_number    = 10
    },
    {
      description  = "Remove untagged images older than 7 days"
      tag_status   = "untagged"
      count_type   = "sinceImagePushed"
      count_unit   = "days"
      count_number = 7
    }
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### With Cross-Account Access

```hcl
module "ecr" {
  source = "github.com/your-org/infra-modules//terraform/ecr?ref=v1.0.0"

  repository_name = "my-application"

  repository_policy_statements = [
    {
      sid        = "AllowCrossAccountPull"
      effect     = "Allow"
      principals = ["arn:aws:iam::123456789012:root"]
      actions = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ]
    }
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### Development Environment (Mutable Tags)

```hcl
module "ecr" {
  source = "github.com/your-org/infra-modules//terraform/ecr?ref=v1.0.0"

  repository_name      = "my-application-dev"
  image_tag_mutability = "MUTABLE"

  tags = {
    Environment = "development"
    ManagedBy   = "terraform"
  }
}
```

## Inputs

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Outputs

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Security Considerations

- **Encryption**: All repositories use encryption at rest (AES256 by default, optional KMS)
- **Image Scanning**: Enabled by default to detect vulnerabilities
- **Tag Immutability**: Immutable by default to prevent tag overwrites
- **Access Control**: Use repository policies for least-privilege access

## Examples

See the [tests/basic](./tests/basic) directory for more examples.

## License

See the root LICENSE file for details.
