# ElastiCache Module

A comprehensive Terraform module for creating and managing AWS ElastiCache clusters with support for both Redis and Memcached engines.

## Features

- Multi-Engine Support for both Redis and Memcached with engine-specific optimizations
- High Availability Automatic failover and Multi-AZ support for Redis clusters
- Security At-rest and in-transit encryption with optional auth tokens (Redis)
- Backups Automated snapshots with configurable retention for Redis
- Custom Parameters Flexible parameter group configuration for both engines
- Subnet Groups Automatic subnet group creation or use existing groups
- Logging Optional CloudWatch Logs and Kinesis Firehose integration for Redis
- Maintenance Configurable maintenance windows and auto-upgrade settings

## Quick Start

```hcl
module "elasticache" {
  source = "github.com/llamandcoco/infra-modules//terraform/elasticache?ref=<commit-sha>"

  cluster_id         = "my-redis-cluster"
  engine             = "redis"
  node_type          = "cache.t3.micro"
  subnet_ids         = ["subnet-12345678", "subnet-87654321"]
  security_group_ids = ["sg-12345678"]
}
```

**Note:** Use commit SHA instead of version tags (e.g., `?ref=abc123def`) until a release policy is established.

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|-----------|
| Basic Redis Configuration | [`tests/basic/main.tf`](tests/basic/main.tf) |
| Advanced Redis HA & Memcached | [`tests/advanced/main.tf`](tests/advanced/main.tf) |

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
