# OIDC Module Examples

This directory contains comprehensive examples for various OIDC providers and use cases.

## Available Examples

### [GitHub Actions](./github-actions/)
Configure OIDC for GitHub Actions workflows to deploy to AWS without storing credentials.

**Key features:**
- Single repository access
- Organization-wide access
- Multi-branch deployments
- Custom inline policies

**Use when:** Running CI/CD pipelines in GitHub Actions

---

### [GitLab CI](./gitlab-ci/)
Set up OIDC for GitLab CI/CD pipelines (both GitLab.com and self-managed).

**Key features:**
- Project-specific access
- Multi-environment support
- Self-managed GitLab instances
- Container registry integration

**Use when:** Running CI/CD pipelines in GitLab

---

### [Google Cloud](./google-cloud/)
Enable Google Cloud workloads to access AWS using Workload Identity Federation.

**Key features:**
- Cross-cloud authentication
- GCP service account integration
- Data pipeline access
- Multi-cloud workloads

**Use when:** Running workloads in GCP that need AWS access

---

### [Azure DevOps](./azure-devops/)
Configure Azure Pipelines to access AWS resources using OIDC.

**Key features:**
- Service connection integration
- Multi-project support
- Build and deployment pipelines
- Container operations

**Use when:** Using Azure DevOps for CI/CD

---

### [Custom Providers](./custom/)
Examples for various third-party and custom OIDC providers.

**Includes:**
- Kubernetes Service Accounts (EKS, GKE, AKS)
- HashiCorp Vault
- Okta
- Auth0
- Keycloak
- CircleCI
- Generic OIDC setup

**Use when:** Integrating with other OIDC-compatible platforms

---

## Quick Start Guide

### 1. Choose Your Platform

Navigate to the appropriate example directory based on your OIDC provider:

```bash
cd github-actions/     # For GitHub Actions
cd gitlab-ci/          # For GitLab CI
cd google-cloud/       # For Google Cloud
cd azure-devops/       # For Azure DevOps
cd custom/             # For other providers
```

### 2. Review the Example

Each example directory contains:
- `main.tf` - Terraform configuration
- `README.md` - Detailed setup instructions
- Platform-specific configuration files

### 3. Customize for Your Use Case

Update the following in `main.tf`:
- Organization/project names
- Repository names or project paths
- IAM policies and permissions
- Tags and metadata

### 4. Apply the Configuration

```bash
terraform init
terraform plan
terraform apply
```

### 5. Configure Your Platform

Follow the platform-specific README for:
- Setting up service connections
- Configuring workflows/pipelines
- Testing the integration

## Common Patterns

### Pattern 1: Single Repository/Project

Best for production deployments with strict access control.

```hcl
module "production_deploy" {
  source = "../../"

  role_name   = "prod-deploy-role"
  github_org  = "my-org"
  github_repo = "production-app"
  github_branch = "main"

  policy_arns = [
    "arn:aws:iam::aws:policy/PowerUserAccess"
  ]
}
```

### Pattern 2: Organization/Multi-Project Access

For shared infrastructure or tooling.

```hcl
module "org_wide_access" {
  source = "../../"

  role_name   = "org-readonly-role"
  github_org  = "my-org"
  github_repo = "*"

  policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]
}
```

### Pattern 3: Multi-Environment

Different permissions for different branches/environments.

```hcl
module "multi_env" {
  source = "../../"

  role_name = "multi-env-role"

  oidc_subjects = [
    "repo:my-org/app:ref:refs/heads/main",      # Production
    "repo:my-org/app:ref:refs/heads/staging",   # Staging
    "repo:my-org/app:ref:refs/heads/develop"    # Development
  ]

  inline_policy_statements = [
    # Custom policies based on needs
  ]
}
```

### Pattern 4: Least Privilege

Granular permissions using inline policies.

