# -----------------------------------------------------------------------------
# Cluster Identification Outputs
# -----------------------------------------------------------------------------

output "cluster_name" {
  description = "The name of the EKS cluster. Use this to reference the cluster in kubectl, Helm, and other Kubernetes tools."
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster. Use this for IAM policies, resource tagging, and cross-account access configurations."
  value       = aws_eks_cluster.this.arn
}

output "cluster_id" {
  description = "The ID of the EKS cluster. This is the same as the cluster name."
  value       = aws_eks_cluster.this.id
}

# -----------------------------------------------------------------------------
# Cluster Endpoint and Certificate Outputs
# -----------------------------------------------------------------------------

output "cluster_endpoint" {
  description = <<-EOT
    The endpoint URL for the EKS cluster API server. Use this to configure kubectl and other Kubernetes clients.
    This endpoint respects the endpoint_private_access and endpoint_public_access settings.
  EOT
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = <<-EOT
    Base64 encoded certificate data required to communicate with the cluster.
    Use this when configuring kubectl or other Kubernetes clients. This is sensitive data that should be handled securely.
  EOT
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Cluster Version and Platform Outputs
# -----------------------------------------------------------------------------

output "cluster_version" {
  description = "The Kubernetes version running on the cluster. Important for compatibility checks when deploying workloads or upgrading."
  value       = aws_eks_cluster.this.version
}

output "cluster_platform_version" {
  description = "The platform version of the EKS cluster. AWS updates the platform version to provide new features and security patches."
  value       = aws_eks_cluster.this.platform_version
}

# -----------------------------------------------------------------------------
# Cluster IAM Role Outputs
# -----------------------------------------------------------------------------

output "cluster_iam_role_arn" {
  description = "The ARN of the IAM role used by the EKS control plane. This role has permissions to manage cluster resources."
  value       = aws_iam_role.cluster.arn
}

output "cluster_iam_role_name" {
  description = "The name of the IAM role used by the EKS control plane."
  value       = aws_iam_role.cluster.name
}

# -----------------------------------------------------------------------------
# Cluster Security Group Outputs
# -----------------------------------------------------------------------------

output "cluster_security_group_id" {
  description = <<-EOT
    The security group ID created by EKS for the cluster. This security group controls communication between the control plane and worker nodes.
    Use this to configure additional security group rules if needed.
  EOT
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

# -----------------------------------------------------------------------------
# OIDC Provider Outputs (for IRSA)
# -----------------------------------------------------------------------------

output "oidc_provider_arn" {
  description = <<-EOT
    The ARN of the OIDC identity provider for the cluster. Use this when creating IAM roles for service accounts (IRSA) in terraform/iam/eks/.
    IAM roles that trust this OIDC provider can be assumed by Kubernetes service accounts.
    Only available if enable_oidc_provider is true.
  EOT
  value       = var.enable_oidc_provider ? aws_iam_openid_connect_provider.this[0].arn : null
}

output "oidc_provider_url" {
  description = <<-EOT
    The URL of the OIDC identity provider for the cluster (without https:// prefix).
    Use this when configuring trust relationships for IRSA IAM roles in terraform/iam/eks/.
    Example trust policy condition: "OIDC_PROVIDER_URL:sub": "system:serviceaccount:NAMESPACE:SERVICE_ACCOUNT_NAME"
    Only available if enable_oidc_provider is true.
  EOT
  value       = var.enable_oidc_provider ? replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "") : null
}

# -----------------------------------------------------------------------------
# Node Group Outputs
# -----------------------------------------------------------------------------

output "node_groups" {
  description = <<-EOT
    Map of node group attributes including IDs, ARNs, and status. Use this to reference node groups in other resources or for monitoring.
    Contains information about all managed node groups created by this module.
  EOT
  value = {
    for ng_key, ng_value in aws_eks_node_group.this : ng_key => {
      id                  = ng_value.id
      arn                 = ng_value.arn
      status              = ng_value.status
      capacity_type       = ng_value.capacity_type
      node_group_name     = ng_value.node_group_name
      resources           = ng_value.resources
      remote_access_sg_id = try(ng_value.resources[0].remote_access_security_group_id, null)
    }
  }
}

output "node_group_ids" {
  description = "List of node group IDs. Use this for scripting and automation that needs to reference all node groups."
  value       = [for ng in aws_eks_node_group.this : ng.id]
}

output "node_group_arns" {
  description = "List of node group ARNs. Use this for IAM policies or resource tagging."
  value       = [for ng in aws_eks_node_group.this : ng.arn]
}

output "node_group_statuses" {
  description = "Map of node group names to their current status. Use this for health checks and monitoring. Possible values: CREATING, ACTIVE, UPDATING, DELETING, CREATE_FAILED, DELETE_FAILED, DEGRADED."
  value       = { for ng_key, ng_value in aws_eks_node_group.this : ng_key => ng_value.status }
}

# -----------------------------------------------------------------------------
# Add-on Outputs
# -----------------------------------------------------------------------------

output "cluster_addons" {
  description = <<-EOT
    Map of cluster add-on attributes including ARNs, versions, and status. Use this to verify add-on versions and health.
    Contains information about all add-ons managed by this module.
  EOT
  value = {
    for addon_key, addon_value in aws_eks_addon.this : addon_key => {
      id                       = addon_value.id
      arn                      = addon_value.arn
      addon_version            = addon_value.addon_version
      service_account_role_arn = addon_value.service_account_role_arn
      configuration_values     = addon_value.configuration_values
      created_at               = addon_value.created_at
      modified_at              = addon_value.modified_at
    }
  }
}

output "cluster_addon_arns" {
  description = "List of cluster add-on ARNs."
  value       = [for addon in aws_eks_addon.this : addon.arn]
}

output "cluster_addon_versions" {
  description = "Map of add-on names to their current versions. Use this to track add-on versions for compatibility and upgrade planning."
  value       = { for addon_key, addon_value in aws_eks_addon.this : addon_key => addon_value.addon_version }
}

# -----------------------------------------------------------------------------
# CloudWatch Log Group Outputs
# -----------------------------------------------------------------------------

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for cluster logs. Use this to query logs or configure log processing."
  value       = length(var.cluster_enabled_log_types) > 0 ? aws_cloudwatch_log_group.this[0].name : null
}

output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch log group for cluster logs."
  value       = length(var.cluster_enabled_log_types) > 0 ? aws_cloudwatch_log_group.this[0].arn : null
}

