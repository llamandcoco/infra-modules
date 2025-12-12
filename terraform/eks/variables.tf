# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "cluster_name" {
  description = <<-EOT
    Name of the EKS cluster. This will be used to identify your cluster and will be prefixed to related resources (e.g., IAM roles, CloudWatch log groups).
    The cluster name must be unique within your AWS account and region.
  EOT
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.cluster_name))
    error_message = "Cluster name must start with a letter and contain only letters, numbers, and hyphens."
  }

  validation {
    condition     = length(var.cluster_name) >= 1 && length(var.cluster_name) <= 100
    error_message = "Cluster name must be between 1 and 100 characters long."
  }
}

variable "subnet_ids" {
  description = <<-EOT
    List of subnet IDs for the EKS cluster. The cluster will create elastic network interfaces (ENIs) in these subnets to communicate with worker nodes.

    Best practices:
    - Use private subnets for worker nodes (recommended)
    - Include at least 2 subnets across different availability zones for high availability
    - Ensure subnets have the required Kubernetes tags:
      - "kubernetes.io/cluster/CLUSTER_NAME" = "shared" (for both public and private subnets)
      - "kubernetes.io/role/internal-elb" = "1" (for private subnets, used by internal load balancers)
      - "kubernetes.io/role/elb" = "1" (for public subnets, used by internet-facing load balancers)

    These subnets will be used by the EKS control plane to create cross-account ENIs for cluster communication.
  EOT
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnet IDs are required for high availability."
  }
}

# -----------------------------------------------------------------------------
# Cluster Configuration Variables
# -----------------------------------------------------------------------------

variable "cluster_version" {
  description = <<-EOT
    Kubernetes version for the EKS cluster. Specify the desired Kubernetes version (e.g., "1.28", "1.29", "1.30").

    Important considerations:
    - EKS supports multiple Kubernetes versions. Check AWS documentation for currently supported versions.
    - Plan regular upgrades to stay within the EKS support window (typically N to N-3 versions).
    - Test upgrades in non-production environments first.
    - When upgrading, also upgrade node groups and add-ons to compatible versions.

    Default: "1.30" (update this default periodically to reflect current best practices)
  EOT
  type        = string
  default     = "1.30"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.cluster_version))
    error_message = "Cluster version must be in the format 'major.minor' (e.g., '1.30')."
  }

  validation {
    condition     = tonumber(split(".", var.cluster_version)[0]) >= 1 && tonumber(split(".", var.cluster_version)[1]) >= 28
    error_message = "Cluster version must be at least 1.28 (older versions may have reached end-of-support)."
  }
}

variable "endpoint_private_access" {
  description = <<-EOT
    Enable private API server endpoint access. When enabled, Kubernetes API requests from within your VPC use the private VPC endpoint.

    Security implications:
    - Enabled by default for better security (API access stays within your VPC)
    - Recommended for production workloads
    - Required if endpoint_public_access is disabled

    Default: true
  EOT
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = <<-EOT
    Enable public API server endpoint access. When enabled, the Kubernetes API server is accessible from the internet.

    Security implications:
    - Disabled by default for better security posture
    - When enabled, use endpoint_public_access_cidrs to restrict access to known IPs
    - Consider using a bastion host or VPN instead of public access
    - If enabled, ensure proper RBAC and authentication are configured

    Use cases for enabling public access:
    - CI/CD pipelines running outside your VPC
    - Developer access from external networks
    - Kubectl access from local machines (consider alternatives like VPN or bastion)

    Default: false
  EOT
  type        = bool
  default     = false
}

