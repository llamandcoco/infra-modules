# AI_README.md - Infrastructure Modules Repository

This document provides context for AI assistants and developers working with this repository.

## Repository Overview

This repository contains reusable Terraform modules for infrastructure as code. The modules are designed to be composable, well-tested, and follow best practices for security and maintainability.

## Directory Structure

```
infra-modules/
├── terraform/
│   └── <resource-type>/           # e.g., s3, dynamodb, lambda
│       ├── main.tf                # Main resource definitions
│       ├── variables.tf           # Input variables
│       ├── outputs.tf             # Output values
│       ├── README.md              # Module documentation
│       ├── versions.tf            # Terraform and provider version constraints
│       └── tests/
│           └── <test-name>/       # e.g., basic, advanced
│               └── main.tf        # Test configuration
├── .github/
│   └── workflows/
│       ├── terraform-check.yml         # Code quality and validation
│       └── terraform-module-tests.yml  # Module testing
└── AI_README.md                   # This file
```

## GitHub Actions Workflows

### terraform-check.yml

Runs on every PR and push to main. This workflow validates Terraform code quality without requiring cloud credentials.

**Checks performed:**
- **Terraform Format**: Ensures code follows standard formatting (`terraform fmt`)
- **Terraform Validate**: Validates syntax and configuration (`terraform validate`)
- **TFLint**: Linting for best practices and potential issues
- **trivy**: Security scanning for misconfigurations and vulnerabilities

**Key features:**
- Runs with `-backend=false` to avoid needing backend credentials
- All checks run without actual cloud provider credentials
- Posts results as PR comments for easy review
- Fails the build if format or validation fails

### terraform-module-tests.yml

Automatically discovers and tests all module test cases.

**Test execution:**
- **Auto-discovery**: Finds all test modules in `terraform/**/tests/*/main.tf`
- **Matrix strategy**: Runs each test module in parallel
- **Terraform Plan**: Generates execution plan to verify module correctness
- **No Apply**: Never creates actual infrastructure

**Key features:**
- Uses mock AWS credentials for planning
- Tests run completely in CI without cloud access
- Validates that modules can generate valid plans
- Fail-fast disabled to see all test results

## Local Development

### Quick Start

1. **Install tools:**
   ```bash
   make install-tools  # macOS with Homebrew
   # or manually install: terraform, tflint, trivy, pre-commit
   ```

2. **Setup pre-commit hooks:**
   ```bash
   make setup
   # or manually: bash .pre-commit-setup.sh
   ```

3. **Test your changes:**
   ```bash
   make test              # Run all checks
   make test-module MODULE=s3  # Test specific module
   ```

### Pre-commit Hooks

Pre-commit hooks run **automatically on every `git commit`**, regardless of branch:

**What runs automatically:**
- `terraform fmt` - Auto-formats code
- `terraform validate` - Validates configuration
- `tflint` - Linting checks
- `trivy` - Security scanning
- `terraform-docs` - Auto-generates documentation
- File checks - Trailing whitespace, YAML syntax, merge conflicts
- Branch protection - Prevents direct commits to main/master

**Setup:**
```bash
# One-time setup
bash .pre-commit-setup.sh

# Or use make
make setup
```

**Usage:**
```bash
# Runs automatically on commit
git commit -m "your message"

# Run manually on all files
pre-commit run --all-files

# Skip hooks (not recommended)
git commit --no-verify

# Update hooks to latest versions
pre-commit autoupdate
```

### Makefile Commands

The repository includes a `Makefile` for common tasks:

```bash
make help           # Show all available commands
make setup          # Setup pre-commit hooks
make test           # Run all tests
make fmt            # Format all terraform files
make validate       # Validate terraform configuration
make lint           # Run tflint
make security       # Run trivy
make test-module MODULE=s3  # Test specific module
make clean          # Clean terraform artifacts
```

### Local Testing Workflow

**Before committing:**
```bash
# 1. Format your code
make fmt

# 2. Run all checks
make test

# 3. Test specific module
make test-module MODULE=your-module

# 4. Commit (pre-commit hooks will run automatically)
git commit -m "feat: add new module"
```

**Pre-commit will:**
- ✅ Auto-fix formatting issues
- ✅ Validate terraform syntax
- ✅ Run linting checks
- ✅ Scan for security issues
- ❌ Block commit if critical issues found

### Branch Protection

Pre-commit includes `no-commit-to-branch` hook:
- **Prevents direct commits to `main` and `master`**
- Forces use of feature branches and PRs
- Helps maintain code quality through review process

To commit to main (e.g., for initial setup):
```bash
git commit --no-verify
```

## Testing Strategy

### Credential-less Testing

All tests run **without real cloud credentials** by using provider configuration:

```hcl
provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  access_key = "test"
  secret_key = "test"
}
```

This allows:
- `terraform init -backend=false` to work without backend credentials
- `terraform plan` to generate execution plans
- Full validation of module logic and configurations
- **No actual resources are created**

