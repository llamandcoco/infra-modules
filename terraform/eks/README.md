# EKS Module

Production-ready Terraform module for creating and managing Amazon Elastic Kubernetes Service (EKS) clusters.

## Overview

This module provides a secure-by-default, flexible foundation for deploying EKS clusters. It follows AWS best practices and is designed to integrate seamlessly with other modules in this repository for IAM roles, Karpenter, and EKS add-ons.

### Key Features

- **Secure by default**: Private endpoints, encryption support, comprehensive logging
- **Flexible compute options**: Support for managed node groups, Karpenter-only mode, or both
- **IRSA support**: Optional OIDC provider for IAM Roles for Service Accounts
- **Fine-grained access control**: Support for EKS access entries (AWS Provider v5.x)
- **Production-ready**: Comprehensive logging, encryption, and monitoring capabilities
- **Composable**: Designed to work with terraform/iam/eks/, terraform/karpenter/, and other modules

### What This Module Creates

**Core resources (always created):**
- EKS cluster
- Cluster IAM role with required policies
- CloudWatch log group (if logging enabled)

**Optional resources (controlled by variables):**
- OIDC identity provider (for IRSA)
- Managed node groups
- EKS access entries
- EKS add-ons

### What This Module Does NOT Create

This module intentionally does not create:
- Node IAM roles (use terraform/iam/eks/)
- Karpenter controller IAM roles (use terraform/iam/eks/)
- IRSA workload roles (use terraform/iam/eks/)
- VPC or subnets (use terraform/vpc/)
- Security groups (use terraform/security-group/ or provide existing IDs)

This separation enables better reusability and prevents circular dependencies.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         EKS Cluster                         │
│                     (Control Plane)                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • API Server                                       │   │
│  │  • Controller Manager                               │   │
│  │  • Scheduler                                        │   │
│  │  • etcd                                             │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ (Cluster IAM Role - created by this module)
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
   Managed Node     Managed Node       Karpenter
     Group 1          Group 2        (Optional)
        │                 │                 │
        │                 │                 │
   (Node IAM Role - NOT created by this module)
   (Created in terraform/iam/eks/)
                          │
                          │
                          ▼
              ┌─────────────────────┐
              │   OIDC Provider     │
              │  (Optional, for     │
              │       IRSA)         │
              └─────────────────────┘
                          │
                          │
                          ▼
              ┌─────────────────────┐
              │  Workload IAM Roles │
              │  (Created in        │
              │ terraform/iam/eks/) │
              └─────────────────────┘
```

## Prerequisites

### VPC Requirements

Your VPC subnets must have the following tags for proper EKS integration:

```hcl
# Required for all subnets used by EKS
tags = {
  "kubernetes.io/cluster/${var.cluster_name}" = "shared"
}

# Required for private subnets (for internal load balancers)
tags = {
  "kubernetes.io/role/internal-elb" = "1"
}

# Required for public subnets (for internet-facing load balancers)
tags = {
  "kubernetes.io/role/elb" = "1"
}
```

If using the terraform/vpc/ module, ensure these tags are applied when creating subnets.

### IAM Requirements

If using managed node groups, create the node IAM role separately:

```hcl
module "eks_iam" {
  source = "../iam/eks/"

  cluster_name         = "my-cluster"
  oidc_provider_arn    = module.eks.oidc_provider_arn
  oidc_provider_url    = module.eks.oidc_provider_url
  enable_node_role     = true

  # ... other configuration
}
```

Then reference the role in your node groups:

```hcl
node_groups = {
  default = {
    node_role_arn = module.eks_iam.node_role_arn
    # ... other configuration
  }
}
```

## Usage Examples

### Example 1: Minimal Private Cluster (Karpenter-Ready)

A minimal, secure cluster with no managed node groups. Perfect for use with Karpenter.

```hcl
module "eks" {
  source = "path/to/terraform/eks"