variable "endpoint_public_access_cidrs" {
  description = <<-EOT
    List of CIDR blocks that can access the public API server endpoint. Only used when endpoint_public_access is true.

    Security best practices:
    - Never use ["0.0.0.0/0"] in production (allows access from anywhere on the internet)
    - Restrict to known IP ranges (office networks, CI/CD systems, VPN endpoints)
    - Regularly review and update this list as your infrastructure changes

    Example: ["203.0.113.0/24", "198.51.100.0/24"] (your office and CI/CD network ranges)

    Default: ["0.0.0.0/0"] (allows access from anywhere - change this for production!)
  EOT
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "additional_security_group_ids" {
  description = <<-EOT
    List of additional security group IDs to attach to the EKS cluster.

    Use cases:
    - Attach security groups from terraform/security-group/ module for custom ingress/egress rules
    - Allow specific traffic patterns between cluster and other AWS resources
    - Implement network segmentation requirements

    Note: EKS automatically creates a cluster security group for node-to-control-plane communication.
    These additional security groups are for custom requirements beyond the default.

    Default: [] (no additional security groups)
  EOT
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Authentication and Access Variables
# -----------------------------------------------------------------------------

variable "authentication_mode" {
  description = <<-EOT
    Authentication mode for the EKS cluster. Determines how users and services authenticate to the cluster.

    Options:
    - "CONFIG_MAP": Uses the aws-auth ConfigMap (legacy method, still supported but not recommended for new clusters)
    - "API": Uses EKS access entries API (recommended for new clusters, supports fine-grained access control)
    - "API_AND_CONFIG_MAP": Supports both methods (useful for migration from CONFIG_MAP to API)

    Recommendation:
    - Use "API" for new clusters (cleaner, more manageable, supports EKS access entries)
    - Use "API_AND_CONFIG_MAP" if migrating from an existing cluster using CONFIG_MAP
    - Avoid "CONFIG_MAP" for new clusters unless you have specific requirements

    Default: "API"
  EOT
  type        = string
  default     = "API"

  validation {
    condition     = contains(["CONFIG_MAP", "API", "API_AND_CONFIG_MAP"], var.authentication_mode)
    error_message = "Authentication mode must be one of: CONFIG_MAP, API, API_AND_CONFIG_MAP."
  }
}

variable "bootstrap_cluster_creator_admin_permissions" {
  description = <<-EOT
    Grant the cluster creator administrator permissions. When enabled, the IAM principal creating the cluster is automatically granted admin access.

    Important considerations:
    - Enabled by default for easier initial setup
    - Disable in production if you want to enforce strict access control via access_entries
    - If disabled, ensure you configure access_entries to grant necessary permissions
    - The cluster creator can still manage access entries even if this is disabled

    Default: true
  EOT
  type        = bool
  default     = true
}

variable "access_entries" {
  description = <<-EOT
    Map of EKS access entries for granting IAM principals access to the cluster. Only used when authentication_mode is "API" or "API_AND_CONFIG_MAP".

    Access entries provide fine-grained access control and are the recommended method for managing cluster access.

    Each entry includes:
    - principal_arn: ARN of the IAM user, role, or federated user
    - kubernetes_groups: List of Kubernetes groups to add the principal to (optional)
    - type: Access entry type - "STANDARD", "FARGATE_LINUX", or "EC2_LINUX" (default: "STANDARD")
    - access_policies: List of AWS managed access policies to associate (optional)
      - policy_arn: ARN of the access policy (e.g., "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy")
      - access_scope:
        - type: "cluster" or "namespace"
        - namespaces: List of namespaces (only for type = "namespace")

    Available AWS managed access policies:
    - AmazonEKSClusterAdminPolicy: Full admin access to cluster
    - AmazonEKSAdminPolicy: Admin access within specified namespace(s)
    - AmazonEKSEditPolicy: Edit resources within specified namespace(s)
    - AmazonEKSViewPolicy: Read-only access within specified namespace(s)

    Example:
    access_entries = {
      admin = {
        principal_arn     = "arn:aws:iam::123456789012:role/EKSAdminRole"
        kubernetes_groups = ["system:masters"]
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
        access_policies = [
          {
            policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
            access_scope = {
              type       = "namespace"
              namespaces = ["default", "development"]
            }
          }
        ]
      }
    }

    Default: {} (no additional access entries)
  EOT
  type = map(object({
    principal_arn     = string
    kubernetes_groups = optional(list(string))
    type              = optional(string)
    access_policies = optional(list(object({
      policy_arn = string
      access_scope = object({
        type       = string
        namespaces = optional(list(string))
      })
    })))
    tags = optional(map(string))
  }))
  default = {}
}

# -----------------------------------------------------------------------------
# Logging Variables
# -----------------------------------------------------------------------------

variable "cluster_enabled_log_types" {
  description = <<-EOT
    List of control plane log types to enable. Logs are sent to CloudWatch Logs for monitoring and troubleshooting.

    Available log types:
    - "api": API server logs (requests to the Kubernetes API)
    - "audit": Audit logs (Kubernetes audit events)
    - "authenticator": Authenticator logs (authentication requests)
    - "controllerManager": Controller manager logs (cluster controller operations)
    - "scheduler": Scheduler logs (pod scheduling decisions)

    Security and compliance:
    - Enable "audit" for security compliance and forensics
    - Enable "api" for troubleshooting API issues
    - Enable "authenticator" for debugging authentication problems

    Cost considerations:
    - CloudWatch Logs charges apply for ingestion and storage
    - Consider enabling only necessary log types to manage costs
    - Use cloudwatch_log_retention_days to control storage costs

    Default: ["audit", "authenticator"] (minimal recommended set for security)
  EOT
  type        = list(string)
  default     = ["audit", "authenticator"]

  validation {
    condition = alltrue([
      for log_type in var.cluster_enabled_log_types :
      contains(["api", "audit", "authenticator", "controllerManager", "scheduler"], log_type)
    ])
    error_message = "Invalid log type. Must be one of: api, audit, authenticator, controllerManager, scheduler."
  }
}

variable "cloudwatch_log_retention_days" {
  description = <<-EOT
    Number of days to retain cluster logs in CloudWatch Logs.

    Common retention periods:
    - 7 days: Development/testing environments
    - 30 days: Staging environments
    - 90 days: Production environments (standard)
    - 365 days: Production with compliance requirements

    Cost considerations:
    - Longer retention increases CloudWatch Logs storage costs
    - Consider exporting old logs to S3 for long-term archival at lower cost

    Default: 90
  EOT
  type        = number
  default     = 90

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.cloudwatch_log_retention_days)
    error_message = "Log retention days must be one of the allowed values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653."
  }
}

