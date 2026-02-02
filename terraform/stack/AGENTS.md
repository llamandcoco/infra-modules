<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-01-31 18:39:36 | Updated: 2026-01-31 18:39:36 -->

# stack/

## Purpose

Composite Terraform modules that combine multiple individual modules to create complete, opinionated infrastructure stacks. Stacks reduce boilerplate by bundling commonly-used module combinations with sensible defaults while allowing customization.

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `audit-logging/` | Complete audit logging stack with CloudTrail, S3, and monitoring |
| `networking/` | Complete VPC networking stack with subnets, gateways, and routing |

## For AI Agents

### When to Use

**Use stacks when:**
- Deploying standard infrastructure patterns (VPC, audit logging, etc.)
- Following organizational standards across environments
- Rapid prototyping or reducing boilerplate

**Use individual modules when:**
- Need fine-grained control or custom configurations
- Integrating with existing infrastructure
- Specific requirements not covered by stack defaults

### Testing Requirements

- Test interaction between multiple modules (not just individual resources)
- Validate outputs from one module correctly feed inputs to another
- Use realistic scenarios (e.g., full VPC setup, not single subnet)
- Use mock provider configuration with skip flags (same as individual modules)

### Dependencies

**audit-logging/ uses:**
- `terraform/cloudtrail/` - CloudTrail configuration
- `terraform/s3/` - S3 bucket for log storage
- `terraform/cloudwatch-alarm/` - Monitoring and alerting

**networking/ uses:**
- `terraform/vpc/` - Virtual Private Cloud
- `terraform/subnet/` - Subnet creation
- `terraform/internet-gateway/` - Internet Gateway
- `terraform/nat-gateway/` - NAT Gateway
- `terraform/route-table/` - Route tables
- `terraform/security-group/` - Security groups

### Stack Details

| Stack | Combines | Use For |
|-------|----------|---------|
| `audit-logging/` | CloudTrail + S3 + CloudWatch + IAM | Compliance and security monitoring |
| `networking/` | VPC + Subnets + IGW + NAT + Routes + Security Groups | Complete networking foundation |

**Note:** Read stack code in subdirectories for implementation details, variable patterns, and outputs.

<!-- MANUAL: Add stack-specific notes below this line -->
