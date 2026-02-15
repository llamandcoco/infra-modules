# AmazonMQ Module

A production-ready Terraform module for creating and managing AWS AmazonMQ message brokers with support for ActiveMQ and RabbitMQ engines, high availability deployments, KMS encryption, and CloudWatch logging.

## Features

- Multiple Engines Support for both ActiveMQ and RabbitMQ message brokers
- High Availability SINGLE_INSTANCE, ACTIVE_STANDBY_MULTI_AZ, and CLUSTER_MULTI_AZ deployment modes
- Security KMS encryption, VPC isolation, security groups, and LDAP authentication (ActiveMQ)
- Monitoring CloudWatch Logs integration for general and audit logs
- Storage Options EBS or EFS storage with configurable capacity
- Custom Configurations Support for broker-specific XML configurations
- Maintenance Windows Configurable maintenance windows with auto minor version upgrades
- Multi-User Support Multiple broker users with role-based access

## Quick Start

```hcl
module "amazonmq" {
  source = "github.com/llamandcoco/infra-modules//terraform/amazonmq?ref=<commit-sha>"

  broker_name        = "my-broker"
  engine_type        = "ActiveMQ"
  engine_version     = "5.18.3"
  host_instance_type = "mq.m5.large"

  subnet_ids      = ["subnet-12345678"]
  security_groups = ["sg-12345678"]

  users = [
    {
      username       = "admin"
      password       = "SecurePassword123!"
      console_access = true
    }
  ]
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic | [`tests/basic/main.tf`](tests/basic/main.tf) |

**Usage:**
```bash
# View example
cat tests/basic/

# Copy and adapt
cp -r tests/basic/ my-project/
```

## Testing

```bash
cd tests/basic && terraform init && terraform plan
```

<details>
<summary>Terraform Documentation</summary>

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
</details>
