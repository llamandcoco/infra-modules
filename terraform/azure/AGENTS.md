<!-- Parent: ../AGENTS.md -->

# azure/

## Purpose

Azure-specific Terraform modules placeholder directory. Currently minimal - intended for future Azure resource modules following the same structure and conventions as AWS modules.

## Key Files

Currently minimal structure. Future modules will follow the standard pattern:
- `main.tf` - Resource definitions
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `README.md` - Documentation

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `tests/` | Test configurations |
| `tests/basic/` | Basic Azure resource examples |

## For AI Agents

### Working In This Directory

**Module Type:** Multi-Cloud / Azure

**Current Status:**
This directory is a placeholder for future Azure modules. The repository currently focuses on AWS modules but follows a cloud-agnostic structure that can accommodate Azure and GCP modules.

**When Adding Azure Modules:**

1. **Follow AWS Module Patterns:**
   - Same directory structure (main.tf, variables.tf, outputs.tf, README.md)
   - Same testing approach (tests/basic/ etc.)
   - Same documentation style (ultra-minimal, reference tests/)

2. **Provider Configuration (Mock):**
```hcl
provider "azurerm" {
  features {}
  skip_provider_registration = true
}
```

3. **Common Azure Resources to Modularize:**
   - Virtual Networks (VNet) and Subnets
   - Azure Kubernetes Service (AKS)
   - Azure Storage Accounts
   - Azure SQL Database

4. **Naming Conventions:**
   - Use Azure-specific naming: `azurerm_resource_type`
   - Use tags for resource organization

**Security Best Practices for Azure:**
- Use Managed Identities instead of service principals
- Enable encryption at rest and in transit
- Use Azure Key Vault for secrets management

**Testing Strategy:**
- Follow same mock provider approach as AWS modules
- Use `terraform plan` for validation without actual Azure credentials
- CI/CD pipeline should support multi-cloud testing

### Future Enhancements

When expanding Azure support:
1. Create module subdirectories following AWS pattern
2. Add AGENTS.md for each Azure module
3. Update parent ../AGENTS.md with Azure module inventory
4. Ensure cross-cloud consistency in variable naming and structure
5. Document cloud-specific differences clearly

## Dependencies

### Internal
- None currently (placeholder directory)
- Future: Will integrate with parent terraform/ structure

### External
- Terraform >= 1.0 (when modules are added)
- hashicorp/azurerm provider ~> 3.0 (when modules are added)
