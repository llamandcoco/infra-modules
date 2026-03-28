# GitHub Actions OIDC Example

This example demonstrates how to set up OIDC authentication for GitHub Actions to access AWS resources.

## Prerequisites

- AWS account with appropriate permissions
- GitHub repository
- Terraform >= 1.0

## What This Example Creates

1. **OIDC Provider** - GitHub Actions OIDC provider in AWS
2. **IAM Role** - Role that GitHub Actions can assume
3. **Policies** - Permissions for the role

## Usage

1. Update the variables in `main.tf`:
   - `github_org` - Your GitHub organization name
   - `github_repo` - Your repository name
   - `github_branch` - Branch that can assume the role

2. Apply the Terraform configuration:
```bash
terraform init
terraform plan
terraform apply
```

3. Note the output `role_arn` - you'll need this for your GitHub Actions workflow

4. Configure your GitHub Actions workflow using the example in `workflow-example.yml`

## GitHub Actions Workflow Configuration

Add the following to your `.github/workflows/deploy.yml`:

```yaml
permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: ap-northeast-2
```

## Security Best Practices

1. **Limit repository access** - Use specific repository names instead of `*`
2. **Limit branch access** - Specify exact branches (e.g., `main`) instead of `*`
3. **Principle of least privilege** - Grant only necessary permissions
4. **Use secrets** - Store the role ARN in GitHub repository secrets

## Examples in This Directory

- **single_repo** - OIDC for a specific repository and branch
- **org_wide** - OIDC for all repositories in an organization
- **multi_branch** - OIDC supporting multiple branches with custom policies

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_github_actions_multi_branch"></a> [github\_actions\_multi\_branch](#module\_github\_actions\_multi\_branch) | ../../ | n/a |
| <a name="module_github_actions_org_wide"></a> [github\_actions\_org\_wide](#module\_github\_actions\_org\_wide) | ../../ | n/a |
| <a name="module_github_actions_single_repo"></a> [github\_actions\_single\_repo](#module\_github\_actions\_single\_repo) | ../../ | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_multi_branch_role_arn"></a> [multi\_branch\_role\_arn](#output\_multi\_branch\_role\_arn) | Role ARN for multi-branch deployment |
| <a name="output_org_wide_role_arn"></a> [org\_wide\_role\_arn](#output\_org\_wide\_role\_arn) | Role ARN for organization-wide access |
| <a name="output_single_repo_role_arn"></a> [single\_repo\_role\_arn](#output\_single\_repo\_role\_arn) | Role ARN for single repository - use this in GitHub Actions workflow |
<!-- END_TF_DOCS -->
