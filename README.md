# Infrastructure Modules

Public repository for reusable Terraform infrastructure modules.

## Overview

This repository contains well-tested, production-ready Terraform modules for managing cloud infrastructure. All modules are designed to work without requiring cloud credentials during CI/CD testing, making them safe and easy to validate.

## Features

- **Credential-less Testing**: All tests run in GitHub Actions without AWS/cloud credentials
- **Automated Validation**: Terraform fmt, validate, TFLint (with AWS rules), and Trivy checks on every PR
- **Local = CI/CD**: Same tools and configurations for local development and GitHub Actions
- **Auto-discovery**: Test modules are automatically discovered and executed
- **Security First**: All modules scanned with Trivy (MEDIUM, HIGH, CRITICAL severity)
- **Smart PR Comments**: Table format with issue counts and expandable details
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

Runs on every PR and validates changed modules:
- **Code formatting** (`terraform fmt`) - All modules
- **Configuration validity** (`terraform validate`) - All modules
- **Linting with TFLint** (AWS plugin enabled) - Changed modules only
- **Security scanning with Trivy** (MEDIUM, HIGH, CRITICAL) - Changed modules only

**PR Comments** include:
- ✅/❌ Summary table with pass/fail status
- 📊 Issue counts (TFLint warnings, Trivy vulnerabilities)
- 📦 List of changed modules
- Expandable details for each check

### Module Tests

Automatically discovers and tests all modules:
- Finds all test cases in `terraform/**/tests/*/main.tf`
- Runs `terraform plan` for each test
- Reports results in PR

**No credentials required** - all tests use mock provider configuration.

## Development

### Prerequisites

**Required:**
- [Terraform](https://www.terraform.io/downloads) >= 1.0
- Git

**Optional (for local development with pre-commit):**
- [pre-commit](https://pre-commit.com/) - Git hook framework
- [TFLint](https://github.com/terraform-linters/tflint) - Terraform linter
- [trivy](https://github.com/aquasecurity/trivy) - Security scanner
- [terraform-docs](https://terraform-docs.io/) - Documentation generator

**Installation (macOS):**
```bash
# Install via Homebrew
brew install terraform
brew install pre-commit
brew install tflint
brew install trivy
brew install terraform-docs
```

**Installation (Linux):**
```bash
# Terraform
wget https://releases.hashicorp.com/terraform/1.x.x/terraform_1.x.x_linux_amd64.zip
unzip terraform_1.x.x_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# pre-commit
pip install pre-commit
# or
curl https://pre-commit.com/install-local.py | python -

# TFLint
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# terraform-docs
GO111MODULE=on go install github.com/terraform-docs/terraform-docs@latest
```

**Or use the automated installer:**
```bash
# Installs all required tools (macOS only)
make install-tools
```

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
- trivy security scan
- Trailing whitespace, YAML syntax, etc.

### Make Commands

```bash
make help                    # Show all commands
make install-tools           # Install required tools (terraform, tflint, trivy)
make test                    # Run all tests (fmt, validate, lint, security)
make fmt                     # Format terraform files
make validate                # Validate configuration
make lint                    # Run tflint (with AWS plugin)
make security                # Run Trivy security scan (matches CI/CD)
make security-tfsec          # Run tfsec (legacy)
make pre-commit              # Run pre-commit on all files
make test-module MODULE=sqs  # Test specific module
make clean                   # Clean artifacts
```

**Local testing matches GitHub Actions workflow** - Same tools, same configurations!

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

### Running Linters and Security Scans

```bash
# TFLint (with AWS plugin)
tflint --init --config=terraform/.tflint.hcl
tflint --recursive --chdir terraform/ --config="$(PWD)/terraform/.tflint.hcl"

# Trivy (matches GitHub Actions)
trivy config terraform/ --severity MEDIUM,HIGH,CRITICAL --quiet

# tfsec (legacy, for comparison)
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
