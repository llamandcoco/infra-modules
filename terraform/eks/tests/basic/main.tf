terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Mock AWS provider for testing without credentials
provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  access_key = "test"
  secret_key = "test"
}

# -----------------------------------------------------------------------------
# Mock Data for Testing
# -----------------------------------------------------------------------------

locals {
  # Mock VPC and subnet IDs for testing
  mock_vpc_id = "vpc-1234567890abcdef0"
  mock_subnet_ids = [
    "subnet-1234567890abcdef0",
    "subnet-0987654321fedcba0"
  ]

  # Mock IAM role ARN for node groups
  mock_node_role_arn = "arn:aws:iam::123456789012:role/eks-node-group-role"

  # Mock KMS key ARN for testing encryption
  mock_kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
}

# -----------------------------------------------------------------------------
# Test 1: Minimal EKS cluster (Karpenter-ready)
# Private endpoint only, no node groups, OIDC enabled
# -----------------------------------------------------------------------------

module "minimal_cluster" {
  source = "../../"

  cluster_name    = "test-minimal-cluster"
  cluster_version = "1.30"
  subnet_ids      = local.mock_subnet_ids

  # Security: private endpoint only
  endpoint_private_access = true
  endpoint_public_access  = false

  # Enable OIDC for IRSA (required for Karpenter and other add-ons)
  enable_oidc_provider = true

  # Minimal logging for cost optimization
  cluster_enabled_log_types = ["audit"]

  # No node groups - Karpenter-only mode
  node_groups = {}

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "minimal-testing"
    Workload    = "karpenter-ready"
  }
}

# -----------------------------------------------------------------------------
# Test 2: EKS cluster with managed node groups
# Demonstrates using node groups with different configurations
# -----------------------------------------------------------------------------

module "cluster_with_node_groups" {
  source = "../../"

  cluster_name    = "test-cluster-with-nodes"
  cluster_version = "1.30"
  subnet_ids      = local.mock_subnet_ids

  # Public endpoint for testing (restrict in production!)
  endpoint_private_access      = true
  endpoint_public_access       = true
  endpoint_public_access_cidrs = ["10.0.0.0/8"] # Office network example

  # Enable OIDC for IRSA
  enable_oidc_provider = true

  # Comprehensive logging
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Node groups with different configurations
  node_groups = {
    general = {
      node_role_arn = local.mock_node_role_arn
      subnet_ids    = local.mock_subnet_ids
      desired_size  = 2
      max_size      = 4
      min_size      = 1

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      labels = {
        workload-type = "general"
        node-group    = "general"
      }
    }

    spot = {
      node_role_arn = local.mock_node_role_arn
      subnet_ids    = local.mock_subnet_ids
      desired_size  = 1
      max_size      = 10
      min_size      = 0

      instance_types = ["t3.medium", "t3.large"]
      capacity_type  = "SPOT"

      labels = {
        workload-type = "batch"
        node-group    = "spot"
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
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "node-group-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 3: Highly secure EKS cluster with encryption
# Demonstrates security best practices
# -----------------------------------------------------------------------------

module "secure_cluster" {
  source = "../../"

  cluster_name    = "test-secure-cluster"
  cluster_version = "1.30"
  subnet_ids      = local.mock_subnet_ids

  # Strictly private endpoint
  endpoint_private_access = true
  endpoint_public_access  = false

  # Enable OIDC for IRSA
  enable_oidc_provider = true

  # Full logging for security and compliance
  cluster_enabled_log_types      = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cloudwatch_log_retention_days  = 365
  cloudwatch_log_kms_key_id      = local.mock_kms_key_arn

  # Encrypt Kubernetes secrets at rest
  encryption_config_kms_key_arn = local.mock_kms_key_arn

  # Use API-only authentication mode (no ConfigMap)
  authentication_mode = "API"
  bootstrap_cluster_creator_admin_permissions = false

  # Access entries for fine-grained access control
  access_entries = {
    admin = {
      principal_arn = "arn:aws:iam::123456789012:role/EKSAdminRole"
      type          = "STANDARD"
      access_policies = [
        {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      ]
    }
    developer = {
      principal_arn = "arn:aws:iam::123456789012:role/EKSDeveloperRole"
      type          = "STANDARD"
      access_policies = [
        {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
          access_scope = {
            type       = "namespace"
            namespaces = ["development"]
          }
        }
      ]
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Purpose     = "security-testing"
    Compliance  = "pci-dss"
  }
}

# -----------------------------------------------------------------------------
# Test 4: EKS cluster with add-ons
# Demonstrates add-on configuration
# -----------------------------------------------------------------------------

module "cluster_with_addons" {
  source = "../../"

  cluster_name    = "test-cluster-with-addons"
  cluster_version = "1.30"
  subnet_ids      = local.mock_subnet_ids

  endpoint_private_access = true
  endpoint_public_access  = false

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
      service_account_role_arn = "arn:aws:iam::123456789012:role/ebs-csi-driver-role"
    }
  }

  # Node group to support add-ons
  node_groups = {
    default = {
      node_role_arn = local.mock_node_role_arn
      subnet_ids    = local.mock_subnet_ids
      desired_size  = 2
      max_size      = 4
      min_size      = 1
    }
  }

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "addon-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 5: EKS cluster with mixed authentication mode
# Demonstrates migration from ConfigMap to API mode
# -----------------------------------------------------------------------------

module "mixed_auth_cluster" {
  source = "../../"

  cluster_name    = "test-mixed-auth-cluster"
  cluster_version = "1.30"
  subnet_ids      = local.mock_subnet_ids

  endpoint_private_access = true
  endpoint_public_access  = true

  enable_oidc_provider = true

  # Mixed authentication mode for migration scenarios
  authentication_mode = "API_AND_CONFIG_MAP"
  bootstrap_cluster_creator_admin_permissions = true

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "migration-testing"
  }
}

# -----------------------------------------------------------------------------
# Test Outputs
# -----------------------------------------------------------------------------

output "minimal_cluster_endpoint" {
  description = "Endpoint of the minimal test cluster"
  value       = module.minimal_cluster.cluster_endpoint
}

output "minimal_cluster_oidc_provider_arn" {
  description = "OIDC provider ARN for minimal cluster (for IRSA)"
  value       = module.minimal_cluster.oidc_provider_arn
}

output "minimal_cluster_oidc_provider_url" {
  description = "OIDC provider URL for minimal cluster (for IRSA)"
  value       = module.minimal_cluster.oidc_provider_url
}

output "node_group_cluster_endpoint" {
  description = "Endpoint of the cluster with node groups"
  value       = module.cluster_with_node_groups.cluster_endpoint
}

output "node_group_ids" {
  description = "IDs of the node groups"
  value       = module.cluster_with_node_groups.node_group_ids
}

output "secure_cluster_name" {
  description = "Name of the secure test cluster"
  value       = module.secure_cluster.cluster_name
}

output "secure_cluster_encryption_enabled" {
  description = "Whether encryption is enabled for secure cluster"
  value       = module.secure_cluster.cluster_encryption_enabled
}

output "addon_cluster_addons" {
  description = "Add-ons configured for addon cluster"
  value       = module.cluster_with_addons.cluster_addon_versions
}

output "mixed_auth_cluster_authentication_mode" {
  description = "Authentication mode of mixed auth cluster"
  value       = module.mixed_auth_cluster.cluster_authentication_mode
}
