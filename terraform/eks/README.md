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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.26.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_eks_access_entry.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry) | resource |
| [aws_eks_access_policy_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_policy_association) | resource |
| [aws_eks_addon.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_node_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_openid_connect_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cluster_eks_cluster_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cluster_eks_vpc_resource_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.cluster_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [tls_certificate.cluster](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_entries"></a> [access\_entries](#input\_access\_entries) | Map of EKS access entries for granting IAM principals access to the cluster. Only used when authentication\_mode is "API" or "API\_AND\_CONFIG\_MAP".<br/><br/>Access entries provide fine-grained access control and are the recommended method for managing cluster access.<br/><br/>Each entry includes:<br/>- principal\_arn: ARN of the IAM user, role, or federated user<br/>- kubernetes\_groups: List of Kubernetes groups to add the principal to (optional)<br/>- type: Access entry type - "STANDARD", "FARGATE\_LINUX", or "EC2\_LINUX" (default: "STANDARD")<br/>- access\_policies: List of AWS managed access policies to associate (optional)<br/>  - policy\_arn: ARN of the access policy (e.g., "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy")<br/>  - access\_scope:<br/>    - type: "cluster" or "namespace"<br/>    - namespaces: List of namespaces (only for type = "namespace")<br/><br/>Available AWS managed access policies:<br/>- AmazonEKSClusterAdminPolicy: Full admin access to cluster<br/>- AmazonEKSAdminPolicy: Admin access within specified namespace(s)<br/>- AmazonEKSEditPolicy: Edit resources within specified namespace(s)<br/>- AmazonEKSViewPolicy: Read-only access within specified namespace(s)<br/><br/>Example:<br/>access\_entries = {<br/>  admin = {<br/>    principal\_arn     = "arn:aws:iam::123456789012:role/EKSAdminRole"<br/>    kubernetes\_groups = ["system:masters"]<br/>    access\_policies = [<br/>      {<br/>        policy\_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"<br/>        access\_scope = {<br/>          type = "cluster"<br/>        }<br/>      }<br/>    ]<br/>  }<br/>  developer = {<br/>    principal\_arn = "arn:aws:iam::123456789012:role/EKSDeveloperRole"<br/>    access\_policies = [<br/>      {<br/>        policy\_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"<br/>        access\_scope = {<br/>          type       = "namespace"<br/>          namespaces = ["default", "development"]<br/>        }<br/>      }<br/>    ]<br/>  }<br/>}<br/><br/>Default: {} (no additional access entries) | <pre>map(object({<br/>    principal_arn     = string<br/>    kubernetes_groups = optional(list(string))<br/>    type              = optional(string)<br/>    access_policies = optional(list(object({<br/>      policy_arn = string<br/>      access_scope = object({<br/>        type       = string<br/>        namespaces = optional(list(string))<br/>      })<br/>    })))<br/>    tags = optional(map(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_additional_security_group_ids"></a> [additional\_security\_group\_ids](#input\_additional\_security\_group\_ids) | List of additional security group IDs to attach to the EKS cluster.<br/><br/>Use cases:<br/>- Attach security groups from terraform/security-group/ module for custom ingress/egress rules<br/>- Allow specific traffic patterns between cluster and other AWS resources<br/>- Implement network segmentation requirements<br/><br/>Note: EKS automatically creates a cluster security group for node-to-control-plane communication.<br/>These additional security groups are for custom requirements beyond the default.<br/><br/>Default: [] (no additional security groups) | `list(string)` | `[]` | no |
| <a name="input_authentication_mode"></a> [authentication\_mode](#input\_authentication\_mode) | Authentication mode for the EKS cluster. Determines how users and services authenticate to the cluster.<br/><br/>Options:<br/>- "CONFIG\_MAP": Uses the aws-auth ConfigMap (legacy method, still supported but not recommended for new clusters)<br/>- "API": Uses EKS access entries API (recommended for new clusters, supports fine-grained access control)<br/>- "API\_AND\_CONFIG\_MAP": Supports both methods (useful for migration from CONFIG\_MAP to API)<br/><br/>Recommendation:<br/>- Use "API" for new clusters (cleaner, more manageable, supports EKS access entries)<br/>- Use "API\_AND\_CONFIG\_MAP" if migrating from an existing cluster using CONFIG\_MAP<br/>- Avoid "CONFIG\_MAP" for new clusters unless you have specific requirements<br/><br/>Default: "API" | `string` | `"API"` | no |
| <a name="input_bootstrap_cluster_creator_admin_permissions"></a> [bootstrap\_cluster\_creator\_admin\_permissions](#input\_bootstrap\_cluster\_creator\_admin\_permissions) | Grant the cluster creator administrator permissions. When enabled, the IAM principal creating the cluster is automatically granted admin access.<br/><br/>Important considerations:<br/>- Enabled by default for easier initial setup<br/>- Disable in production if you want to enforce strict access control via access\_entries<br/>- If disabled, ensure you configure access\_entries to grant necessary permissions<br/>- The cluster creator can still manage access entries even if this is disabled<br/><br/>Default: true | `bool` | `true` | no |
| <a name="input_cloudwatch_log_kms_key_id"></a> [cloudwatch\_log\_kms\_key\_id](#input\_cloudwatch\_log\_kms\_key\_id) | ARN of the KMS key to use for encrypting CloudWatch Logs.<br/><br/>Use a KMS key when you need:<br/>- Encryption of logs at rest with customer-managed keys<br/>- Fine-grained access control over log encryption<br/>- Audit trails via CloudTrail for key usage<br/>- Compliance requirements for encrypted logs<br/><br/>If not specified, logs are encrypted using AWS-managed keys.<br/><br/>Default: null (uses AWS-managed encryption) | `string` | `null` | no |
| <a name="input_cloudwatch_log_retention_days"></a> [cloudwatch\_log\_retention\_days](#input\_cloudwatch\_log\_retention\_days) | Number of days to retain cluster logs in CloudWatch Logs.<br/><br/>Common retention periods:<br/>- 7 days: Development/testing environments<br/>- 30 days: Staging environments<br/>- 90 days: Production environments (standard)<br/>- 365 days: Production with compliance requirements<br/><br/>Cost considerations:<br/>- Longer retention increases CloudWatch Logs storage costs<br/>- Consider exporting old logs to S3 for long-term archival at lower cost<br/><br/>Default: 90 | `number` | `90` | no |
| <a name="input_cluster_addons"></a> [cluster\_addons](#input\_cluster\_addons) | Map of EKS add-on configurations. Add-ons are operational software for providing key functionality for Kubernetes clusters.<br/><br/>Common add-ons:<br/>- vpc-cni: Amazon VPC CNI plugin for pod networking (required)<br/>- kube-proxy: Kubernetes network proxy (required)<br/>- coredns: DNS server for service discovery (required)<br/>- aws-ebs-csi-driver: EBS CSI driver for persistent volumes (recommended for stateful workloads)<br/><br/>Each add-on configuration includes:<br/>- addon\_version: Version of the add-on (optional, defaults to EKS default version)<br/>- configuration\_values: JSON configuration values for the add-on (optional)<br/>- resolve\_conflicts\_on\_create: "OVERWRITE" or "NONE" (default: "OVERWRITE")<br/>- resolve\_conflicts\_on\_update: "OVERWRITE", "NONE", or "PRESERVE" (default: "OVERWRITE")<br/>- service\_account\_role\_arn: IAM role ARN for IRSA (optional, required for some add-ons like EBS CSI driver)<br/>- preserve: Preserve add-on resources when deleting the add-on (default: true)<br/>- tags: Additional tags for this add-on<br/><br/>IRSA requirements:<br/>- Some add-ons require IRSA (aws-ebs-csi-driver, aws-efs-csi-driver, etc.)<br/>- Create the IAM role in terraform/iam/eks/ module<br/>- Pass the role ARN via service\_account\_role\_arn<br/><br/>Example 1 - Essential add-ons:<br/>cluster\_addons = {<br/>  vpc-cni = {<br/>    addon\_version = "v1.15.0-eksbuild.2"<br/>  }<br/>  kube-proxy = {<br/>    addon\_version = "v1.28.1-eksbuild.1"<br/>  }<br/>  coredns = {<br/>    addon\_version = "v1.10.1-eksbuild.2"<br/>  }<br/>}<br/><br/>Example 2 - With EBS CSI driver (requires IRSA):<br/>cluster\_addons = {<br/>  vpc-cni = {}<br/>  kube-proxy = {}<br/>  coredns = {}<br/>  aws-ebs-csi-driver = {<br/>    addon\_version            = "v1.25.0-eksbuild.1"<br/>    service\_account\_role\_arn = module.eks\_iam.ebs\_csi\_driver\_role\_arn<br/>  }<br/>}<br/><br/>Note: Add-on versions must be compatible with your cluster version. Check AWS documentation for version compatibility.<br/><br/>Default: {} (no add-ons managed by Terraform - they can be installed separately) | <pre>map(object({<br/>    addon_version               = optional(string)<br/>    configuration_values        = optional(string)<br/>    resolve_conflicts_on_create = optional(string)<br/>    resolve_conflicts_on_update = optional(string)<br/>    service_account_role_arn    = optional(string)<br/>    preserve                    = optional(bool)<br/>    tags                        = optional(map(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_cluster_enabled_log_types"></a> [cluster\_enabled\_log\_types](#input\_cluster\_enabled\_log\_types) | List of control plane log types to enable. Logs are sent to CloudWatch Logs for monitoring and troubleshooting.<br/><br/>Available log types:<br/>- "api": API server logs (requests to the Kubernetes API)<br/>- "audit": Audit logs (Kubernetes audit events)<br/>- "authenticator": Authenticator logs (authentication requests)<br/>- "controllerManager": Controller manager logs (cluster controller operations)<br/>- "scheduler": Scheduler logs (pod scheduling decisions)<br/><br/>Security and compliance:<br/>- Enable "audit" for security compliance and forensics<br/>- Enable "api" for troubleshooting API issues<br/>- Enable "authenticator" for debugging authentication problems<br/><br/>Cost considerations:<br/>- CloudWatch Logs charges apply for ingestion and storage<br/>- Consider enabling only necessary log types to manage costs<br/>- Use cloudwatch\_log\_retention\_days to control storage costs<br/><br/>Default: ["audit", "authenticator"] (minimal recommended set for security) | `list(string)` | <pre>[<br/>  "audit",<br/>  "authenticator"<br/>]</pre> | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster. This will be used to identify your cluster and will be prefixed to related resources (e.g., IAM roles, CloudWatch log groups).<br/>The cluster name must be unique within your AWS account and region. | `string` | n/a | yes |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes version for the EKS cluster. Specify the desired Kubernetes version (e.g., "1.28", "1.29", "1.30").<br/><br/>Important considerations:<br/>- EKS supports multiple Kubernetes versions. Check AWS documentation for currently supported versions.<br/>- Plan regular upgrades to stay within the EKS support window (typically N to N-3 versions).<br/>- Test upgrades in non-production environments first.<br/>- When upgrading, also upgrade node groups and add-ons to compatible versions.<br/><br/>Default: "1.30" (update this default periodically to reflect current best practices) | `string` | `"1.30"` | no |
| <a name="input_enable_oidc_provider"></a> [enable\_oidc\_provider](#input\_enable\_oidc\_provider) | Enable OIDC identity provider for the cluster. Required for IAM Roles for Service Accounts (IRSA).<br/><br/>What is IRSA?<br/>- IRSA allows Kubernetes service accounts to assume IAM roles<br/>- Provides fine-grained IAM permissions to pods without using instance profiles<br/>- More secure than sharing IAM credentials or using node IAM roles<br/><br/>When to enable:<br/>- You want to use AWS services from pods with IAM permissions (recommended)<br/>- You need different IAM permissions for different pods/services<br/>- You're using EKS add-ons that require IRSA (EBS CSI driver, ALB controller, etc.)<br/><br/>Integration with terraform/iam/eks/:<br/>- This module outputs the OIDC provider ARN and URL<br/>- Use terraform/iam/eks/ module to create IAM roles that trust this OIDC provider<br/>- IAM roles can then be used by Kubernetes service accounts via annotations<br/><br/>Example IRSA workflow:<br/>1. Enable OIDC provider (this variable = true)<br/>2. Create IAM role in terraform/iam/eks/ that trusts the OIDC provider<br/>3. Annotate Kubernetes service account with eks.amazonaws.com/role-arn<br/>4. Pods using that service account can assume the IAM role<br/><br/>Default: true (recommended for production) | `bool` | `true` | no |
| <a name="input_encryption_config_kms_key_arn"></a> [encryption\_config\_kms\_key\_arn](#input\_encryption\_config\_kms\_key\_arn) | ARN of the KMS key to use for encrypting Kubernetes secrets at rest.<br/><br/>Security best practices:<br/>- Enable encryption for production clusters (required for many compliance frameworks)<br/>- Use a dedicated KMS key for EKS secrets<br/>- Implement proper KMS key policies to control access<br/><br/>Important considerations:<br/>- Encryption can only be enabled at cluster creation time (cannot be enabled later)<br/>- Ensure the KMS key policy grants EKS service permissions<br/>- If the KMS key is deleted or disabled, the cluster will become inoperable<br/><br/>Use a KMS key when you need:<br/>- Encryption of Kubernetes secrets with customer-managed keys<br/>- Fine-grained access control over secret encryption<br/>- Audit trails via CloudTrail for secret access<br/>- Compliance requirements (PCI DSS, HIPAA, etc.)<br/><br/>If not specified, secrets are stored unencrypted (not recommended for production).<br/><br/>Default: null (secrets are not encrypted - enable for production!) | `string` | `null` | no |
| <a name="input_endpoint_private_access"></a> [endpoint\_private\_access](#input\_endpoint\_private\_access) | Enable private API server endpoint access. When enabled, Kubernetes API requests from within your VPC use the private VPC endpoint.<br/><br/>Security implications:<br/>- Enabled by default for better security (API access stays within your VPC)<br/>- Recommended for production workloads<br/>- Required if endpoint\_public\_access is disabled<br/><br/>Default: true | `bool` | `true` | no |
| <a name="input_endpoint_public_access"></a> [endpoint\_public\_access](#input\_endpoint\_public\_access) | Enable public API server endpoint access. When enabled, the Kubernetes API server is accessible from the internet.<br/><br/>Security implications:<br/>- Disabled by default for better security posture<br/>- When enabled, use endpoint\_public\_access\_cidrs to restrict access to known IPs<br/>- Consider using a bastion host or VPN instead of public access<br/>- If enabled, ensure proper RBAC and authentication are configured<br/><br/>Use cases for enabling public access:<br/>- CI/CD pipelines running outside your VPC<br/>- Developer access from external networks<br/>- Kubectl access from local machines (consider alternatives like VPN or bastion)<br/><br/>Default: false | `bool` | `false` | no |
| <a name="input_endpoint_public_access_cidrs"></a> [endpoint\_public\_access\_cidrs](#input\_endpoint\_public\_access\_cidrs) | List of CIDR blocks that can access the public API server endpoint. Only used when endpoint\_public\_access is true.<br/><br/>Security best practices:<br/>- Never use ["0.0.0.0/0"] in production (allows access from anywhere on the internet)<br/>- Restrict to known IP ranges (office networks, CI/CD systems, VPN endpoints)<br/>- Regularly review and update this list as your infrastructure changes<br/><br/>Example: ["203.0.113.0/24", "198.51.100.0/24"] (your office and CI/CD network ranges)<br/><br/>Default: ["0.0.0.0/0"] (allows access from anywhere - change this for production!) | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | Map of EKS managed node group configurations. Node groups provide compute capacity for running Kubernetes workloads.<br/><br/>IMPORTANT: Node IAM roles are NOT created by this module. They must be created separately in terraform/iam/eks/ and passed via node\_role\_arn.<br/><br/>Why separate node IAM roles?<br/>- Reusability: Same IAM role can be used across multiple node groups or with Karpenter<br/>- Separation of concerns: IAM management is separate from EKS cluster management<br/>- Prevents circular dependencies between modules<br/><br/>Each node group configuration includes:<br/><br/>Required fields:<br/>- node\_role\_arn: ARN of the IAM role for the node group (created in terraform/iam/eks/)<br/>- subnet\_ids: List of subnet IDs where nodes will be launched<br/>- desired\_size: Desired number of nodes<br/>- max\_size: Maximum number of nodes<br/>- min\_size: Minimum number of nodes<br/><br/>Optional fields:<br/>- instance\_types: List of instance types (default: ["t3.medium"])<br/>- capacity\_type: "ON\_DEMAND" or "SPOT" (default: "ON\_DEMAND")<br/>- disk\_size: Root volume size in GB (default: EKS default based on AMI)<br/>- ami\_type: AMI type - "AL2\_x86\_64", "AL2\_x86\_64\_GPU", "AL2\_ARM\_64", "BOTTLEROCKET\_x86\_64", "BOTTLEROCKET\_ARM\_64" (default: "AL2\_x86\_64")<br/>- kubernetes\_version: Override cluster version for this node group (default: cluster\_version)<br/>- labels: Map of Kubernetes labels to apply to nodes<br/>- taints: List of Kubernetes taints to apply to nodes<br/>  - key: Taint key<br/>  - value: Taint value (optional)<br/>  - effect: "NO\_SCHEDULE", "NO\_EXECUTE", or "PREFER\_NO\_SCHEDULE"<br/>- update\_config: Configuration for node updates<br/>  - max\_unavailable: Maximum number of nodes unavailable during update (use this OR max\_unavailable\_percentage)<br/>  - max\_unavailable\_percentage: Maximum percentage of nodes unavailable during update<br/>- remote\_access: SSH access configuration (optional)<br/>  - ec2\_ssh\_key: Name of EC2 key pair<br/>  - source\_security\_group\_ids: Security groups allowed to SSH<br/>- launch\_template: Custom launch template (optional, for advanced configuration)<br/>  - id: Launch template ID<br/>  - name: Launch template name (use id OR name)<br/>  - version: Launch template version (default: "$Latest")<br/>- tags: Additional tags for this node group<br/><br/>Design considerations:<br/>- Node groups are OPTIONAL - clusters can run without them (Karpenter-only mode)<br/>- You can have multiple node groups with different configurations<br/>- Use node selectors, labels, and taints for workload placement<br/><br/>Example 1 - Minimal configuration:<br/>node\_groups = {<br/>  default = {<br/>    node\_role\_arn = module.eks\_iam.node\_role\_arn<br/>    subnet\_ids    = module.vpc.private\_subnet\_ids<br/>    desired\_size  = 2<br/>    max\_size      = 4<br/>    min\_size      = 1<br/>  }<br/>}<br/><br/>Example 2 - Multiple node groups with different instance types:<br/>node\_groups = {<br/>  general = {<br/>    node\_role\_arn  = module.eks\_iam.node\_role\_arn<br/>    subnet\_ids     = module.vpc.private\_subnet\_ids<br/>    desired\_size   = 2<br/>    max\_size       = 5<br/>    min\_size       = 1<br/>    instance\_types = ["t3.large"]<br/>    capacity\_type  = "ON\_DEMAND"<br/>    labels = {<br/>      workload-type = "general"<br/>    }<br/>  }<br/>  spot = {<br/>    node\_role\_arn  = module.eks\_iam.node\_role\_arn<br/>    subnet\_ids     = module.vpc.private\_subnet\_ids<br/>    desired\_size   = 1<br/>    max\_size       = 10<br/>    min\_size       = 0<br/>    instance\_types = ["t3.large", "t3.xlarge"]<br/>    capacity\_type  = "SPOT"<br/>    labels = {<br/>      workload-type = "batch"<br/>    }<br/>    taints = [<br/>      {<br/>        key    = "spot"<br/>        value  = "true"<br/>        effect = "NO\_SCHEDULE"<br/>      }<br/>    ]<br/>  }<br/>}<br/><br/>Default: {} (no node groups - cluster can run in Karpenter-only mode) | <pre>map(object({<br/>    node_role_arn      = string<br/>    subnet_ids         = list(string)<br/>    desired_size       = number<br/>    max_size           = number<br/>    min_size           = number<br/>    instance_types     = optional(list(string))<br/>    capacity_type      = optional(string)<br/>    disk_size          = optional(number)<br/>    ami_type           = optional(string)<br/>    kubernetes_version = optional(string)<br/>    labels             = optional(map(string))<br/>    taints = optional(list(object({<br/>      key    = string<br/>      value  = optional(string)<br/>      effect = string<br/>    })))<br/>    update_config = optional(object({<br/>      max_unavailable            = optional(number)<br/>      max_unavailable_percentage = optional(number)<br/>    }))<br/>    remote_access = optional(object({<br/>      ec2_ssh_key               = optional(string)<br/>      source_security_group_ids = optional(list(string))<br/>    }))<br/>    launch_template = optional(object({<br/>      id      = optional(string)<br/>      name    = optional(string)<br/>      version = optional(string)<br/>    }))<br/>    tags = optional(map(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for the EKS cluster. The cluster will create elastic network interfaces (ENIs) in these subnets to communicate with worker nodes.<br/><br/>Best practices:<br/>- Use private subnets for worker nodes (recommended)<br/>- Include at least 2 subnets across different availability zones for high availability<br/>- Ensure subnets have the required Kubernetes tags:<br/>  - "kubernetes.io/cluster/CLUSTER\_NAME" = "shared" (for both public and private subnets)<br/>  - "kubernetes.io/role/internal-elb" = "1" (for private subnets, used by internal load balancers)<br/>  - "kubernetes.io/role/elb" = "1" (for public subnets, used by internet-facing load balancers)<br/><br/>These subnets will be used by the EKS control plane to create cross-account ENIs for cluster communication. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. Use this to add consistent tagging across your infrastructure for cost allocation, environment identification, etc.<br/><br/>Recommended tags:<br/>- Environment: production, staging, development<br/>- ManagedBy: terraform<br/>- Owner: team or individual responsible<br/>- CostCenter: for cost allocation<br/>- Project: project or application name<br/><br/>Note: The "Name" tag is automatically added to resources with appropriate values (e.g., cluster name, node group name). | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_entries"></a> [access\_entries](#output\_access\_entries) | Map of access entry attributes. Use this to reference access entries for monitoring or verification.<br/>Only relevant when authentication\_mode is "API" or "API\_AND\_CONFIG\_MAP". |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | The ARN of the CloudWatch log group for cluster logs. |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | The name of the CloudWatch log group for cluster logs. Use this to query logs or configure log processing. |
| <a name="output_cluster_addon_arns"></a> [cluster\_addon\_arns](#output\_cluster\_addon\_arns) | List of cluster add-on ARNs. |
| <a name="output_cluster_addon_versions"></a> [cluster\_addon\_versions](#output\_cluster\_addon\_versions) | Map of add-on names to their current versions. Use this to track add-on versions for compatibility and upgrade planning. |
| <a name="output_cluster_addons"></a> [cluster\_addons](#output\_cluster\_addons) | Map of cluster add-on attributes including ARNs, versions, and status. Use this to verify add-on versions and health.<br/>Contains information about all add-ons managed by this module. |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | The ARN of the EKS cluster. Use this for IAM policies, resource tagging, and cross-account access configurations. |
| <a name="output_cluster_authentication_mode"></a> [cluster\_authentication\_mode](#output\_cluster\_authentication\_mode) | The authentication mode configured for the cluster (CONFIG\_MAP, API, or API\_AND\_CONFIG\_MAP). |
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | Base64 encoded certificate data required to communicate with the cluster.<br/>Use this when configuring kubectl or other Kubernetes clients. This is sensitive data that should be handled securely. |
| <a name="output_cluster_enabled_log_types"></a> [cluster\_enabled\_log\_types](#output\_cluster\_enabled\_log\_types) | List of enabled control plane log types. |
| <a name="output_cluster_encryption_enabled"></a> [cluster\_encryption\_enabled](#output\_cluster\_encryption\_enabled) | Whether Kubernetes secrets encryption is enabled. |
| <a name="output_cluster_encryption_kms_key_arn"></a> [cluster\_encryption\_kms\_key\_arn](#output\_cluster\_encryption\_kms\_key\_arn) | The ARN of the KMS key used for secrets encryption, if enabled. |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | The endpoint URL for the EKS cluster API server. Use this to configure kubectl and other Kubernetes clients.<br/>This endpoint respects the endpoint\_private\_access and endpoint\_public\_access settings. |
| <a name="output_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#output\_cluster\_endpoint\_private\_access) | Whether the cluster API endpoint has private access enabled. |
| <a name="output_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#output\_cluster\_endpoint\_public\_access) | Whether the cluster API endpoint is publicly accessible. |
| <a name="output_cluster_iam_role_arn"></a> [cluster\_iam\_role\_arn](#output\_cluster\_iam\_role\_arn) | The ARN of the IAM role used by the EKS control plane. This role has permissions to manage cluster resources. |
| <a name="output_cluster_iam_role_name"></a> [cluster\_iam\_role\_name](#output\_cluster\_iam\_role\_name) | The name of the IAM role used by the EKS control plane. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The ID of the EKS cluster. This is the same as the cluster name. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The name of the EKS cluster. Use this to reference the cluster in kubectl, Helm, and other Kubernetes tools. |
| <a name="output_cluster_platform_version"></a> [cluster\_platform\_version](#output\_cluster\_platform\_version) | The platform version of the EKS cluster. AWS updates the platform version to provide new features and security patches. |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | The security group ID created by EKS for the cluster. This security group controls communication between the control plane and worker nodes.<br/>Use this to configure additional security group rules if needed. |
| <a name="output_cluster_version"></a> [cluster\_version](#output\_cluster\_version) | The Kubernetes version running on the cluster. Important for compatibility checks when deploying workloads or upgrading. |
| <a name="output_node_group_arns"></a> [node\_group\_arns](#output\_node\_group\_arns) | List of node group ARNs. Use this for IAM policies or resource tagging. |
| <a name="output_node_group_ids"></a> [node\_group\_ids](#output\_node\_group\_ids) | List of node group IDs. Use this for scripting and automation that needs to reference all node groups. |
| <a name="output_node_group_statuses"></a> [node\_group\_statuses](#output\_node\_group\_statuses) | Map of node group names to their current status. Use this for health checks and monitoring. Possible values: CREATING, ACTIVE, UPDATING, DELETING, CREATE\_FAILED, DELETE\_FAILED, DEGRADED. |
| <a name="output_node_groups"></a> [node\_groups](#output\_node\_groups) | Map of node group attributes including IDs, ARNs, and status. Use this to reference node groups in other resources or for monitoring.<br/>Contains information about all managed node groups created by this module. |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | The ARN of the OIDC identity provider for the cluster. Use this when creating IAM roles for service accounts (IRSA) in terraform/iam/eks/.<br/>IAM roles that trust this OIDC provider can be assumed by Kubernetes service accounts.<br/>Only available if enable\_oidc\_provider is true. |
| <a name="output_oidc_provider_url"></a> [oidc\_provider\_url](#output\_oidc\_provider\_url) | The URL of the OIDC identity provider for the cluster (without https:// prefix).<br/>Use this when configuring trust relationships for IRSA IAM roles in terraform/iam/eks/.<br/>Example trust policy condition: "OIDC\_PROVIDER\_URL:sub": "system:serviceaccount:NAMESPACE:SERVICE\_ACCOUNT\_NAME"<br/>Only available if enable\_oidc\_provider is true. |
| <a name="output_tags"></a> [tags](#output\_tags) | All tags applied to the cluster, including default and custom tags. |
<!-- END_TF_DOCS -->


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