# -----------------------------------------------------------------------------
# Cluster Configuration Outputs
# -----------------------------------------------------------------------------

output "cluster_authentication_mode" {
  description = "The authentication mode configured for the cluster (CONFIG_MAP, API, or API_AND_CONFIG_MAP)."
  value       = var.authentication_mode
}

output "cluster_endpoint_public_access" {
  description = "Whether the cluster API endpoint is publicly accessible."
  value       = aws_eks_cluster.this.vpc_config[0].endpoint_public_access
}

output "cluster_endpoint_private_access" {
  description = "Whether the cluster API endpoint has private access enabled."
  value       = aws_eks_cluster.this.vpc_config[0].endpoint_private_access
}

output "cluster_enabled_log_types" {
  description = "List of enabled control plane log types."
  value       = var.cluster_enabled_log_types
}

output "cluster_encryption_enabled" {
  description = "Whether Kubernetes secrets encryption is enabled."
  value       = var.encryption_config_kms_key_arn != null
}

output "cluster_encryption_kms_key_arn" {
  description = "The ARN of the KMS key used for secrets encryption, if enabled."
  value       = var.encryption_config_kms_key_arn
}

# -----------------------------------------------------------------------------
# Access Entry Outputs
# -----------------------------------------------------------------------------

output "access_entries" {
  description = <<-EOT
    Map of access entry attributes. Use this to reference access entries for monitoring or verification.
    Only relevant when authentication_mode is "API" or "API_AND_CONFIG_MAP".
  EOT
  value = {
    for entry_key, entry_value in aws_eks_access_entry.this : entry_key => {
      access_entry_arn  = entry_value.access_entry_arn
      principal_arn     = entry_value.principal_arn
      kubernetes_groups = entry_value.kubernetes_groups
      type              = entry_value.type
      created_at        = entry_value.created_at
      modified_at       = entry_value.modified_at
    }
  }
}

# -----------------------------------------------------------------------------
# Reference Outputs
# -----------------------------------------------------------------------------

output "tags" {
  description = "All tags applied to the cluster, including default and custom tags."
  value       = aws_eks_cluster.this.tags_all
}
