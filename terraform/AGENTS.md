<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-01-31 18:39:36 | Updated: 2026-01-31 18:39:36 -->

# terraform/

## Purpose

Main Terraform module registry containing 50 production-ready, reusable infrastructure modules for AWS, Azure, and GCP. Each module follows a standardized structure with comprehensive testing and documentation. All modules support credential-less testing using mock provider configurations.

## Key Files

| File | Description |
|------|-------------|
| `.tflint.hcl` | TFLint configuration with AWS plugin rules |
| `.trivy.yaml` | Trivy security scanner configuration |

## Module Inventory (50 Modules)

### Networking (7 modules)
| Module | Purpose |
|--------|---------|
| `vpc/` | Virtual Private Cloud with configurable CIDR and DNS settings |
| `subnet/` | Public/private subnets with availability zone support |
| `internet-gateway/` | Internet Gateway for VPC internet access |
| `nat-gateway/` | NAT Gateway for private subnet outbound traffic |
| `route-table/` | Route tables with customizable routes |
| `security-group/` | Security group with ingress/egress rules |
| `security-groups/` | Multiple security groups management |

### Compute (4 modules)
| Module | Purpose |
|--------|---------|
| `ec2/` | EC2 instances with user data and advanced configurations |
| `autoscaling/` | Auto Scaling Groups with launch templates |
| `instance-profile/` | IAM instance profiles for EC2 |
| `key-pair/` | EC2 key pairs for SSH access |

### ECS Containers (5 modules)
| Module | Purpose |
|--------|---------|
| `ecs-cluster/` | ECS cluster with container insights |
| `ecs-service/` | ECS Fargate/EC2 services with load balancer integration |
| `ecs-execution-role/` | IAM role for ECS task execution |
| `ecs-task-role/` | IAM role for ECS tasks |
| `ecr/` | Elastic Container Registry for Docker images |

### EKS Kubernetes (7 modules)
| Module | Purpose |
|--------|---------|
| `eks/` | Elastic Kubernetes Service cluster |
| `eks-node-role/` | IAM role for EKS worker nodes |
| `eks-app-deployment/` | Kubernetes deployments and services |
| `eks-argocd/` | ArgoCD GitOps deployment on EKS |
| `eks-karpenter/` | Karpenter autoscaler for EKS |
| `eks-keda/` | KEDA event-driven autoscaling |
| `eks-lb-controller/` | AWS Load Balancer Controller for EKS |

### Load Balancing (3 modules)
| Module | Purpose |
|--------|---------|
| `alb/` | Application Load Balancer with listeners |
| `alb-target-group/` | ALB target groups for routing |
| `aws-lb-controller-role/` | IAM role for AWS Load Balancer Controller |

### Serverless (3 modules)
| Module | Purpose |
|--------|---------|
| `lambda/` | Lambda functions with configurable runtime and triggers |
| `api-gateway/` | API Gateway REST/HTTP APIs |
| `cloudfront/` | CloudFront CDN distributions |

### Databases/Storage (4 modules)
| Module | Purpose |
|--------|---------|
| `s3/` | S3 buckets with encryption and versioning |
| `dynamodb/` | DynamoDB tables with autoscaling |
| `parameter-store/` | SSM Parameter Store parameters |
| `cloudtrail/` | CloudTrail audit logging |

### Monitoring/Logging (4 modules)
| Module | Purpose |
|--------|---------|
| `cloudwatch-alarm/` | CloudWatch alarms for monitoring |
| `cloudwatch-dashboard/` | CloudWatch dashboards for visualization |
| `aws_config/` | AWS Config for compliance monitoring |
| `cloudtrail/` | CloudTrail for API activity logging |

### CI/CD (2 modules)
| Module | Purpose |
|--------|---------|
| `codebuild/` | CodeBuild projects for building applications |
| `codepipeline/` | CodePipeline for CI/CD workflows |

### Messaging (3 modules)
| Module | Purpose |
|--------|---------|
| `eventbridge/` | EventBridge rules and targets for event routing |
| `sqs/` | SQS queues with dead-letter queue support |
| `cloudtrail/` | CloudTrail event logging |

### IAM/Security (3 modules)
| Module | Purpose |
|--------|---------|
| `oidc/` | OIDC identity provider for GitHub Actions |
| `scp/` | Service Control Policies for AWS Organizations |
| `keda-iam-role/` | IAM role for KEDA autoscaling |

### AI/ML (1 module)
| Module | Purpose |
|--------|---------|
| `bedrock/` | Amazon Bedrock for generative AI |

### Utilities (2 modules)
| Module | Purpose |
|--------|---------|
| `ssm-config-reader/` | Read SSM parameters for configuration |
| `keda-scaledobject/` | KEDA ScaledObject for autoscaling |

### Templates (1 module)
| Module | Purpose |
|--------|---------|
| `_template/` | Template for creating new modules |

## Subdirectories (Special Categories)

