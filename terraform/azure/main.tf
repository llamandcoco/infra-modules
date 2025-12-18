terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Storage Account
# Creates the main Azure Storage Account for blob storage
resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.replication_type
  account_kind             = var.account_kind

  # Security: Enable HTTPS-only traffic by default
  enable_https_traffic_only = var.enable_https_traffic_only

  # Security: Minimum TLS version
  min_tls_version = var.min_tls_version

  # Security: Disable public blob access by default
  allow_nested_items_to_be_public = var.allow_public_access

  # Enable infrastructure encryption for additional security
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled

  # Versioning for blob storage
  blob_properties {
    versioning_enabled = var.versioning_enabled

    # Blob soft delete
    dynamic "delete_retention_policy" {
      for_each = var.blob_soft_delete_retention_days > 0 ? [1] : []
      content {
        days = var.blob_soft_delete_retention_days
      }
    }

    # Container soft delete
    dynamic "container_delete_retention_policy" {
      for_each = var.container_soft_delete_retention_days > 0 ? [1] : []
      content {
        days = var.container_soft_delete_retention_days
      }
    }

    # Change feed for tracking changes
    change_feed_enabled = var.change_feed_enabled

    # Last access time tracking for lifecycle management
    last_access_time_enabled = var.last_access_time_enabled
  }

  # Network rules for security
  dynamic "network_rules" {
    for_each = var.network_rules_enabled ? [1] : []
    content {
      default_action             = var.network_rules_default_action
      bypass                     = var.network_rules_bypass
      ip_rules                   = var.network_rules_ip_rules
      virtual_network_subnet_ids = var.network_rules_subnet_ids
    }
  }

  # Customer-managed key encryption
  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key_vault_key_id != null ? [1] : []
    content {
      key_vault_key_id          = var.customer_managed_key_vault_key_id
      user_assigned_identity_id = var.customer_managed_key_user_assigned_identity_id
    }
  }

  # Identity for customer-managed keys
  dynamic "identity" {
    for_each = var.customer_managed_key_vault_key_id != null ? [1] : []
    content {
      type         = var.customer_managed_key_user_assigned_identity_id != null ? "UserAssigned" : "SystemAssigned"
      identity_ids = var.customer_managed_key_user_assigned_identity_id != null ? [var.customer_managed_key_user_assigned_identity_id] : null
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.storage_account_name
    }
  )
}

# Blob Container
# Creates the blob container within the storage account
resource "azurerm_storage_container" "this" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = var.container_access_type

  # Container metadata
  metadata = var.container_metadata
}

# Lifecycle Management Policy
# Manages blob lifecycle for cost optimization
resource "azurerm_storage_management_policy" "this" {
  count = length(var.lifecycle_rules) > 0 ? 1 : 0

  storage_account_id = azurerm_storage_account.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      name    = rule.value.name
      enabled = rule.value.enabled

      filters {
        prefix_match = rule.value.prefix_match
        blob_types   = rule.value.blob_types
      }

      actions {
        # Base blob actions
        dynamic "base_blob" {
          for_each = rule.value.base_blob_actions != null ? [rule.value.base_blob_actions] : []

          content {
            tier_to_cool_after_days_since_modification_greater_than        = base_blob.value.tier_to_cool_after_days
            tier_to_cool_after_days_since_last_access_time_greater_than    = base_blob.value.tier_to_cool_after_last_access_days
            tier_to_archive_after_days_since_modification_greater_than     = base_blob.value.tier_to_archive_after_days
            tier_to_archive_after_days_since_last_access_time_greater_than = base_blob.value.tier_to_archive_after_last_access_days
            delete_after_days_since_modification_greater_than              = base_blob.value.delete_after_days
            delete_after_days_since_last_access_time_greater_than          = base_blob.value.delete_after_last_access_days
          }
        }

        # Snapshot actions
        dynamic "snapshot" {
          for_each = rule.value.snapshot_actions != null ? [rule.value.snapshot_actions] : []

          content {
            change_tier_to_archive_after_days_since_creation = snapshot.value.tier_to_archive_after_days
            change_tier_to_cool_after_days_since_creation    = snapshot.value.tier_to_cool_after_days
            delete_after_days_since_creation_greater_than    = snapshot.value.delete_after_days
          }
        }

        # Version actions (for versioned blobs)
        dynamic "version" {
          for_each = rule.value.version_actions != null ? [rule.value.version_actions] : []

          content {
            change_tier_to_archive_after_days_since_creation = version.value.tier_to_archive_after_days
            change_tier_to_cool_after_days_since_creation    = version.value.tier_to_cool_after_days
            delete_after_days_since_creation                 = version.value.delete_after_days
          }
        }
      }
    }
  }
}
