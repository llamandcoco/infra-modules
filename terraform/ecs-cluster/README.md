# ECS Cluster Module

This module creates a **shared ECS cluster** that can host multiple services.

## What is an ECS Cluster?

An ECS cluster is a logical grouping of tasks or services. Think of it as a container for your services:
- ✅ **One cluster** can host **many services**
- ✅ **Free** - No charge for the cluster itself
- ✅ **Shared** - All services in the same cluster can share capacity and insights

## When to Use This Module

Use this module to create a cluster that will be shared across multiple services:
- Microservices architecture (API, worker, scheduler all in one cluster)
- Different environments (dev-cluster, staging-cluster, prod-cluster)
- Team boundaries (frontend-cluster, backend-cluster)

## Usage

### Basic Example

```hcl
module "cluster" {
  source = "../../terraform/ecs-cluster"

  name = "production"

  tags = {
    Environment = "production"
  }
}
```

### Example with Container Insights Disabled

```hcl
module "cluster" {
  source = "../../terraform/ecs-cluster"

  name = "development"

  enable_container_insights = false  # Reduce costs in dev

  tags = {
    Environment = "development"
  }
}
```

### Example with Capacity Providers

```hcl
module "cluster" {
  source = "../../terraform/ecs-cluster"

  name = "production"

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 4
      base              = 2
    },
    {
      capacity_provider = "FARGATE"
      weight            = 1
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

## Complete Stack Example

```hcl
# Step 1: Create shared cluster
module "cluster" {
  source = "../../terraform/ecs-cluster"
  name   = "production"
}

# Step 2: Deploy multiple services to the cluster
module "api_service" {
  source = "../../terraform/ecs-service"

  cluster_id   = module.cluster.cluster_id
  service_name = "api"

  container_image = "myapp/api:latest"
  container_port  = 8080

  subnet_ids         = var.private_subnet_ids
  security_group_ids = [var.app_sg_id]
  target_group_arn   = var.api_tg_arn

  execution_role_arn = module.execution_role.role_arn
}

module "worker_service" {
  source = "../../terraform/ecs-service"

  cluster_id   = module.cluster.cluster_id
  service_name = "worker"

  container_image = "myapp/worker:latest"
  container_port  = 8080

  subnet_ids         = var.private_subnet_ids
  security_group_ids = [var.worker_sg_id]
  target_group_arn   = var.worker_tg_arn

  execution_role_arn = module.execution_role.role_arn
}
```

## Cluster vs Service

| Resource | Created | Shared | Purpose |
|----------|---------|--------|---------|
| **Cluster** | Once | ✅ Yes | Logical grouping |
| **Service** | Many | ❌ No | Application deployment |

Think of it like:
- **Cluster** = Kubernetes Namespace (logical boundary)
- **Service** = Kubernetes Deployment (actual workload)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the ECS cluster | `string` | n/a | yes |
| enable_container_insights | Enable CloudWatch Container Insights for the cluster | `bool` | `true` | no |
| capacity_providers | List of capacity providers (e.g., FARGATE, FARGATE_SPOT) | `list(string)` | `["FARGATE", "FARGATE_SPOT"]` | no |
| default_capacity_provider_strategy | Default capacity provider strategy | `list(object)` | `[]` | no |
| tags | Tags to apply to the cluster | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | ID of the ECS cluster |
| cluster_arn | ARN of the ECS cluster |
| cluster_name | Name of the ECS cluster |

## Best Practices

1. **One cluster per environment** - Create separate clusters for dev, staging, prod
2. **Enable Container Insights in production** - Provides detailed metrics
3. **Use Fargate Spot for cost savings** - Can reduce costs by up to 70%
4. **Tag your clusters** - Essential for cost tracking and automation

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.28.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_capacity_providers"></a> [capacity\_providers](#input\_capacity\_providers) | List of capacity providers to associate with the cluster (e.g., FARGATE, FARGATE\_SPOT) | `list(string)` | <pre>[<br/>  "FARGATE",<br/>  "FARGATE_SPOT"<br/>]</pre> | no |
| <a name="input_default_capacity_provider_strategy"></a> [default\_capacity\_provider\_strategy](#input\_default\_capacity\_provider\_strategy) | Default capacity provider strategy for the cluster | <pre>list(object({<br/>    capacity_provider = string<br/>    weight            = optional(number)<br/>    base              = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_container_insights"></a> [enable\_container\_insights](#input\_enable\_container\_insights) | Enable CloudWatch Container Insights for the cluster | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the ECS cluster | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the cluster | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | ARN of the ECS cluster |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | ID of the ECS cluster |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the ECS cluster |
<!-- END_TF_DOCS -->