  cluster_name    = "my-cluster"
  cluster_version = "1.30"
  subnet_ids      = module.vpc.private_subnet_ids

  # Security: private endpoint only
  endpoint_private_access = true
  endpoint_public_access  = false

  # Enable OIDC for IRSA (required for Karpenter)
  enable_oidc_provider = true

  # Minimal logging
  cluster_enabled_log_types = ["audit", "authenticator"]

  # No node groups - Karpenter will manage compute
  node_groups = {}

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# Output OIDC provider details for use with terraform/iam/eks/
output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  value = module.eks.oidc_provider_url
}
```

### Example 2: Cluster with Managed Node Groups

A cluster with multiple managed node groups for different workload types.

```hcl
# First, create node IAM role
module "eks_iam" {
  source = "path/to/terraform/iam/eks"

  cluster_name      = "my-cluster"
  enable_node_role  = true

  # Will be set after cluster is created
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
}

# Then, create cluster with node groups
module "eks" {
  source = "path/to/terraform/eks"

  cluster_name    = "my-cluster"
  cluster_version = "1.30"
  subnet_ids      = module.vpc.private_subnet_ids

  endpoint_private_access = true
  endpoint_public_access  = true
  endpoint_public_access_cidrs = ["10.0.0.0/8"] # Your office network

  enable_oidc_provider = true

