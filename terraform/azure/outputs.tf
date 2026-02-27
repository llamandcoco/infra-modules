# -----------------------------------------------------------------------------
# Storage Account Identification Outputs
# -----------------------------------------------------------------------------

output "storage_account_id" {
  description = "The ID of the storage account. Use this for resource references and configurations."
  value       = azurerm_storage_account.this.id
}

output "storage_account_name" {
  description = "The name of the storage account. Use this for accessing the storage account."
  value       = azurerm_storage_account.this.name
}

# -----------------------------------------------------------------------------
# Container Identification Outputs
# -----------------------------------------------------------------------------

output "container_id" {
  description = "The ID of the blob container."
  value       = azurerm_storage_container.this.id
}

output "container_name" {
  description = "The name of the blob container."
  value       = azurerm_storage_container.this.name
}

# -----------------------------------------------------------------------------
# Endpoint Outputs
# -----------------------------------------------------------------------------

output "primary_blob_endpoint" {
  description = "The primary blob service endpoint. Use this for accessing blobs in the storage account."
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_blob_host" {
  description = "The hostname for the primary blob service endpoint."
  value       = azurerm_storage_account.this.primary_blob_host
}

output "secondary_blob_endpoint" {
  description = "The secondary blob service endpoint. Available when geo-replication is enabled."
  value       = azurerm_storage_account.this.secondary_blob_endpoint
}

output "secondary_blob_host" {
  description = "The hostname for the secondary blob service endpoint. Available when geo-replication is enabled."
  value       = azurerm_storage_account.this.secondary_blob_host
}

# -----------------------------------------------------------------------------
# Access Key Outputs (Marked Sensitive)
# -----------------------------------------------------------------------------

output "primary_access_key" {
  description = "The primary access key for the storage account. Use this for authentication when accessing the storage account."
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "The secondary access key for the storage account. Use this for key rotation scenarios."
  value       = azurerm_storage_account.this.secondary_access_key
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Connection String Outputs (Marked Sensitive)
# -----------------------------------------------------------------------------

output "primary_connection_string" {
  description = "The primary connection string for the storage account. Use this for SDK and tool connections."
  value       = azurerm_storage_account.this.primary_connection_string
  sensitive   = true
}

output "secondary_connection_string" {
  description = "The secondary connection string for the storage account. Use this for failover scenarios."
  value       = azurerm_storage_account.this.secondary_connection_string
  sensitive   = true
}

output "primary_blob_connection_string" {
  description = "The primary blob service connection string. Use this for blob-specific SDK connections."
  value       = azurerm_storage_account.this.primary_blob_connection_string
  sensitive   = true
}

output "secondary_blob_connection_string" {
  description = "The secondary blob service connection string. Use this for blob-specific failover scenarios."
  value       = azurerm_storage_account.this.secondary_blob_connection_string
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Configuration Outputs
# -----------------------------------------------------------------------------

output "location" {
  description = "The Azure region where the storage account is deployed."
  value       = azurerm_storage_account.this.location
}

output "account_tier" {
  description = "The tier of the storage account (Standard or Premium)."
  value       = azurerm_storage_account.this.account_tier
}

output "replication_type" {
  description = "The replication type of the storage account."
  value       = azurerm_storage_account.this.account_replication_type
}

output "account_kind" {
  description = "The kind of the storage account."
  value       = azurerm_storage_account.this.account_kind
}

# -----------------------------------------------------------------------------
# Security Outputs
# -----------------------------------------------------------------------------

output "versioning_enabled" {
  description = "Whether blob versioning is enabled. Important for compliance and data protection verification."
  value       = var.versioning_enabled
}

output "https_traffic_only" {
  description = "Whether HTTPS-only traffic is enforced."
  value       = var.enable_https_traffic_only
}

output "min_tls_version" {
  description = "The minimum TLS version required for requests."
  value       = azurerm_storage_account.this.min_tls_version
}

output "infrastructure_encryption_enabled" {
  description = "Whether infrastructure encryption is enabled for additional security."
  value       = azurerm_storage_account.this.infrastructure_encryption_enabled
}

# -----------------------------------------------------------------------------
# Identity Outputs
# -----------------------------------------------------------------------------

output "identity" {
  description = "The managed identity configuration of the storage account."
  value       = try(azurerm_storage_account.this.identity[0], null)
}

# -----------------------------------------------------------------------------
# Reference Outputs
# -----------------------------------------------------------------------------

output "resource_group_name" {
  description = "The name of the resource group containing the storage account."
  value       = azurerm_storage_account.this.resource_group_name
}

output "tags" {
  description = "All tags applied to the storage account, including default and custom tags."
  value       = azurerm_storage_account.this.tags
}
