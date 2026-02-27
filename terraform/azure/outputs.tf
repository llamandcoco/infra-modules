# -----------------------------------------------------------------------------
# Function App Identification Outputs
# -----------------------------------------------------------------------------

output "function_app_id" {
  description = "The ID of the Function App. Use this for resource references and dependencies."
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.this[0].id : azurerm_windows_function_app.this[0].id
}

output "function_app_name" {
  description = "The name of the Function App."
  value       = var.function_app_name
}

# -----------------------------------------------------------------------------
# Function App Endpoint Outputs
# -----------------------------------------------------------------------------

output "default_hostname" {
  description = "The default hostname of the Function App. Use this to access your functions via HTTPS."
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.this[0].default_hostname : azurerm_windows_function_app.this[0].default_hostname
}

output "outbound_ip_addresses" {
  description = "A comma-separated list of outbound IP addresses used by the Function App."
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.this[0].outbound_ip_addresses : azurerm_windows_function_app.this[0].outbound_ip_addresses
}

output "possible_outbound_ip_addresses" {
  description = "A comma-separated list of possible outbound IP addresses. Use this for firewall allowlisting."
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.this[0].possible_outbound_ip_addresses : azurerm_windows_function_app.this[0].possible_outbound_ip_addresses
}

# -----------------------------------------------------------------------------
# Identity Outputs
# -----------------------------------------------------------------------------

output "identity_principal_id" {
  description = "The Principal ID of the System Assigned Managed Identity. Use this to grant permissions to Azure resources."
  value       = var.identity_type != null && contains(["SystemAssigned", "SystemAssigned, UserAssigned"], var.identity_type) ? (var.os_type == "Linux" ? azurerm_linux_function_app.this[0].identity[0].principal_id : azurerm_windows_function_app.this[0].identity[0].principal_id) : null
}

output "identity_tenant_id" {
  description = "The Tenant ID of the System Assigned Managed Identity."
  value       = var.identity_type != null && contains(["SystemAssigned", "SystemAssigned, UserAssigned"], var.identity_type) ? (var.os_type == "Linux" ? azurerm_linux_function_app.this[0].identity[0].tenant_id : azurerm_windows_function_app.this[0].identity[0].tenant_id) : null
}

# -----------------------------------------------------------------------------
# Storage Account Outputs
# -----------------------------------------------------------------------------

output "storage_account_id" {
  description = "The ID of the Storage Account used by the Function App."
  value       = azurerm_storage_account.this.id
}

output "storage_account_name" {
  description = "The name of the Storage Account used by the Function App."
  value       = azurerm_storage_account.this.name
}

output "storage_account_primary_connection_string" {
  description = "The primary connection string for the Storage Account. Sensitive - handle with care."
  value       = azurerm_storage_account.this.primary_connection_string
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Service Plan Outputs
# -----------------------------------------------------------------------------

output "service_plan_id" {
  description = "The ID of the App Service Plan."
  value       = azurerm_service_plan.this.id
}

output "service_plan_name" {
  description = "The name of the App Service Plan."
  value       = azurerm_service_plan.this.name
}

# -----------------------------------------------------------------------------
# Application Insights Outputs
# -----------------------------------------------------------------------------

output "application_insights_id" {
  description = "The ID of the Application Insights resource. Only available if Application Insights is enabled."
  value       = var.enable_application_insights ? azurerm_application_insights.this[0].id : null
}

output "application_insights_instrumentation_key" {
  description = "The instrumentation key for Application Insights. Sensitive - handle with care."
  value       = var.enable_application_insights ? azurerm_application_insights.this[0].instrumentation_key : null
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "The connection string for Application Insights. Sensitive - handle with care."
  value       = var.enable_application_insights ? azurerm_application_insights.this[0].connection_string : null
  sensitive   = true
}

output "application_insights_app_id" {
  description = "The App ID of Application Insights. Use this for API access to Application Insights data."
  value       = var.enable_application_insights ? azurerm_application_insights.this[0].app_id : null
}

# -----------------------------------------------------------------------------
# Configuration Outputs
# -----------------------------------------------------------------------------

output "os_type" {
  description = "The operating system type of the Function App (Linux or Windows)."
  value       = var.os_type
}

output "runtime_stack" {
  description = "The runtime stack configured for the Function App."
  value       = var.runtime_stack
}

output "runtime_version" {
  description = "The runtime version configured for the Function App."
  value       = var.runtime_version
}

output "https_only" {
  description = "Whether the Function App enforces HTTPS only traffic."
  value       = var.https_only
}

# -----------------------------------------------------------------------------
# Reference Outputs
# -----------------------------------------------------------------------------

output "tags" {
  description = "All tags applied to the Function App."
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.this[0].tags : azurerm_windows_function_app.this[0].tags
}

output "resource_group_name" {
  description = "The name of the Resource Group where resources are deployed."
  value       = var.resource_group_name
}

output "location" {
  description = "The Azure region where resources are deployed."
  value       = var.location
}
