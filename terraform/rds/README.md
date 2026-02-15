# RDS Module

A Terraform module for creating and managing AWS RDS database instances with support for multiple database engines, high availability, read replicas, and comprehensive monitoring.

## Features

- Multi-Engine Support for MySQL, PostgreSQL, MariaDB, Oracle, and SQL Server
- High Availability with Multi-AZ deployments and automated failover
- Read Replicas for horizontal scaling of read workloads
- Storage Autoscaling to automatically increase storage capacity as needed
- Security with encryption at rest (KMS), IAM authentication, and security group management
- Monitoring via CloudWatch Logs, Enhanced Monitoring, and Performance Insights
- Automated Backups with configurable retention and point-in-time recovery
- Flexible Storage with support for gp2, gp3, io1, and io2 storage types

## Quick Start

```hcl
module "rds" {
  source = "github.com/llamandcoco/infra-modules//terraform/rds?ref=<commit-sha>"

  identifier        = "myapp-db"
  engine            = "postgres"
  engine_version    = "15.4"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  master_username = "dbadmin"
  master_password = var.db_password

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic MySQL Instance | [`tests/basic/main.tf`](tests/basic/main.tf) |
| Advanced PostgreSQL with Read Replicas | [`tests/advanced/main.tf`](tests/advanced/main.tf) |

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
