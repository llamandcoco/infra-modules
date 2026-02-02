<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-01-31 18:39:36 | Updated: 2026-01-31 18:39:36 -->

# .github/

## Purpose

GitHub Actions workflows and automation for continuous integration, testing, and quality assurance of Terraform modules. All workflows are designed to run without requiring cloud credentials using mock provider configurations.

## Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `terraform-check.yml` | PR/push to main (`terraform/**`) | Format, validate, lint (TFLint), and security scan (Trivy). Posts aggregated results to PR. |
| `terraform-module-tests.yml` | PR/push to main (`terraform/**`) | Auto-discovers tests at `terraform/**/tests/*/main.tf`, runs `terraform plan` on each in parallel. |
| `terraform-fmt-fix.yml` | Manual dispatch | Runs `terraform fmt -recursive` and commits formatting fixes. |

### Execution Strategy

- **Format/Validate**: All modules (fast, ensures consistency)
- **Lint/Security**: Changed modules only (slower tools)
- **Tests**: All discovered tests (parallel execution)

## For AI Agents

### When to Modify Workflows

- Adding validation tools (Checkov, Infracost, etc.)
- Changing required vs optional checks
- Modifying PR comment format
- Adding test discovery patterns

### Key Constraints

1. **Never require cloud credentials** - Use mock providers with skip flags
2. **Keep workflows fast** - Target <5 minutes
3. **Fail appropriately** - Decide if errors block PR or warn
4. **Test in PR first** - Validate workflow changes before merging

### Key Variables

- `paths: ['terraform/**']` - Only trigger on Terraform file changes
- `terraform init -backend=false` - No backend required
- `fail-fast: false` - See all test results
- `permissions.pull-requests: write` - Required for PR comments

### Test Discovery Pattern

Tests auto-discovered via: `find terraform -type f -name "main.tf" -path "*/tests/*"`

No manual configuration needed when adding new test cases.

## Dependencies

| Tool | Purpose | Installation |
|------|---------|--------------|
| Terraform | IaC execution | `hashicorp/setup-terraform@v3` |
| TFLint | Linting | curl download |
| Trivy | Security scanning | `aquasecurity/trivy-action` |

**GitHub Actions:**
- `actions/checkout@v4` - Repository checkout
- `actions/github-script@v7` - PR comment posting

## Key Files

| File | Description |
|------|-------------|
| `CODEOWNERS` | Code ownership rules (if exists) |
| `dependabot.yml` | Dependency updates (if exists) |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `workflows/` | GitHub Actions workflow definitions |

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "No valid credential sources" | Ensure mock provider with skip flags in test |
| "Backend initialization required" | Use `terraform init -backend=false` |
| PR comment not posted | Verify `pull-requests: write` permission |
| TFLint failures | Check `.tflint.hcl` config |

**Typical run times:**
- terraform-check: 2-4 min
- terraform-module-tests: 3-8 min
- terraform-fmt-fix: 1-2 min

<!-- MANUAL: Add workflow-specific notes below this line -->
