terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Storage Account
# Required for Azure Functions to store function app data
# tfsec:ignore:azure-storage-default-action-deny - Network rules are optional and configurable
resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  min_tls_version          = "TLS1_2"

  tags = merge(
    var.tags,
    {
      Name = var.storage_account_name
    }
  )
}

# Service Plan
# Defines the compute resources for the Function App
resource "azurerm_service_plan" "this" {
  name                = var.app_service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.os_type
  sku_name            = var.sku_name

  tags = merge(
    var.tags,
    {
      Name = var.app_service_plan_name
    }
  )
}

# Application Insights
# Provides monitoring and diagnostics for the Function App
resource "azurerm_application_insights" "this" {
  count               = var.enable_application_insights ? 1 : 0
  name                = var.application_insights_name != null ? var.application_insights_name : "${var.function_app_name}-insights"
  resource_group_name = var.resource_group_name
  location            = var.location
  application_type    = var.application_insights_type

  tags = merge(
    var.tags,
    {
      Name = var.application_insights_name != null ? var.application_insights_name : "${var.function_app_name}-insights"
    }
  )
}

# Linux Function App
# Creates the Function App on Linux
resource "azurerm_linux_function_app" "this" {
  count                      = var.os_type == "Linux" ? 1 : 0
  name                       = var.function_app_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key
  service_plan_id            = azurerm_service_plan.this.id

  site_config {
    application_insights_key               = var.enable_application_insights ? azurerm_application_insights.this[0].instrumentation_key : null
    application_insights_connection_string = var.enable_application_insights ? azurerm_application_insights.this[0].connection_string : null

    dynamic "application_stack" {
      for_each = var.runtime_stack != null ? [1] : []

      content {
        dotnet_version              = var.runtime_stack == "dotnet" ? var.runtime_version : null
        use_dotnet_isolated_runtime = var.runtime_stack == "dotnet" && var.use_dotnet_isolated_runtime ? true : null
        java_version                = var.runtime_stack == "java" ? var.runtime_version : null
        node_version                = var.runtime_stack == "node" ? var.runtime_version : null
        python_version              = var.runtime_stack == "python" ? var.runtime_version : null
        powershell_core_version     = var.runtime_stack == "powershell" ? var.runtime_version : null
      }
    }

    minimum_tls_version = var.minimum_tls_version
    http2_enabled       = var.http2_enabled
    ftps_state          = var.ftps_state

    dynamic "cors" {
      for_each = length(var.cors_allowed_origins) > 0 ? [1] : []

      content {
        allowed_origins     = var.cors_allowed_origins
        support_credentials = var.cors_support_credentials
      }
    }
  }

  app_settings = merge(
    var.app_settings,
    var.enable_application_insights ? {
      "APPLICATIONINSIGHTS_CONNECTION_STRING"      = azurerm_application_insights.this[0].connection_string
      "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    } : {}
  )

  https_only = var.https_only

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []

    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned" ? var.identity_ids : null
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.function_app_name
    }
  )
}

# Windows Function App
# Creates the Function App on Windows
resource "azurerm_windows_function_app" "this" {
  count                      = var.os_type == "Windows" ? 1 : 0
  name                       = var.function_app_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key
  service_plan_id            = azurerm_service_plan.this.id

  site_config {
    application_insights_key               = var.enable_application_insights ? azurerm_application_insights.this[0].instrumentation_key : null
    application_insights_connection_string = var.enable_application_insights ? azurerm_application_insights.this[0].connection_string : null

    dynamic "application_stack" {
      for_each = var.runtime_stack != null ? [1] : []

      content {
        dotnet_version              = var.runtime_stack == "dotnet" ? var.runtime_version : null
        use_dotnet_isolated_runtime = var.runtime_stack == "dotnet" && var.use_dotnet_isolated_runtime ? true : null
        java_version                = var.runtime_stack == "java" ? var.runtime_version : null
        node_version                = var.runtime_stack == "node" ? var.runtime_version : null
        powershell_core_version     = var.runtime_stack == "powershell" ? var.runtime_version : null
      }
    }

    minimum_tls_version = var.minimum_tls_version
    http2_enabled       = var.http2_enabled
    ftps_state          = var.ftps_state

    dynamic "cors" {
      for_each = length(var.cors_allowed_origins) > 0 ? [1] : []

      content {
        allowed_origins     = var.cors_allowed_origins
        support_credentials = var.cors_support_credentials
      }
    }
  }

  app_settings = merge(
    var.app_settings,
    var.enable_application_insights ? {
      "APPLICATIONINSIGHTS_CONNECTION_STRING"      = azurerm_application_insights.this[0].connection_string
      "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    } : {}
  )

  https_only = var.https_only

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []

    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned" ? var.identity_ids : null
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.function_app_name
    }
  )
}
