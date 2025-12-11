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
| [aws_ecr_lifecycle_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_force_delete"></a> [force\_delete](#input\_force\_delete) | Allow deletion of the repository even if it contains images.<br/>Use with caution in production environments. Setting this to true will delete all images when the repository is destroyed. | `bool` | `false` | no |
| <a name="input_image_tag_mutability"></a> [image\_tag\_mutability](#input\_image\_tag\_mutability) | Image tag mutability setting. Use 'IMMUTABLE' to prevent image tags from being overwritten (recommended for production).<br/>Use 'MUTABLE' to allow tags to be updated (useful for development workflows with 'latest' tags). | `string` | `"IMMUTABLE"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of the KMS key to use for encryption at rest. If not specified, AES256 encryption will be used.<br/>Use a KMS key when you need:<br/>- Fine-grained access control over encryption keys<br/>- Audit trails via CloudTrail for key usage<br/>- Ability to disable/rotate encryption keys<br/>- Cross-account repository access with custom encryption | `string` | `null` | no |
| <a name="input_lifecycle_policy"></a> [lifecycle\_policy](#input\_lifecycle\_policy) | List of lifecycle policy rules to manage image retention and cleanup.<br/>Use lifecycle policies to:<br/>- Remove old or unused images to reduce storage costs<br/>- Keep only the N most recent images<br/>- Expire images older than X days<br/>- Keep images matching specific tag patterns<br/><br/>Each rule includes:<br/>- description: Human-readable description of the rule<br/>- priority: Optional explicit priority (lower numbers have higher priority). If not specified, rules are prioritized by their order in the list (first = priority 1)<br/>- tag\_status: Either 'tagged', 'untagged', or 'any'<br/>- tag\_prefix\_list: List of tag prefixes to match (only for tagged images, omit for untagged/any)<br/>- count\_type: Either 'imageCountMoreThan' or 'sinceImagePushed'<br/>- count\_unit: 'days' (only for sinceImagePushed, omit for imageCountMoreThan)<br/>- count\_number: Number of images or days<br/><br/>Example:<br/>lifecycle\_policy = [<br/>  {<br/>    description     = "Keep only 10 most recent production images"<br/>    tag\_status      = "tagged"<br/>    tag\_prefix\_list = ["prod-"]<br/>    count\_type      = "imageCountMoreThan"<br/>    count\_number    = 10<br/>  },<br/>  {<br/>    description  = "Remove untagged images older than 7 days"<br/>    tag\_status   = "untagged"<br/>    count\_type   = "sinceImagePushed"<br/>    count\_unit   = "days"<br/>    count\_number = 7<br/>  }<br/>] | <pre>list(object({<br/>    description     = string<br/>    priority        = optional(number)<br/>    tag_status      = string<br/>    tag_prefix_list = optional(list(string))<br/>    count_type      = string<br/>    count_unit      = optional(string)<br/>    count_number    = number<br/>  }))</pre> | `null` | no |
| <a name="input_repository_name"></a> [repository\_name](#input\_repository\_name) | Name of the ECR repository. This will be used to identify your container images (e.g., 'my-app', 'backend-service'). While AWS ECR supports mixed case, lowercase is recommended for consistency. | `string` | n/a | yes |
| <a name="input_repository_policy_statements"></a> [repository\_policy\_statements](#input\_repository\_policy\_statements) | List of IAM policy statements for repository access control.<br/>Use repository policies to:<br/>- Grant cross-account access to pull/push images<br/>- Allow specific IAM roles (e.g., CI/CD pipelines) to interact with the repository<br/>- Implement least-privilege access control<br/><br/>Each statement includes:<br/>- sid: Statement ID (unique identifier)<br/>- effect: Either 'Allow' or 'Deny'<br/>- principals: List of AWS principal ARNs (IAM users, roles, or account IDs)<br/>- actions: List of ECR actions (e.g., 'ecr:GetDownloadUrlForLayer', 'ecr:BatchGetImage', 'ecr:PutImage')<br/><br/>Example:<br/>repository\_policy\_statements = [<br/>  {<br/>    sid        = "AllowCrossAccountPull"<br/>    effect     = "Allow"<br/>    principals = ["arn:aws:iam::123456789012:root"]<br/>    actions    = [<br/>      "ecr:GetDownloadUrlForLayer",<br/>      "ecr:BatchGetImage",<br/>      "ecr:BatchCheckLayerAvailability"<br/>    ]<br/>  }<br/>] | <pre>list(object({<br/>    sid        = string<br/>    effect     = string<br/>    principals = list(string)<br/>    actions    = list(string)<br/>  }))</pre> | `null` | no |
| <a name="input_scan_on_push"></a> [scan\_on\_push](#input\_scan\_on\_push) | Enable automatic image scanning on push for security vulnerabilities.<br/>Recommended to keep enabled for security best practices. Scans are performed using Amazon ECR basic scanning or enhanced scanning if enabled at the registry level. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to the ECR repository. Use this to add consistent tagging across your infrastructure for cost allocation, environment identification, etc. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_encryption_type"></a> [encryption\_type](#output\_encryption\_type) | The encryption type used for the repository (AES256 or KMS). |
| <a name="output_image_tag_mutability"></a> [image\_tag\_mutability](#output\_image\_tag\_mutability) | The tag mutability setting for the repository (MUTABLE or IMMUTABLE). Important for understanding image tag update behavior. |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | The ARN of the KMS key used for encryption, if KMS encryption is enabled. |
| <a name="output_lifecycle_policy_enabled"></a> [lifecycle\_policy\_enabled](#output\_lifecycle\_policy\_enabled) | Whether a lifecycle policy is configured for the repository. Indicates if automatic image cleanup is active. |
| <a name="output_registry_id"></a> [registry\_id](#output\_registry\_id) | The registry ID where the repository was created. This is typically your AWS account ID. |
| <a name="output_repository_arn"></a> [repository\_arn](#output\_repository\_arn) | The ARN of the ECR repository. Use this for IAM policies, resource tagging, and cross-account access configurations. |
| <a name="output_repository_name"></a> [repository\_name](#output\_repository\_name) | The name of the ECR repository. Use this to reference the repository in deployment configurations. |
| <a name="output_repository_policy_enabled"></a> [repository\_policy\_enabled](#output\_repository\_policy\_enabled) | Whether a repository policy is configured. Indicates if custom access control is in place. |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | The URL of the ECR repository. Use this as the Docker image repository URL for pushing and pulling images (e.g., in CI/CD pipelines). |
| <a name="output_scan_on_push_enabled"></a> [scan\_on\_push\_enabled](#output\_scan\_on\_push\_enabled) | Whether image scanning on push is enabled. Important for security compliance verification. |
| <a name="output_tags"></a> [tags](#output\_tags) | All tags applied to the repository, including default and custom tags. |
<!-- END_TF_DOCS -->

## Security Considerations

- **Encryption**: All repositories use encryption at rest (AES256 by default, optional KMS)
- **Image Scanning**: Enabled by default to detect vulnerabilities
- **Tag Immutability**: Immutable by default to prevent tag overwrites
- **Access Control**: Use repository policies for least-privilege access

## Testing

```
cd tests/basic
terraform init -backend=false
terraform plan
```
