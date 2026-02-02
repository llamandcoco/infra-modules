<!-- Generated: 2026-01-31 18:39:36 | Updated: 2026-01-31 21:45:00 -->

# infra-modules

## Purpose

Public repository for reusable Terraform infrastructure modules designed for production use. Contains 50+ well-tested, production-ready Terraform modules for managing cloud infrastructure across AWS, Azure, and GCP. All modules are designed to work without requiring cloud credentials during CI/CD testing, making them safe and easy to validate.

**Key Innovation**: Credential-less testing philosophy - all tests run in GitHub Actions without AWS/cloud credentials using mock provider configurations.

## Key Files

| File | Description |
|------|-------------|
| `README.md` | User-facing documentation with quick start guide |
| `AI_README.md` | Comprehensive guide for AI assistants and developers |
| `DOCUMENTATION_GUIDELINES.md` | **CRITICAL** - Ultra-minimal README structure rules (read before writing docs) |
| `LICENSE` | Project license |
| `Makefile` | Local development commands (test, fmt, validate, lint, security) |
| `test-workflow.sh` | Automated test discovery and execution script |
| `.pre-commit-config.yaml` | Git hooks for automated validation |
| `.tflint.hcl` | TFLint configuration with AWS plugin |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `terraform/` | Main module registry with 50+ production-ready modules (see `terraform/AGENTS.md`) |
| `.github/` | CI/CD workflows and GitHub Actions automation (see `.github/AGENTS.md`) |
| `.claude/` | Claude AI configuration and custom skills |

## Architecture Overview

### Repository Statistics
- **Total Directories**: 180+
- **Total Files**: 388
- **Total Terraform Modules**: 50
- **Test Coverage**: 49/50 modules (98%)
- **Directory Depth**: 4 levels

### Module Categories (50 Total)

| Category | Count |
|----------|-------|
| Networking | 7 |
| Compute | 4 |
| ECS Containers | 5 |
| EKS Kubernetes | 7 |
| Load Balancing | 3 |
| Serverless | 3 |
| Databases/Storage | 4 |
| Monitoring/Logging | 4 |
| CI/CD | 2 |
| Messaging | 3 |
| IAM/Security | 3 |
| Multi-Cloud | 4 |
| Composite Stacks | 1 |

## For AI Agents

### Working In This Repository

**Before making ANY changes:**
1. **Read DOCUMENTATION_GUIDELINES.md** - Contains strict README structure rules
2. **Never duplicate code in README** - Reference `tests/` directories instead
3. **Keep README features ≤8 items** - Ultra-minimal documentation philosophy
4. **Tests are the documentation** - All examples live in `tests/` directories

**When adding a new module:**
1. Create standard structure: `main.tf`, `variables.tf`, `outputs.tf`, `README.md`, `tests/basic/main.tf`
2. Follow ultra-minimal README structure from DOCUMENTATION_GUIDELINES.md
3. Add mock provider configuration to test files
4. Run `make test` before committing

**When modifying an existing module:**
1. Read module code + test cases first
2. Make changes and run `terraform fmt -recursive terraform/`
3. Test locally: `make test-module MODULE=<name>`
4. Verify all tests still pass
5. Update README only if inputs/outputs changed

### Testing Requirements

**All tests MUST:**
- Use mock provider configuration (no real AWS credentials)
- Run `terraform plan` successfully
- Be auto-discoverable at `terraform/**/tests/*/main.tf`
- Include realistic values even though resources won't be created

**Local testing commands:**
See `Makefile` for all available commands:
- `make fmt` - Format all Terraform code
- `make test` - Run all checks (fmt, validate, lint, security)
- `make test-module MODULE=<name>` - Test specific module

### Key Patterns

**Mock Provider (required in ALL test files):**
```hcl
provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
  access_key                  = "test"
  secret_key                  = "test"
}
```

**Security defaults:**
- Enable encryption by default where applicable
- Block public access by default for data stores
- Never commit real credentials or sensitive data

**Anti-patterns to avoid:**
- Don't create infrastructure without tests
- Don't write verbose READMEs (see DOCUMENTATION_GUIDELINES.md)
- Don't duplicate code examples in README - reference tests/ instead
- Don't commit without running `make test`

## Dependencies

### Internal
- All modules are self-contained and independently usable
- Composite stacks (in `terraform/stack/`) combine multiple modules
- See individual module READMEs for inter-module dependencies

### External

**Required:**
- Terraform >= 1.0
- Git

**Optional (for local development):**
- pre-commit - Git hook framework
- TFLint - Terraform linter (with AWS plugin)
- trivy - Security scanner
- terraform-docs - Documentation generator

**Installation:**
See `README.md` for installation instructions or run `make install-tools` (macOS).

### Provider Versions
- `hashicorp/aws` ~> 5.0 (primary)
- `hashicorp/azurerm` (for Azure modules)
- `hashicorp/google` (for GCP modules)

## CI/CD Workflows

See `.github/AGENTS.md` for detailed workflow documentation.

**Summary:**
- Terraform format, validate, lint, and security checks on every PR
- Auto-discovers and tests all modules without cloud credentials
- Pre-commit hooks for local validation

## Migration from chatops-platform

This repository consolidates Terraform modules from the `chatops-platform` repository. The workflows and module structure are designed to work identically, with improved auto-discovery and testing capabilities.

<!-- MANUAL: Add any project-specific notes below this line -->