```hcl
module "least_privilege" {
  source = "../../"

  role_name = "specific-access-role"

  inline_policy_statements = [
    {
      sid    = "AllowSpecificS3"
      effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:PutObject"
      ]
      resources = [
        "arn:aws:s3:::my-bucket/deployments/*"
      ]
      condition = null
    }
  ]
}
```

## Comparison Table

| Platform | OIDC Subject Format | Best For | Setup Complexity |
|----------|-------------------|----------|------------------|
| GitHub Actions | `repo:ORG/REPO:ref:refs/heads/BRANCH` | CI/CD, deployments | Low |
| GitLab CI | `project_path:GROUP/PROJECT:ref_type:branch:ref:BRANCH` | CI/CD, containers | Low |
| Google Cloud | `https://accounts.google.com/PROJECT_NUMBER` | Multi-cloud, data | Medium |
| Azure DevOps | `sc://ORG/PROJECT/CONNECTION` | Enterprise CI/CD | Medium |
| Kubernetes | `system:serviceaccount:NAMESPACE:SA_NAME` | In-cluster access | Medium |
| Vault | `vault:role:ROLE_NAME` | Dynamic credentials | High |
| Okta/Auth0 | `okta:user:EMAIL` or `auth0\|USER_ID` | SSO, federation | Medium |

## Security Recommendations

### 1. Principle of Least Privilege
Always grant the minimum permissions needed:
```hcl
# Good: Specific permissions
inline_policy_statements = [
  {
    sid    = "AllowSpecificBucket"
    effect = "Allow"
    actions = ["s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::my-bucket/path/*"]
  }
]

# Avoid: Overly permissive
policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
```

### 2. Limit Subject Scope
Be specific in OIDC subjects:
```hcl
# Good: Specific repository and branch
github_org    = "my-org"
github_repo   = "my-app"
github_branch = "main"

# Avoid: Too permissive
github_org  = "my-org"
github_repo = "*"
```

### 3. Use Separate Roles per Environment
```hcl
# Production role
module "prod_role" {
  role_name     = "prod-deploy"
  github_branch = "main"
  # Production permissions
}

# Staging role
module "staging_role" {
  role_name     = "staging-deploy"
  github_branch = "staging"
  # Staging permissions (potentially more permissive)
}
```

### 4. Enable CloudTrail Logging
Monitor all AssumeRoleWithWebIdentity calls for audit and security.

### 5. Set Appropriate Session Duration
```hcl
# For quick deployments
max_session_duration = 3600  # 1 hour

# For long-running processes
max_session_duration = 7200  # 2 hours
```

## Troubleshooting

### Common Errors

**"Not authorized to perform sts:AssumeRoleWithWebIdentity"**
1. Verify OIDC subject claim matches trust policy
2. Check audience claim matches client_id_list
3. Ensure OIDC provider exists in AWS

**"Invalid identity token"**
1. Token may be expired
2. Audience doesn't match
3. OIDC provider URL mismatch

**"Access denied" during AWS operations**
1. Role assumed successfully but lacks permissions
2. Review attached policies
3. Check resource-based policies

### Debug Steps

1. **Verify OIDC Provider**
```bash
aws iam list-open-id-connect-providers
```

2. **Check Role Trust Policy**
```bash
aws iam get-role --role-name YOUR_ROLE_NAME
```

3. **Test AssumeRole**
```bash
aws sts assume-role-with-web-identity \
  --role-arn YOUR_ROLE_ARN \
  --role-session-name test \
  --web-identity-token YOUR_TOKEN
```

4. **Review CloudTrail**
Look for AssumeRoleWithWebIdentity events to see failure details.

## Additional Resources

- [Main Module Documentation](../README.md)
- [AWS OIDC Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [GitHub Actions OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [GitLab CI OIDC](https://docs.gitlab.com/ee/ci/cloud_services/)
- [OIDC Specification](https://openid.net/specs/openid-connect-core-1_0.html)

## Contributing

If you have examples for additional OIDC providers or use cases, please contribute!