  # Comprehensive logging for production
  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  # Multiple node groups with different configurations
  node_groups = {
    # General purpose on-demand nodes
    general = {
      node_role_arn  = module.eks_iam.node_role_arn
      subnet_ids     = module.vpc.private_subnet_ids

      desired_size   = 2
      max_size       = 10
      min_size       = 1

      instance_types = ["t3.large"]
      capacity_type  = "ON_DEMAND"

      labels = {
        workload-type = "general"
      }
    }

    # Spot instances for batch workloads
    spot = {
      node_role_arn  = module.eks_iam.node_role_arn
      subnet_ids     = module.vpc.private_subnet_ids

      desired_size   = 0
      max_size       = 20
      min_size       = 0

      instance_types = ["t3.large", "t3.xlarge", "t3a.large"]
      capacity_type  = "SPOT"

      labels = {
        workload-type = "batch"
      }

      taints = [
        {
          key    = "spot"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### Example 3: Highly Secure Cluster with Encryption

A production cluster with all security features enabled.

```hcl
# Create KMS key for secrets encryption
resource "aws_kms_key" "eks" {
  description             = "EKS cluster encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_kms_key" "cloudwatch" {
  description             = "CloudWatch logs encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

module "eks" {
  source = "path/to/terraform/eks"

  cluster_name    = "secure-cluster"
  cluster_version = "1.30"
  subnet_ids      = module.vpc.private_subnet_ids

  # Strictly private endpoint
  endpoint_private_access = true
  endpoint_public_access  = false

  # Enable OIDC for IRSA
  enable_oidc_provider = true

  # Encrypt Kubernetes secrets at rest
  encryption_config_kms_key_arn = aws_kms_key.eks.arn

  # Full logging with encryption
  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
  cloudwatch_log_retention_days = 365
  cloudwatch_log_kms_key_id     = aws_kms_key.cloudwatch.arn

  # Use API-only authentication (no ConfigMap)
  authentication_mode = "API"
  bootstrap_cluster_creator_admin_permissions = false

  # Fine-grained access control
  access_entries = {
    admin = {
      principal_arn = aws_iam_role.eks_admin.arn
      access_policies = [
        {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      ]
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Compliance  = "pci-dss"
  }
}
```

### Example 4: Cluster with Add-ons

A cluster with essential EKS add-ons configured.

```hcl
module "eks_iam" {
  source = "path/to/terraform/iam/eks"

  cluster_name      = "my-cluster"
  enable_node_role  = true
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url

  # Create IRSA role for EBS CSI driver
  enable_ebs_csi_driver_role = true
}

module "eks" {
  source = "path/to/terraform/eks"

  cluster_name    = "my-cluster"
  cluster_version = "1.30"
  subnet_ids      = module.vpc.private_subnet_ids

  enable_oidc_provider = true

  # Configure essential add-ons
  cluster_addons = {
    vpc-cni = {
      addon_version = "v1.16.0-eksbuild.1"
    }
    kube-proxy = {
      addon_version = "v1.29.0-eksbuild.1"
    }
    coredns = {
      addon_version = "v1.11.1-eksbuild.4"
    }
    aws-ebs-csi-driver = {
      addon_version            = "v1.26.1-eksbuild.1"
      service_account_role_arn = module.eks_iam.ebs_csi_driver_role_arn
    }
  }

  node_groups = {
    default = {
      node_role_arn = module.eks_iam.node_role_arn
      subnet_ids    = module.vpc.private_subnet_ids
      desired_size  = 2
      max_size      = 4
      min_size      = 1
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### Example 5: Integration with Other Modules

Complete example showing integration with VPC, IAM, and Karpenter modules.

```hcl
# 1. VPC
module "vpc" {
  source = "path/to/terraform/vpc"

  vpc_name = "my-vpc"
  vpc_cidr = "10.0.0.0/16"

  # EKS requires subnets in at least 2 AZs
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  # Add required EKS tags to subnets
  private_subnet_tags = {
    "kubernetes.io/cluster/my-cluster" = "shared"
    "kubernetes.io/role/internal-elb"  = "1"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/my-cluster" = "shared"
    "kubernetes.io/role/elb"           = "1"
  }
}

# 2. EKS Cluster
module "eks" {
  source = "path/to/terraform/eks"

  cluster_name    = "my-cluster"
  cluster_version = "1.30"
  subnet_ids      = module.vpc.private_subnet_ids

  endpoint_private_access = true
  endpoint_public_access  = false

  enable_oidc_provider = true

  # No managed node groups - Karpenter will manage compute
  node_groups = {}

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# 3. IAM Roles (node role, Karpenter role, IRSA workload roles)
module "eks_iam" {
  source = "path/to/terraform/iam/eks"

  cluster_name      = "my-cluster"
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url

  # Enable Karpenter controller IAM role
  enable_karpenter_controller_role = true

  # Enable node IAM role (for Karpenter-managed nodes)
  enable_node_role = true

  # Enable IRSA roles for workloads
  enable_ebs_csi_driver_role = true
  enable_cluster_autoscaler_role = true
}

# 4. Karpenter (optional)
module "karpenter" {
  source = "path/to/terraform/karpenter"

  cluster_name              = module.eks.cluster_name
  cluster_endpoint          = module.eks.cluster_endpoint
  karpenter_controller_role_arn = module.eks_iam.karpenter_controller_role_arn
  node_iam_role_name        = module.eks_iam.node_role_name

  depends_on = [module.eks]
}

# Outputs for reference
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region us-east-1"
}
```

## Security Considerations

### Private vs. Public Endpoints

- **Private endpoint (recommended)**: Kubernetes API is only accessible from within your VPC
  - Set `endpoint_private_access = true` and `endpoint_public_access = false`
  - Access cluster via bastion host, VPN, or AWS VPN/Direct Connect
  - Most secure option for production workloads

- **Public endpoint**: Kubernetes API is accessible from the internet
  - Only enable if necessary (CI/CD pipelines, external access)
  - ALWAYS restrict access using `endpoint_public_access_cidrs`
  - Never use `["0.0.0.0/0"]` in production

### Encryption

- **Secrets encryption**: Enable `encryption_config_kms_key_arn` to encrypt Kubernetes secrets at rest
  - Can only be enabled at cluster creation (cannot be added later)
  - Required for many compliance frameworks (PCI DSS, HIPAA)

- **CloudWatch logs encryption**: Enable `cloudwatch_log_kms_key_id` to encrypt control plane logs

### Logging

Enable appropriate log types based on your security and compliance requirements:
- `audit`: Kubernetes audit logs (required for compliance)
- `authenticator`: Authentication attempts (useful for security monitoring)
- `api`: API server requests (useful for troubleshooting)
- `controllerManager`: Controller manager logs
- `scheduler`: Scheduler logs

### Authentication

- **API mode (recommended for new clusters)**: Use EKS access entries for fine-grained access control
  - Set `authentication_mode = "API"`
  - Configure `access_entries` for IAM principals

- **ConfigMap mode (legacy)**: Uses aws-auth ConfigMap
  - Not recommended for new clusters
  - More difficult to manage at scale

### IAM Roles for Service Accounts (IRSA)

Enable OIDC provider to use IRSA:
- Set `enable_oidc_provider = true`
- Create IAM roles in terraform/iam/eks/ that trust the OIDC provider
- Annotate Kubernetes service accounts with IAM role ARN
- More secure than using node IAM roles or embedding credentials

## Testing

### Running Tests

```bash
cd tests/basic
terraform init -backend=false
terraform plan
```

The test configuration includes:
1. Minimal private cluster (Karpenter-ready)
2. Cluster with managed node groups
3. Highly secure cluster with encryption
4. Cluster with add-ons
5. Cluster with mixed authentication mode

All tests use mock AWS credentials and can run without real AWS access.

## Module Outputs

Key outputs from this module:

- `cluster_endpoint`: Kubernetes API endpoint
- `cluster_name`: Cluster name
- `cluster_certificate_authority_data`: Base64-encoded CA certificate
- `oidc_provider_arn`: OIDC provider ARN (for terraform/iam/eks/)
- `oidc_provider_url`: OIDC provider URL (for terraform/iam/eks/)
- `cluster_security_group_id`: Cluster security group ID
- `node_groups`: Map of node group attributes

See outputs.tf for complete list.

## Integration with Other Modules

This module is designed to work with:

- **terraform/vpc/**: VPC and subnet creation with proper EKS tags
- **terraform/security-group/**: Custom security groups for cluster
- **terraform/iam/eks/**: IAM roles for nodes, Karpenter, and IRSA workloads
- **terraform/karpenter/**: Karpenter installation and configuration
- **terraform/eks-addons/**: Additional Kubernetes add-ons (ALB controller, external-dns, etc.)

## Upgrading

### Cluster Version Upgrades

1. Update `cluster_version` variable
2. Apply Terraform changes (control plane upgrades automatically)
3. Update node groups to match (set `kubernetes_version` in node_groups)
4. Update add-ons to compatible versions
5. Test workloads thoroughly

### Add-on Upgrades

1. Check compatibility with cluster version
2. Update `addon_version` in `cluster_addons`
3. Apply Terraform changes
4. Monitor add-on status via outputs

## Troubleshooting

### Cannot access cluster API

- Check endpoint access settings (`endpoint_private_access`, `endpoint_public_access`)
- Verify security group rules
- Check `endpoint_public_access_cidrs` if using public endpoint
- Verify IAM permissions for cluster access

### Node groups not joining cluster

- Verify node IAM role has required policies (AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy, AmazonEC2ContainerRegistryReadOnly)
- Check subnet tags (kubernetes.io/cluster/CLUSTER_NAME = shared)
- Verify security group rules
- Check CloudWatch logs for node bootstrap errors

### IRSA not working

- Verify `enable_oidc_provider = true`
- Check IAM role trust policy references correct OIDC provider
- Verify service account annotation (eks.amazonaws.com/role-arn)
- Check IAM role permissions

## Contributing

This module serves as a reference implementation for other Terraform modules in this repository. When making changes:

1. Follow the established patterns from terraform/ecr/ and terraform/parameter_store/
2. Add comprehensive variable descriptions
3. Include validation blocks where appropriate
4. Update tests in tests/basic/
5. Update this README with examples

## License

See repository LICENSE file.
