terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

# TLS certificate for OIDC provider thumbprint
data "tls_certificate" "cluster" {
  count = var.enable_oidc_provider ? 1 : 0
  url   = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# -----------------------------------------------------------------------------
# CloudWatch Log Group
# -----------------------------------------------------------------------------

# CloudWatch Log Group for EKS control plane logs
# Stores cluster logs for monitoring and troubleshooting
resource "aws_cloudwatch_log_group" "this" {
  count = length(var.cluster_enabled_log_types) > 0 ? 1 : 0

  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.cloudwatch_log_retention_days
  kms_key_id        = var.cloudwatch_log_kms_key_id

  tags = merge(
    var.tags,
    {
      Name = "/aws/eks/${var.cluster_name}/cluster"
    }
  )
}

# -----------------------------------------------------------------------------
# EKS Cluster IAM Role
# -----------------------------------------------------------------------------

# IAM role for the EKS control plane
# This role allows the EKS service to manage cluster resources
resource "aws_iam_role" "cluster" {
  name               = "${var.cluster_name}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role.json

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-eks-cluster-role"
    }
  )
}

# Trust policy for EKS cluster role
# Allows the EKS service to assume this role
data "aws_iam_policy_document" "cluster_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Attach the EKS cluster policy to the cluster role
# This policy provides permissions for EKS to manage resources
resource "aws_iam_role_policy_attachment" "cluster_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# Attach the EKS VPC resource controller policy to the cluster role
# This policy provides permissions for EKS to manage VPC resources (security groups, ENIs)
resource "aws_iam_role_policy_attachment" "cluster_eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

# -----------------------------------------------------------------------------
# EKS Cluster
# -----------------------------------------------------------------------------

# EKS Cluster
# Creates the Kubernetes control plane and API server
# tfsec:ignore:aws-eks-enable-control-plane-logging - Logging is configurable via cluster_enabled_log_types variable
# tfsec:ignore:aws-eks-encrypt-secrets - Encryption is configurable via encryption_config variable
# tfsec:ignore:AVD-AWS-0040 - Public access is configurable via endpoint_public_access variable (test environments may require it)
# tfsec:ignore:AVD-AWS-0041 - Public access CIDRs are configurable via endpoint_public_access_cidrs variable (test environments use 0.0.0.0/0)
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn

  # VPC Configuration
  # Defines the network configuration for the cluster
  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.endpoint_public_access_cidrs
    security_group_ids      = var.additional_security_group_ids
  }

  # Cluster Logging Configuration
  # Enables control plane logs to CloudWatch
  enabled_cluster_log_types = var.cluster_enabled_log_types

  # Encryption Configuration for Secrets
  # Uses KMS to encrypt Kubernetes secrets at rest
  dynamic "encryption_config" {
    for_each = var.encryption_config_kms_key_arn != null ? [1] : []
    content {
      provider {
        key_arn = var.encryption_config_kms_key_arn
      }
      resources = ["secrets"]
    }
  }

  # Access Configuration (AWS Provider v5.x)
  # Defines authentication mode for the cluster
  access_config {
    authentication_mode                         = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin_permissions
  }

  # Ensure CloudWatch log group is created before the cluster
  depends_on = [
    aws_cloudwatch_log_group.this,
    aws_iam_role_policy_attachment.cluster_eks_cluster_policy,
    aws_iam_role_policy_attachment.cluster_eks_vpc_resource_controller,
  ]

  tags = merge(
    var.tags,
    {
      Name = var.cluster_name
    }
  )
}

# -----------------------------------------------------------------------------
# EKS Cluster Access Entries (Optional)
# -----------------------------------------------------------------------------

# EKS access entries for additional IAM principals
# Provides fine-grained access control for cluster API access
resource "aws_eks_access_entry" "this" {
  for_each = var.access_entries

  cluster_name      = aws_eks_cluster.this.name
  principal_arn     = each.value.principal_arn
  kubernetes_groups = try(each.value.kubernetes_groups, null)
  type              = try(each.value.type, "STANDARD")

  tags = merge(
    var.tags,
    try(each.value.tags, {}),
    {
      Name = "${var.cluster_name}-${each.key}"
    }
  )
}

