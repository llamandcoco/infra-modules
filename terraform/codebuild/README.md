# CodeBuild Module

Minimal Terraform module to provision AWS CodeBuild project for Docker image building and pushing to ECR.

## Features

- CodeBuild project with Docker build support
- GitHub webhook trigger (automatic on push)
- ECR push credentials built-in
- CloudWatch Logs integration
- Optional S3 artifact bucket access for CodePipeline integration
- Inline IAM policies for least-privilege access

## Quick Start

```hcl
module "codebuild" {
  source = "github.com/llamandcoco/infra-modules//terraform/codebuild?ref=<commit-sha>"

  project_name        = "my-docker-build"
  ecr_repository_name = "my-app"
  aws_account_id      = "123456789012"

  github_location = "https://github.com/myorg/myapp.git"
  github_branch   = "main"
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|----------|
| Basic | [`tests/basic/main.tf`](tests/basic/main.tf) |
| With Pipeline | [`tests/with_pipeline/main.tf`](tests/with_pipeline/main.tf) |
| Custom Compute | [`tests/custom_compute/main.tf`](tests/custom_compute/main.tf) |

**Usage:**
```bash
# View example
cat tests/basic/main.tf

# Copy and adapt
cp -r tests/basic/ my-project/
```

## Testing

```bash
cd tests/basic
terraform init -backend=false
terraform plan
```

## Migration Notes

### IAM Policy Changes

This module uses inline IAM policies (`aws_iam_role_policy`) instead of managed policies. If migrating from a previous version that used managed policies, you'll need to import the inline policies:

```bash
# Import inline policies
terragrunt import aws_iam_role_policy.ecr '<role-name>:<policy-name>'
terragrunt import aws_iam_role_policy.logs '<role-name>:<policy-name>'

# Example based on the user's command:
# terragrunt import aws_iam_role_policy.ecr lab-scaling-peak-load-pipeline-role:lab-scaling-peak-load-pipeline-ecr-policy
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
| [aws_cloudwatch_log_group.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_codebuild_project.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_source_credential.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_source_credential) | resource |
| [aws_codebuild_webhook.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_webhook) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_policy_document.assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_artifact_bucket_arn"></a> [artifact\_bucket\_arn](#input\_artifact\_bucket\_arn) | ARN of the S3 bucket for pipeline artifacts. Required when enable\_artifact\_bucket\_access is true. | `string` | `null` | no |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | AWS Account ID for the AWS\_ACCOUNT\_ID environment variable. | `string` | n/a | yes |
| <a name="input_buildspec_path"></a> [buildspec\_path](#input\_buildspec\_path) | Path to buildspec.yml file in the repository. | `string` | `"buildspec.yml"` | no |
| <a name="input_compute_type"></a> [compute\_type](#input\_compute\_type) | CodeBuild compute type determining instance size and resources.<br/>Valid values: BUILD\_GENERAL1\_SMALL, BUILD\_GENERAL1\_MEDIUM, BUILD\_GENERAL1\_LARGE,<br/>BUILD\_GENERAL1\_2XLARGE, BUILD\_LAMBDA\_* | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| <a name="input_ecr_repository_name"></a> [ecr\_repository\_name](#input\_ecr\_repository\_name) | ECR repository name for the IMAGE\_REPO\_NAME environment variable. | `string` | n/a | yes |
| <a name="input_enable_artifact_bucket_access"></a> [enable\_artifact\_bucket\_access](#input\_enable\_artifact\_bucket\_access) | Grant CodeBuild read/write access to the pipeline artifact bucket. Required for CodePipeline integration. | `bool` | `false` | no |
| <a name="input_github_branch"></a> [github\_branch](#input\_github\_branch) | GitHub branch to build from. Defaults to main. | `string` | `"main"` | no |
| <a name="input_github_location"></a> [github\_location](#input\_github\_location) | GitHub repository URL (e.g., https://github.com/owner/repo.git). Required when source\_type is GITHUB. | `string` | `null` | no |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | GitHub Personal Access Token for webhook authentication.<br/>Leave empty to skip GitHub source credential creation. | `string` | `""` | no |
| <a name="input_github_webhook"></a> [github\_webhook](#input\_github\_webhook) | Enable GitHub webhook trigger for automatic builds on push and pull requests. | `bool` | `true` | no |
| <a name="input_image"></a> [image](#input\_image) | Docker image to use for builds. Must be a CodeBuild-managed or custom image.<br/>Default uses AWS standard image with Docker support. | `string` | `"aws/codebuild/standard:7.0"` | no |
| <a name="input_logs_retention_days"></a> [logs\_retention\_days](#input\_logs\_retention\_days) | CloudWatch Logs retention period in days.<br/>Valid values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653 | `number` | `7` | no |
| <a name="input_privileged_mode"></a> [privileged\_mode](#input\_privileged\_mode) | Enable privileged mode for Docker builds.<br/>Required for building Docker images (docker build, docker-compose). | `bool` | `true` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | CodeBuild project name. Used for resource naming and tagging. | `string` | n/a | yes |
| <a name="input_source_type"></a> [source\_type](#input\_source\_type) | Source type for CodeBuild project.<br/>Valid values: GITHUB, CODEPIPELINE, CODECOMMIT, S3, BITBUCKET, GITHUB\_ENTERPRISE, NO\_SOURCE | `string` | `"GITHUB"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_badge_url"></a> [badge\_url](#output\_badge\_url) | The URL of the build badge when badge\_enabled is true. |
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | The ARN of the CloudWatch Log Group for build logs. |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | The name of the CloudWatch Log Group for build logs. |
| <a name="output_project_arn"></a> [project\_arn](#output\_project\_arn) | The ARN of the CodeBuild project. |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | The ID of the CodeBuild project. |
| <a name="output_project_name"></a> [project\_name](#output\_project\_name) | The name of the CodeBuild project. |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | The ARN of the IAM role used by CodeBuild. |
| <a name="output_role_id"></a> [role\_id](#output\_role\_id) | The ID of the IAM role used by CodeBuild. |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | The name of the IAM role used by CodeBuild. |
| <a name="output_source_credential_arn"></a> [source\_credential\_arn](#output\_source\_credential\_arn) | The ARN of the GitHub source credential (if created). |
| <a name="output_webhook_secret"></a> [webhook\_secret](#output\_webhook\_secret) | The GitHub webhook secret (if webhook is enabled). |
| <a name="output_webhook_url"></a> [webhook\_url](#output\_webhook\_url) | The GitHub webhook payload URL (if webhook is enabled). |
<!-- END_TF_DOCS -->
</details>
