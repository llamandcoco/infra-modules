# CodePipeline Module

Minimal Terraform module to provision AWS CodePipeline with GitHub source and CodeBuild integration.

## Features

- CodePipeline with GitHub source integration
- Automatic S3 artifact bucket with encryption and versioning
- Optional customer-managed KMS encryption for S3 artifacts
- CodeBuild integration for build stage
- GitHub OAuth token from SSM Parameter Store
- IAM role with least-privilege inline policies
- S3 bucket public access block for security

## Quick Start

```hcl
module "pipeline" {
  source = "github.com/llamandcoco/infra-modules//terraform/codepipeline?ref=<commit-sha>"

  pipeline_name = "my-app-pipeline"
  env           = "prod"
  app           = "myapp"

  github_owner  = "myorg"
  github_repo   = "myapp"
  github_branch = "main"

  codebuild_project_name = "my-app-build"
  codebuild_project_arn  = "arn:aws:codebuild:us-east-1:123456789012:project/my-app-build"

  # Optional: Use customer-managed KMS key for S3 encryption
  # kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|----------|
| Basic | [`tests/basic/main.tf`](tests/basic/main.tf) |

**Usage:**
```bash
# View example
cat tests/basic/main.tf

# Copy and adapt
cp -r tests/basic/ my-project/
```

## Prerequisites

### GitHub OAuth Token in SSM

This module requires a GitHub OAuth token to be stored in AWS Systems Manager Parameter Store:

```bash
# Store GitHub token in SSM Parameter Store
aws ssm put-parameter \
  --name "/<env>/<app>/github-token" \
  --value "ghp_your_token_here" \
  --type "SecureString" \
  --description "GitHub OAuth token for CodePipeline"
```

Example for dev environment:
```bash
aws ssm put-parameter \
  --name "/dev/myapp/github-token" \
  --value "ghp_xxxxxxxxxxxx" \
  --type "SecureString"
```

## IAM Permissions

The module creates an IAM role with the following permissions:

1. **S3 Artifact Access**
   - Get, put, and list objects in the artifact bucket

2. **CodeBuild Integration**
   - Start builds and get build status

3. **SSM Parameter Access**
   - Read GitHub token from Parameter Store

4. **KMS (Optional)**
   - When `kms_key_id` is provided, adds decrypt/encrypt permissions automatically

## Testing

The module includes test configurations that can run without AWS credentials:

```bash
cd tests/basic
terraform init -backend=false
terraform plan
```

For testing without AWS access, use the `skip_data_source_lookup` variable:

```hcl
module "pipeline" {
  source = "..."

  skip_data_source_lookup = true
  mock_account_id         = "123456789012"
  mock_github_token       = "test-token"

  # ... other required variables
}
```

<details>
<summary>Terraform Documentation</summary>

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
| [aws_codepipeline.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |
| [aws_iam_role.pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_s3_bucket.pipeline_artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.pipeline_artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.pipeline_artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.pipeline_artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssm_parameter.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app"></a> [app](#input\_app) | Application name used for resource naming and SSM parameter paths. | `string` | n/a | yes |
| <a name="input_codebuild_project_arn"></a> [codebuild\_project\_arn](#input\_codebuild\_project\_arn) | ARN of the CodeBuild project. Used for IAM permissions. | `string` | n/a | yes |
| <a name="input_codebuild_project_name"></a> [codebuild\_project\_name](#input\_codebuild\_project\_name) | Name of the CodeBuild project to use in the Build stage. | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment name used for resource naming and SSM parameter paths. | `string` | n/a | yes |
| <a name="input_github_branch"></a> [github\_branch](#input\_github\_branch) | GitHub branch to monitor for changes and trigger pipeline executions. | `string` | `"main"` | no |
| <a name="input_github_owner"></a> [github\_owner](#input\_github\_owner) | GitHub repository owner (organization or username). | `string` | n/a | yes |
| <a name="input_github_repo"></a> [github\_repo](#input\_github\_repo) | GitHub repository name. | `string` | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key ID for S3 bucket encryption.<br/>If not provided, uses AWS-managed encryption (AES256).<br/>For enhanced security, provide a customer-managed KMS key ARN or alias.<br/>Examples:<br/>- Key ARN: arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012<br/>- Alias ARN: arn:aws:kms:us-east-1:123456789012:alias/my-key<br/>- Key ID: 12345678-1234-1234-1234-123456789012 | `string` | `null` | no |
| <a name="input_mock_account_id"></a> [mock\_account\_id](#input\_mock\_account\_id) | Mock AWS account ID to use when skip\_data\_source\_lookup is true. | `string` | `"123456789012"` | no |
| <a name="input_mock_github_token"></a> [mock\_github\_token](#input\_mock\_github\_token) | Mock GitHub token to use when skip\_data\_source\_lookup is true. | `string` | `"mock-token"` | no |
| <a name="input_pipeline_name"></a> [pipeline\_name](#input\_pipeline\_name) | Name of the CodePipeline. Used for resource naming and tagging. | `string` | n/a | yes |
| <a name="input_skip_data_source_lookup"></a> [skip\_data\_source\_lookup](#input\_skip\_data\_source\_lookup) | Skip AWS data source lookups for testing without credentials. Uses mock values instead. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_artifact_bucket_arn"></a> [artifact\_bucket\_arn](#output\_artifact\_bucket\_arn) | The ARN of the S3 bucket for pipeline artifacts. |
| <a name="output_artifact_bucket_id"></a> [artifact\_bucket\_id](#output\_artifact\_bucket\_id) | The ID of the S3 bucket for pipeline artifacts. |
| <a name="output_artifact_bucket_name"></a> [artifact\_bucket\_name](#output\_artifact\_bucket\_name) | The name of the S3 bucket for pipeline artifacts. |
| <a name="output_artifact_bucket_region"></a> [artifact\_bucket\_region](#output\_artifact\_bucket\_region) | The AWS region of the S3 bucket. |
| <a name="output_pipeline_arn"></a> [pipeline\_arn](#output\_pipeline\_arn) | The ARN of the CodePipeline. |
| <a name="output_pipeline_id"></a> [pipeline\_id](#output\_pipeline\_id) | The ID of the CodePipeline. |
| <a name="output_pipeline_name"></a> [pipeline\_name](#output\_pipeline\_name) | The name of the CodePipeline. |
| <a name="output_pipeline_role_arn"></a> [pipeline\_role\_arn](#output\_pipeline\_role\_arn) | The ARN of the CodePipeline IAM role. |
| <a name="output_pipeline_role_id"></a> [pipeline\_role\_id](#output\_pipeline\_role\_id) | The ID of the CodePipeline IAM role. |
| <a name="output_pipeline_role_name"></a> [pipeline\_role\_name](#output\_pipeline\_role\_name) | The name of the CodePipeline IAM role. |
<!-- END_TF_DOCS -->
</details>