# EKS access policy associations for access entries
# Associates AWS managed policies with access entries
resource "aws_eks_access_policy_association" "this" {
  for_each = {
    for item in flatten([
      for entry_key, entry_value in var.access_entries : [
        for policy in try(entry_value.access_policies, []) : {
          entry_key  = entry_key
          policy_arn = policy.policy_arn
          access_scope = {
            type       = try(policy.access_scope.type, "cluster")
            namespaces = try(policy.access_scope.namespaces, null)
          }
        }
      ]
    ]) : "${item.entry_key}-${basename(item.policy_arn)}" => item
  }

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.access_entries[each.value.entry_key].principal_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type       = each.value.access_scope.type
    namespaces = each.value.access_scope.namespaces
  }

  depends_on = [
    aws_eks_access_entry.this,
  ]
}

# -----------------------------------------------------------------------------
# EKS Managed Node Groups (Optional)
# -----------------------------------------------------------------------------

# EKS Managed Node Groups
# Provides managed compute capacity for the cluster
# NOTE: Node IAM roles must be created separately (terraform/iam/eks/) and passed via node_groups[*].node_role_arn
resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.key
  node_role_arn   = each.value.node_role_arn
  subnet_ids      = each.value.subnet_ids
  version         = try(each.value.kubernetes_version, var.cluster_version)

  # Scaling Configuration
  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  # Update Configuration
  dynamic "update_config" {
    for_each = try(each.value.update_config, null) != null ? [each.value.update_config] : []
    content {
      max_unavailable_percentage = try(update_config.value.max_unavailable_percentage, null)
      max_unavailable            = try(update_config.value.max_unavailable, null)
    }
  }

  # Instance Configuration
  capacity_type  = try(each.value.capacity_type, "ON_DEMAND")
  instance_types = try(each.value.instance_types, ["t3.medium"])
  disk_size      = try(each.value.disk_size, null)
  ami_type       = try(each.value.ami_type, "AL2_x86_64")

  # Remote Access Configuration (Optional)
  dynamic "remote_access" {
    for_each = try(each.value.remote_access, null) != null ? [each.value.remote_access] : []
    content {
      ec2_ssh_key               = try(remote_access.value.ec2_ssh_key, null)
      source_security_group_ids = try(remote_access.value.source_security_group_ids, null)
    }
  }

  # Launch Template Configuration (Optional)
  dynamic "launch_template" {
    for_each = try(each.value.launch_template, null) != null ? [each.value.launch_template] : []
    content {
      id      = try(launch_template.value.id, null)
      name    = try(launch_template.value.name, null)
      version = try(launch_template.value.version, "$Latest")
    }
  }

  # Kubernetes Labels
  labels = try(each.value.labels, null)

  # Kubernetes Taints
  dynamic "taint" {
    for_each = coalesce(each.value.taints, [])
    content {
      key    = taint.value.key
      value  = coalesce(taint.value.value, null)
      effect = taint.value.effect
    }
  }

  tags = merge(
    var.tags,
    try(each.value.tags, {}),
    {
      Name = "${var.cluster_name}-${each.key}"
    }
  )

  # Ensure the cluster is fully created before creating node groups
  depends_on = [
    aws_eks_cluster.this,
  ]

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      scaling_config[0].desired_size
    ]
  }
}

# -----------------------------------------------------------------------------
# EKS Add-ons (Optional)
# -----------------------------------------------------------------------------

# EKS Add-ons
# Deploys and manages official EKS add-ons (vpc-cni, kube-proxy, coredns, etc.)
resource "aws_eks_addon" "this" {
  for_each = var.cluster_addons

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.key
  addon_version               = try(each.value.addon_version, null)
  configuration_values        = try(each.value.configuration_values, null)
  resolve_conflicts_on_create = try(each.value.resolve_conflicts_on_create, "OVERWRITE")
  resolve_conflicts_on_update = try(each.value.resolve_conflicts_on_update, "OVERWRITE")
  service_account_role_arn    = try(each.value.service_account_role_arn, null)
  preserve                    = try(each.value.preserve, true)

  tags = merge(
    var.tags,
    try(each.value.tags, {}),
    {
      Name = "${var.cluster_name}-${each.key}"
    }
  )

  depends_on = [
    aws_eks_cluster.this,
    aws_eks_node_group.this,
  ]
}
