# -----------------------------------------------------------------------------
# OIDC Provider for IAM Roles for Service Accounts (IRSA)
# -----------------------------------------------------------------------------

# OIDC Identity Provider
# Enables IAM Roles for Service Accounts (IRSA) by creating an OIDC provider that trusts the EKS cluster
#
# What is IRSA?
# - IRSA allows Kubernetes service accounts to assume IAM roles
# - Provides fine-grained IAM permissions to pods without using instance profiles
# - More secure than sharing IAM credentials or using node IAM roles
#
# How it works:
# 1. EKS cluster issues OIDC tokens to service accounts
# 2. IAM roles trust the OIDC provider (created by this resource)
# 3. Pods with annotated service accounts can assume IAM roles
# 4. AWS SDKs in pods automatically use the assumed role credentials
#
# Integration with terraform/iam/eks/:
# - This module outputs oidc_provider_arn and oidc_provider_url
# - Use terraform/iam/eks/ module to create IAM roles that trust this OIDC provider
# - IAM roles reference the OIDC provider ARN in their trust policy
#
# Example IAM role trust policy for IRSA (created in terraform/iam/eks/):
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/OIDC_PROVIDER_URL"
#       },
#       "Action": "sts:AssumeRoleWithWebIdentity",
#       "Condition": {
#         "StringEquals": {
#           "OIDC_PROVIDER_URL:sub": "system:serviceaccount:NAMESPACE:SERVICE_ACCOUNT_NAME",
#           "OIDC_PROVIDER_URL:aud": "sts.amazonaws.com"
#         }
#       }
#     }
#   ]
# }
#
# Example Kubernetes service account annotation (for using IRSA):
# apiVersion: v1
# kind: ServiceAccount
# metadata:
#   name: my-service-account
#   namespace: my-namespace
#   annotations:
#     eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT_ID:role/my-irsa-role
#
resource "aws_iam_openid_connect_provider" "this" {
  count = var.enable_oidc_provider ? 1 : 0

  # The OIDC provider URL from the EKS cluster
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer

  # Client IDs that can authenticate with this OIDC provider
  # sts.amazonaws.com is required for IRSA to work
  client_id_list = ["sts.amazonaws.com"]

  # Thumbprint of the OIDC provider's TLS certificate
  # Used to verify the authenticity of the OIDC provider
  thumbprint_list = [data.tls_certificate.cluster[0].certificates[0].sha1_fingerprint]

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-eks-oidc-provider"
    }
  )
}