| Directory | Purpose |
|-----------|---------|
| `stack/` | Composite modules combining multiple resources (see `stack/AGENTS.md`) |
| `azure/` | Azure cloud modules (see `azure/AGENTS.md`) |
| `gcp/` | Google Cloud Platform modules (see `gcp/AGENTS.md`) |

## For AI Agents

### Working In This Directory

**Standard Module Structure (ALL modules follow this):**
```
module-name/
├── main.tf                  # Resource definitions only
├── variables.tf             # Input variables with type, description, validation
├── outputs.tf               # Output values with descriptions
├── README.md                # Ultra-minimal user documentation
├── .terraform.lock.hcl      # Dependency lock file
└── tests/
    ├── basic/               # Minimal working example (REQUIRED)
    │   └── main.tf
    ├── advanced/            # Advanced features (optional)
    │   └── main.tf
    └── with_*/              # Feature-specific tests (optional)
        └── main.tf
```

**When adding a new module:**
1. Copy `_template/` directory: `cp -r _template/ new-module/`
2. Edit `main.tf` with resource definitions
3. Define variables in `variables.tf` (include type, description, validation)
4. Add outputs to `outputs.tf` (include descriptions)
5. Update `README.md` following DOCUMENTATION_GUIDELINES.md
6. Create `tests/basic/main.tf` with mock provider config
7. Test locally: `cd tests/basic && terraform init -backend=false && terraform plan`
8. Run `make test-module MODULE=new-module` from repository root

**When modifying a module:**
1. Read existing code and test cases first
2. Make changes to `.tf` files
3. Update tests if behavior changes
4. Update README.md only if inputs/outputs changed
5. Run `terraform fmt -recursive .` in module directory
6. Test locally: `cd tests/basic && terraform init -backend=false && terraform plan`
7. Run `make test-module MODULE=module-name` from repository root

**Documentation rules (CRITICAL - Read DOCUMENTATION_GUIDELINES.md):**
- ❌ **Never** duplicate code in README
- ✅ **Always** reference `tests/` directories for examples
- ✅ Keep feature list ≤8 items
- ✅ Use ultra-minimal structure
- ✅ Run `terraform-docs` to auto-generate inputs/outputs section

### Testing Requirements

**Mock Provider Configuration (REQUIRED in ALL test files):**
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
  access_key                  = "test"
  secret_key                  = "test"
}

module "test" {
  source = "../../"

  # Add test configuration here
}
```

**Test discovery:**
- All tests at `terraform/**/tests/*/main.tf` are auto-discovered
- GitHub Actions runs `terraform plan` for each test
- No actual resources are created (mock provider)

**Local testing:**
```bash
# From repository root
make test-module MODULE=s3

# Manual testing
cd terraform/s3/tests/basic
terraform init -backend=false
terraform plan
```

### Common Patterns

**Variable Validation:**
```hcl
variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}
```

**Output Naming:**
```hcl
output "resource_id" {
  description = "The ID of the created resource"
  value       = aws_resource.this.id
}

output "resource_arn" {
  description = "The ARN of the created resource"
  value       = aws_resource.this.arn
}
```

**Security Defaults:**
```hcl
# Enable encryption by default
variable "encryption_enabled" {
  type        = bool
  description = "Enable encryption at rest"
  default     = true
}

# Block public access by default
variable "block_public_access" {
  type        = bool
  description = "Block all public access"
  default     = true
}
```

**Tags:**
```hcl
variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}

resource "aws_resource" "this" {
  # ... other configuration ...

  tags = merge(
    var.tags,
    {
      ManagedBy = "Terraform"
    }
  )
}
```

## Dependencies

### Internal
- Modules are designed to be independently usable
- Some modules reference IAM roles from other modules (documented in module README)
- Composite stacks (`stack/`) combine multiple modules

### External

**Provider Requirements:**
- `hashicorp/aws` ~> 5.0 (primary provider for AWS modules)
- `hashicorp/azurerm` (for Azure modules in `azure/`)
- `hashicorp/google` (for GCP modules in `gcp/`)

**Terraform Version:**
- Terraform >= 1.0 (required for all modules)

**Development Tools:**
- TFLint - Linter with AWS plugin
- Trivy - Security scanner
- terraform-docs - Documentation generator

## Test Coverage Statistics

- **Total Modules**: 50
- **Modules with Tests**: 49
- **Test Coverage**: 98%
- **Total Test Cases**: ~150 across all modules

**Most Tested Modules:**
- `alb/` - 5 test scenarios
- `lambda/` - 5 test scenarios
- `ec2/` - 5 test scenarios
- `eventbridge/` - 4 test scenarios

## Module Usage Example

```hcl
# In your infrastructure code
module "s3_bucket" {
  source = "github.com/llamandcoco/infra-modules//terraform/s3?ref=<commit-sha>"

  bucket_name = "my-application-bucket"
  environment = "prod"

  tags = {
    Application = "MyApp"
    CostCenter  = "Engineering"
  }
}
```

<!-- MANUAL: Add any Terraform-specific notes below this line -->