variable "cloudwatch_log_kms_key_id" {
  description = <<-EOT
    ARN of the KMS key to use for encrypting CloudWatch Logs.

    Use a KMS key when you need:
    - Encryption of logs at rest with customer-managed keys
    - Fine-grained access control over log encryption
    - Audit trails via CloudTrail for key usage
    - Compliance requirements for encrypted logs

    If not specified, logs are encrypted using AWS-managed keys.

    Default: null (uses AWS-managed encryption)
  EOT
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Encryption Variables
# -----------------------------------------------------------------------------

variable "encryption_config_kms_key_arn" {
  description = <<-EOT
    ARN of the KMS key to use for encrypting Kubernetes secrets at rest.

    Security best practices:
    - Enable encryption for production clusters (required for many compliance frameworks)
    - Use a dedicated KMS key for EKS secrets
    - Implement proper KMS key policies to control access

    Important considerations:
    - Encryption can only be enabled at cluster creation time (cannot be enabled later)
    - Ensure the KMS key policy grants EKS service permissions
    - If the KMS key is deleted or disabled, the cluster will become inoperable

    Use a KMS key when you need:
    - Encryption of Kubernetes secrets with customer-managed keys
    - Fine-grained access control over secret encryption
    - Audit trails via CloudTrail for secret access
    - Compliance requirements (PCI DSS, HIPAA, etc.)

    If not specified, secrets are stored unencrypted (not recommended for production).

    Default: null (secrets are not encrypted - enable for production!)
  EOT
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# OIDC Provider Variables
# -----------------------------------------------------------------------------

variable "enable_oidc_provider" {
  description = <<-EOT
    Enable OIDC identity provider for the cluster. Required for IAM Roles for Service Accounts (IRSA).

    What is IRSA?
    - IRSA allows Kubernetes service accounts to assume IAM roles
    - Provides fine-grained IAM permissions to pods without using instance profiles
    - More secure than sharing IAM credentials or using node IAM roles

    When to enable:
    - You want to use AWS services from pods with IAM permissions (recommended)
    - You need different IAM permissions for different pods/services
    - You're using EKS add-ons that require IRSA (EBS CSI driver, ALB controller, etc.)

    Integration with terraform/iam/eks/:
    - This module outputs the OIDC provider ARN and URL
    - Use terraform/iam/eks/ module to create IAM roles that trust this OIDC provider
    - IAM roles can then be used by Kubernetes service accounts via annotations

    Example IRSA workflow:
    1. Enable OIDC provider (this variable = true)
    2. Create IAM role in terraform/iam/eks/ that trusts the OIDC provider
    3. Annotate Kubernetes service account with eks.amazonaws.com/role-arn
    4. Pods using that service account can assume the IAM role

    Default: true (recommended for production)
  EOT
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Node Group Variables
# -----------------------------------------------------------------------------

variable "node_groups" {
  description = <<-EOT
    Map of EKS managed node group configurations. Node groups provide compute capacity for running Kubernetes workloads.

    IMPORTANT: Node IAM roles are NOT created by this module. They must be created separately in terraform/iam/eks/ and passed via node_role_arn.

    Why separate node IAM roles?
    - Reusability: Same IAM role can be used across multiple node groups or with Karpenter
    - Separation of concerns: IAM management is separate from EKS cluster management
    - Prevents circular dependencies between modules

    Each node group configuration includes:

    Required fields:
    - node_role_arn: ARN of the IAM role for the node group (created in terraform/iam/eks/)
    - subnet_ids: List of subnet IDs where nodes will be launched
    - desired_size: Desired number of nodes
    - max_size: Maximum number of nodes
    - min_size: Minimum number of nodes

    Optional fields:
    - instance_types: List of instance types (default: ["t3.medium"])
    - capacity_type: "ON_DEMAND" or "SPOT" (default: "ON_DEMAND")
    - disk_size: Root volume size in GB (default: EKS default based on AMI)
    - ami_type: AMI type - "AL2_x86_64", "AL2_x86_64_GPU", "AL2_ARM_64", "BOTTLEROCKET_x86_64", "BOTTLEROCKET_ARM_64" (default: "AL2_x86_64")
    - kubernetes_version: Override cluster version for this node group (default: cluster_version)
    - labels: Map of Kubernetes labels to apply to nodes
    - taints: List of Kubernetes taints to apply to nodes
      - key: Taint key
      - value: Taint value (optional)
      - effect: "NO_SCHEDULE", "NO_EXECUTE", or "PREFER_NO_SCHEDULE"
    - update_config: Configuration for node updates
      - max_unavailable: Maximum number of nodes unavailable during update (use this OR max_unavailable_percentage)
      - max_unavailable_percentage: Maximum percentage of nodes unavailable during update
    - remote_access: SSH access configuration (optional)
      - ec2_ssh_key: Name of EC2 key pair
      - source_security_group_ids: Security groups allowed to SSH
    - launch_template: Custom launch template (optional, for advanced configuration)
      - id: Launch template ID
      - name: Launch template name (use id OR name)
      - version: Launch template version (default: "$Latest")
    - tags: Additional tags for this node group

    Design considerations:
    - Node groups are OPTIONAL - clusters can run without them (Karpenter-only mode)
    - You can have multiple node groups with different configurations
    - Use node selectors, labels, and taints for workload placement

    Example 1 - Minimal configuration:
    node_groups = {
      default = {
        node_role_arn = module.eks_iam.node_role_arn
        subnet_ids    = module.vpc.private_subnet_ids
        desired_size  = 2
        max_size      = 4
        min_size      = 1
      }
    }

    Example 2 - Multiple node groups with different instance types:
    node_groups = {
      general = {
        node_role_arn  = module.eks_iam.node_role_arn
        subnet_ids     = module.vpc.private_subnet_ids
        desired_size   = 2
        max_size       = 5
        min_size       = 1
        instance_types = ["t3.large"]
        capacity_type  = "ON_DEMAND"
        labels = {
          workload-type = "general"
        }
      }
      spot = {
        node_role_arn  = module.eks_iam.node_role_arn
        subnet_ids     = module.vpc.private_subnet_ids
        desired_size   = 1
        max_size       = 10
        min_size       = 0
        instance_types = ["t3.large", "t3.xlarge"]
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

    Default: {} (no node groups - cluster can run in Karpenter-only mode)
  EOT
  type = map(object({
    node_role_arn      = string
    subnet_ids         = list(string)
    desired_size       = number
    max_size           = number
    min_size           = number
    instance_types     = optional(list(string))
    capacity_type      = optional(string)
    disk_size          = optional(number)
    ami_type           = optional(string)
    kubernetes_version = optional(string)
    labels             = optional(map(string))
    taints = optional(list(object({
      key    = string
      value  = optional(string)
      effect = string
    })))
    update_config = optional(object({
      max_unavailable            = optional(number)
      max_unavailable_percentage = optional(number)
    }))
    remote_access = optional(object({
      ec2_ssh_key               = optional(string)
      source_security_group_ids = optional(list(string))
    }))
    launch_template = optional(object({
      id      = optional(string)
      name    = optional(string)
      version = optional(string)
    }))
    tags = optional(map(string))
  }))
  default = {}

  validation {
    condition = alltrue([
      for ng_key, ng_value in var.node_groups :
      ng_value.min_size <= ng_value.desired_size && ng_value.desired_size <= ng_value.max_size
    ])
    error_message = "For each node group, min_size must be <= desired_size <= max_size."
  }

  validation {
    condition = alltrue([
      for ng_key, ng_value in var.node_groups :
      contains(["ON_DEMAND", "SPOT"], coalesce(ng_value.capacity_type, "ON_DEMAND"))
    ])
    error_message = "Node group capacity_type must be either 'ON_DEMAND' or 'SPOT'."
  }

  validation {
    condition = alltrue([
      for ng_key, ng_value in var.node_groups :
      contains([
        "AL2_x86_64",
        "AL2_x86_64_GPU",
        "AL2_ARM_64",
        "BOTTLEROCKET_x86_64",
        "BOTTLEROCKET_ARM_64"
      ], coalesce(ng_value.ami_type, "AL2_x86_64"))
    ])
    error_message = "Node group ami_type must be one of: AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, BOTTLEROCKET_x86_64, BOTTLEROCKET_ARM_64."
  }
}

# -----------------------------------------------------------------------------
# Add-on Variables
# -----------------------------------------------------------------------------

variable "cluster_addons" {
  description = <<-EOT
    Map of EKS add-on configurations. Add-ons are operational software for providing key functionality for Kubernetes clusters.

    Common add-ons:
    - vpc-cni: Amazon VPC CNI plugin for pod networking (required)
    - kube-proxy: Kubernetes network proxy (required)
    - coredns: DNS server for service discovery (required)
    - aws-ebs-csi-driver: EBS CSI driver for persistent volumes (recommended for stateful workloads)

    Each add-on configuration includes:
    - addon_version: Version of the add-on (optional, defaults to EKS default version)
    - configuration_values: JSON configuration values for the add-on (optional)
    - resolve_conflicts_on_create: "OVERWRITE" or "NONE" (default: "OVERWRITE")
    - resolve_conflicts_on_update: "OVERWRITE", "NONE", or "PRESERVE" (default: "OVERWRITE")
    - service_account_role_arn: IAM role ARN for IRSA (optional, required for some add-ons like EBS CSI driver)
    - preserve: Preserve add-on resources when deleting the add-on (default: true)
    - tags: Additional tags for this add-on

    IRSA requirements:
    - Some add-ons require IRSA (aws-ebs-csi-driver, aws-efs-csi-driver, etc.)
    - Create the IAM role in terraform/iam/eks/ module
    - Pass the role ARN via service_account_role_arn

    Example 1 - Essential add-ons:
    cluster_addons = {
      vpc-cni = {
        addon_version = "v1.15.0-eksbuild.2"
      }
      kube-proxy = {
        addon_version = "v1.28.1-eksbuild.1"
      }
      coredns = {
        addon_version = "v1.10.1-eksbuild.2"
      }
    }

    Example 2 - With EBS CSI driver (requires IRSA):
    cluster_addons = {
      vpc-cni = {}
      kube-proxy = {}
      coredns = {}
      aws-ebs-csi-driver = {
        addon_version            = "v1.25.0-eksbuild.1"
        service_account_role_arn = module.eks_iam.ebs_csi_driver_role_arn
      }
    }

    Note: Add-on versions must be compatible with your cluster version. Check AWS documentation for version compatibility.

    Default: {} (no add-ons managed by Terraform - they can be installed separately)
  EOT
  type = map(object({
    addon_version               = optional(string)
    configuration_values        = optional(string)
    resolve_conflicts_on_create = optional(string)
    resolve_conflicts_on_update = optional(string)
    service_account_role_arn    = optional(string)
    preserve                    = optional(bool)
    tags                        = optional(map(string))
  }))
  default = {}
}

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "tags" {
  description = <<-EOT
    A map of tags to add to all resources. Use this to add consistent tagging across your infrastructure for cost allocation, environment identification, etc.

    Recommended tags:
    - Environment: production, staging, development
    - ManagedBy: terraform
    - Owner: team or individual responsible
    - CostCenter: for cost allocation
    - Project: project or application name

    Note: The "Name" tag is automatically added to resources with appropriate values (e.g., cluster name, node group name).
  EOT
  type        = map(string)
  default     = {}
}