### Test Structure

Each module should include test cases under `tests/` directory:

```
terraform/s3/
├── main.tf
├── variables.tf
├── outputs.tf
└── tests/
    ├── basic/
    │   └── main.tf          # Basic configuration test
    ├── encryption/
    │   └── main.tf          # Test with encryption enabled
    └── lifecycle/
        └── main.tf          # Test with lifecycle rules
```

Test files should:
1. Configure the provider with skip flags (as shown above)
2. Call the module with various configurations
3. Use realistic values (even though resources won't be created)
4. Test edge cases and different feature combinations

## Adding New Modules

When adding a new Terraform module:

1. **Create module structure:**
   ```bash
   mkdir -p terraform/<resource-name>/{tests/basic}
   ```

2. **Create required files:**
   - `main.tf`: Resource definitions
   - `variables.tf`: Input variables with descriptions
   - `outputs.tf`: Output values
   - `versions.tf`: Version constraints
   - `README.md`: Module documentation

3. **Create test case:**
   - Add `terraform/<resource-name>/tests/basic/main.tf`
   - Include mock provider configuration
   - Call the module with test values

4. **Test locally:**
   ```bash
   cd terraform/<resource-name>/tests/basic
   terraform init -backend=false
   terraform plan
   ```

5. **Submit PR:**
   - GitHub Actions will automatically discover and test your module
   - Review the workflow results in the PR

## Module Best Practices

### Security

- Enable encryption by default where applicable
- Block public access by default for data stores
- Use `trivy` ignore comments sparingly and document why
- Never commit real credentials or sensitive data

### Documentation

- Document all variables with descriptions and types
- Provide usage examples in module README
- Include output descriptions
- Document any special requirements or dependencies

### Testing

- Create at least one basic test case
- Test different feature combinations
- Use realistic naming conventions in tests
- Validate that plans generate successfully

### Code Quality

- Run `terraform fmt` before committing
- Use consistent naming conventions
- Group related resources logically
- Use dynamic blocks for repetitive configurations

## Versioning

- Use semantic versioning for module releases
- Tag releases in Git: `v1.0.0`, `v1.1.0`, etc.
- Update version constraints when breaking changes occur
- Document changes in module README or CHANGELOG

## Common Workflows

### Running checks locally

```bash
# Format all Terraform files
terraform fmt -recursive terraform/

# Validate a specific module
cd terraform/<module-name>
terraform init -backend=false
terraform validate

# Run tflint
tflint --init
tflint --recursive terraform/

# Run trivy
trivy terraform/
```

### Testing a module locally

```bash
cd terraform/<module-name>/tests/basic
terraform init -backend=false
terraform plan
```

### Adding a new test case

```bash
# Create test directory
mkdir -p terraform/<module-name>/tests/<test-case-name>

# Create test configuration
cat > terraform/<module-name>/tests/<test-case-name>/main.tf <<EOF
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
  access_key                  = "test"
  secret_key                  = "test"
}

module "test" {
  source = "../../"
  # Add your test configuration here
}
EOF
```

## Troubleshooting

### "Error: No valid credential sources found"

This means the provider configuration is missing skip flags. Ensure test files include:
```hcl
provider "aws" {
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
  access_key                  = "test"
  secret_key                  = "test"
}
```

### "Error: Backend initialization required"

Run `terraform init -backend=false` to initialize without configuring a backend.

### TFLint or trivy warnings

Review the output and either:
- Fix the issue if it's a valid concern
- Add an ignore comment with justification if it's a false positive
- Update `.tflint.hcl` or trivy configuration if needed

## Migration Notes

This repository was created to consolidate Terraform modules from `chatops-platform`. The workflows are designed to work identically but are now centralized in this dedicated infrastructure repository.

### Key Differences from chatops-platform

- Auto-discovery of test modules (no manual matrix configuration)
- Enhanced PR commenting for better visibility
- Consistent workflow structure across all modules
- Dedicated repository for infrastructure modules only

## Future Enhancements

Potential improvements to consider:

- [ ] Add Terragrunt support for multi-environment deployments
- [ ] Implement automated module documentation generation
- [ ] Add cost estimation using Infracost
- [ ] Create module dependency graph visualization
- [ ] Add automated security scanning with Checkov
- [ ] Implement module versioning automation
- [ ] Add example usage in separate directory
- [ ] Create module template/generator script

## Resources

- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Terraform Testing Guide](https://developer.hashicorp.com/terraform/tutorials/configuration-language/test)
- [TFLint Rules](https://github.com/terraform-linters/tflint/tree/master/docs/rules)
- [trivy Checks](https://aquasecurity.github.io/trivy/)

## Questions or Issues?

If you encounter issues or have questions:

1. Check the GitHub Actions logs for detailed error messages
2. Review this document for common patterns and solutions
3. Look at existing modules for reference implementations
4. Open an issue in the repository for discussion
