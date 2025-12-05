# Infrastructure Modules

Public repository for reusable Terraform infrastructure modules.

## Overview

This repository contains well-tested, production-ready Terraform modules for managing cloud infrastructure. All modules are designed to work without requiring cloud credentials during CI/CD testing, making them safe and easy to validate.

## Features

- **Credential-less Testing**: All tests run in GitHub Actions without AWS/cloud credentials
- **Automated Validation**: Terraform fmt, validate, tflint, and tfsec checks on every PR
- **Auto-discovery**: Test modules are automatically discovered and executed
- **Security First**: All modules scanned with tfsec for security best practices
- **Well Documented**: Each module includes comprehensive documentation and examples

## Quick Start

### Using a Module

```hcl
module "example" {
  source = "github.com/your-org/infra-modules//terraform/module-name?ref=v1.0.0"

  # Module-specific variables
  resource_name = "my-resource"
}
```

### Creating a New Module

1. Copy the template:
   ```bash
   cp -r terraform/_template terraform/your-module-name
   ```

2. Update the files:
   - Edit `main.tf` with your resource definitions
   - Define variables in `variables.tf`
   - Add outputs to `outputs.tf`
   - Update `README.md` with module documentation
   - Create test cases in `tests/`

3. Test locally:
   ```bash
   cd terraform/your-module-name/tests/basic
   terraform init -backend=false
   terraform plan
   ```

4. Submit a PR - GitHub Actions will automatically test your module

## Repository Structure

```
infra-modules/
├── terraform/
│   ├── _template/              # Template for new modules
│   └── <module-name>/          # Individual modules (e.g., s3, lambda)
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── README.md
│       └── tests/
│           └── basic/
│               └── main.tf
├── .github/
│   └── workflows/
│       ├── terraform-check.yml
│       └── terraform-module-tests.yml
├── .tflint.hcl                 # TFLint configuration
├── README.md                   # This file
└── AI_README.md                # Detailed documentation for AI/developers
```

## GitHub Actions Workflows

### Terraform Check

Runs on every PR and validates:
- Code formatting (`terraform fmt`)
- Configuration validity (`terraform validate`)
- Linting with TFLint
- Security scanning with tfsec

### Module Tests

Automatically discovers and tests all modules:
- Finds all test cases in `terraform/**/tests/*/main.tf`
- Runs `terraform plan` for each test
- Reports results in PR

**No credentials required** - all tests use mock provider configuration.

## Development

### Prerequisites

- Terraform >= 1.0
- Git
- Pre-commit (optional but recommended)
- TFLint (optional but recommended)
- tfsec (optional but recommended)

### Quick Setup

```bash
# Install all tools (macOS)
make install-tools

# Setup pre-commit hooks
make setup

# Run all tests
make test
```

### Pre-commit Hooks

The repository includes pre-commit hooks that run automatically on `git commit`:

```bash
# One-time setup
bash .pre-commit-setup.sh

# Hooks will now run automatically on every commit
git commit -m "your message"

# Run hooks manually on all files
pre-commit run --all-files
```

**What gets checked automatically:**
- Terraform formatting
- Terraform validation
- TFLint checks
- tfsec security scan
- Trailing whitespace, YAML syntax, etc.

### Make Commands

```bash
make help              # Show all commands
make test              # Run all tests (fmt, validate, lint, security)
make fmt               # Format terraform files
make validate          # Validate configuration
make lint              # Run tflint
make security          # Run tfsec
make test-module MODULE=s3  # Test specific module
make clean             # Clean artifacts
```

### Local Testing (Manual)

```bash
# Format all code
terraform fmt -recursive terraform/

# Validate a module
cd terraform/<module-name>
terraform init -backend=false
terraform validate

# Run a test
cd tests/basic
terraform init -backend=false
terraform plan
```

### Running Linters

```bash
# TFLint
tflint --init
tflint --recursive terraform/

# tfsec
tfsec terraform/
```

## Documentation

- [AI_README.md](./AI_README.md) - Comprehensive guide for developers and AI assistants
- Individual module READMEs in `terraform/<module-name>/README.md`

## Best Practices

- Enable encryption by default
- Block public access by default for data stores
- Use descriptive variable names
- Document all variables and outputs
- Include at least one test case per module
- Run `terraform fmt` before committing
- Use semantic versioning for releases

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add or modify modules
4. Ensure all tests pass locally
5. Submit a pull request

## License

See [LICENSE](./LICENSE) file for details.

## Migration from chatops-platform

This repository consolidates Terraform modules from the `chatops-platform` repository. The workflows and module structure are designed to work identically, with improved auto-discovery and testing capabilities.
