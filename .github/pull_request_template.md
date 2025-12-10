## Description

<!-- Provide a brief description of the changes in this PR -->

## Type of Change

- [ ] New module
- [ ] Module enhancement
- [ ] Bug fix
- [ ] Documentation update
- [ ] CI/CD workflow improvement
- [ ] Other (please describe):

## Checklist

### Code Quality

- [ ] Code follows the repository's style guidelines
- [ ] `terraform fmt` has been run on all changed files
- [ ] All new code has been documented (variables, outputs, README)
- [ ] Module README includes usage examples

### Testing

- [ ] At least one test case has been added in `tests/` directory
- [ ] Tests use mock provider configuration (no real credentials required)
- [ ] Local testing completed successfully:
  - [ ] `terraform init -backend=false`
  - [ ] `terraform validate`
  - [ ] `terraform plan`

### Security

- [ ] trivy scan passes without critical issues
- [ ] No sensitive data (credentials, keys, etc.) included
- [ ] Security best practices followed (encryption enabled, public access blocked, etc.)

### Documentation

- [ ] Module variables are documented with descriptions and types
- [ ] Module outputs are documented with descriptions
- [ ] README.md updated with module usage and examples
- [ ] Breaking changes are clearly documented (if applicable)

## Module Information

<!-- If this is a new or updated module, provide details -->

**Module Name:** `terraform/___________`

**Purpose:**
<!-- What does this module do? -->

**Resources Created:**
<!-- List the main AWS/cloud resources this module manages -->

-

## Testing Evidence

<!-- Paste the output of your local testing -->

<details>
<summary>terraform plan output</summary>

```
# Paste terraform plan output here
```

</details>

## Additional Notes

<!-- Any additional information that reviewers should know -->

## Related Issues

<!-- Link to any related issues -->

Closes #
