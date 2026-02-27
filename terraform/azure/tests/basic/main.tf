terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Azure provider configuration for testing
# Note: Unlike AWS, Azure requires valid credentials to run terraform plan
# Use Azure CLI authentication: az login
# Or set environment variables: ARM_SUBSCRIPTION_ID, ARM_TENANT_ID, ARM_CLIENT_ID, ARM_CLIENT_SECRET
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# Mock resource group for testing
resource "azurerm_resource_group" "test" {
  name     = "test-rg"
  location = "eastus"
}

# -----------------------------------------------------------------------------
# Test 1: Basic storage account with default security settings
# -----------------------------------------------------------------------------

module "basic_storage" {
  source = "../../"

  storage_account_name = "basictest123"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  container_name       = "basic-container"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "basic-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 2: Storage account with customer-managed encryption
# -----------------------------------------------------------------------------

module "cmk_storage" {
  source = "../../"

  storage_account_name = "cmktest123"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  container_name       = "cmk-container"

  # Mock Key Vault key ID for testing
  customer_managed_key_vault_key_id = "https://test-keyvault.vault.azure.net/keys/test-key/12345678901234567890123456789012"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "cmk-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 3: Storage account with lifecycle rules
# -----------------------------------------------------------------------------

module "lifecycle_storage" {
  source = "../../"

  storage_account_name = "lifecycletest123"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  container_name       = "lifecycle-container"

  # Enable last access time tracking
  last_access_time_enabled = true

  lifecycle_rules = [
    {
      name         = "archive-logs"
      enabled      = true
      prefix_match = ["logs/"]
      blob_types   = ["blockBlob"]

      base_blob_actions = {
        tier_to_cool_after_days    = 30
        tier_to_archive_after_days = 90
        delete_after_days          = 365
      }

      snapshot_actions = {
        tier_to_archive_after_days = 30
        delete_after_days          = 90
      }

      version_actions = {
        tier_to_archive_after_days = 30
        delete_after_days          = 90
      }
    },
    {
      name         = "cleanup-temp"
      enabled      = true
      prefix_match = ["temp/"]
      blob_types   = ["blockBlob"]

      base_blob_actions = {
        delete_after_days = 7
      }
    },
    {
      name         = "archive-by-access"
      enabled      = true
      prefix_match = ["documents/"]
      blob_types   = ["blockBlob"]

      base_blob_actions = {
        tier_to_cool_after_last_access_days    = 60
        tier_to_archive_after_last_access_days = 180
      }
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "lifecycle-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 4: Storage account with network restrictions
# -----------------------------------------------------------------------------

module "restricted_storage" {
  source = "../../"

  storage_account_name = "restrictedtest123"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  container_name       = "restricted-container"

  # Enable network rules
  network_rules_enabled        = true
  network_rules_default_action = "Deny"
  network_rules_bypass         = ["AzureServices", "Logging"]

  # Mock IP rules for testing
  network_rules_ip_rules = [
    "203.0.113.0/24",
    "198.51.100.42"
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "network-restriction-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 5: Storage account with geo-replication
# -----------------------------------------------------------------------------

module "geo_storage" {
  source = "../../"

  storage_account_name = "geotest123"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  container_name       = "geo-container"

  # Enable geo-redundant replication
  replication_type = "RAGRS"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "geo-replication-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 6: Storage account with versioning disabled and no soft delete
# -----------------------------------------------------------------------------

module "minimal_storage" {
  source = "../../"

  storage_account_name = "minimaltest123"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  container_name       = "minimal-container"

  # Disable optional features
  versioning_enabled                   = false
  blob_soft_delete_retention_days      = 0
  container_soft_delete_retention_days = 0
  infrastructure_encryption_enabled    = false

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "minimal-config-testing"
  }
}

# -----------------------------------------------------------------------------
# Test Outputs
# -----------------------------------------------------------------------------

output "basic_storage_account_id" {
  description = "ID of the basic test storage account"
  value       = module.basic_storage.storage_account_id
}

output "basic_storage_account_name" {
  description = "Name of the basic test storage account"
  value       = module.basic_storage.storage_account_name
}

output "basic_container_id" {
  description = "ID of the basic test container"
  value       = module.basic_storage.container_id
}

output "basic_primary_blob_endpoint" {
  description = "Primary blob endpoint of the basic test storage account"
  value       = module.basic_storage.primary_blob_endpoint
}

output "cmk_storage_account_name" {
  description = "Name of the CMK test storage account"
  value       = module.cmk_storage.storage_account_name
}

output "lifecycle_storage_account_name" {
  description = "Name of the lifecycle test storage account"
  value       = module.lifecycle_storage.storage_account_name
}

output "geo_storage_replication_type" {
  description = "Replication type of the geo test storage account"
  value       = module.geo_storage.replication_type
}

output "minimal_storage_versioning_enabled" {
  description = "Versioning status of the minimal test storage account"
  value       = module.minimal_storage.versioning_enabled
}
