terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Mock Azure provider for testing without credentials
# Note: Azure provider v4.0+ requires authentication even for plan operations.
# In CI/CD, use Azure credentials or run with mock credentials that won't actually connect.
provider "azurerm" {
  features {}

  resource_provider_registrations = "none"
  storage_use_azuread             = false

  # Mock credentials for testing
  # These will attempt to authenticate but won't affect plan generation
  use_cli         = false
  use_oidc        = false
  use_msi         = false
  subscription_id = "00000000-0000-0000-0000-000000000000"
  tenant_id       = "00000000-0000-0000-0000-000000000000"
  client_id       = "00000000-0000-0000-0000-000000000000"
  client_secret   = "mock-secret-for-testing"
}

# -----------------------------------------------------------------------------
# Test 1: Basic Node.js Function App on Linux
# -----------------------------------------------------------------------------

module "nodejs_function" {
  source = "../../"

  function_app_name     = "test-nodejs-func-12345"
  resource_group_name   = "test-rg"
  location              = "East US"
  storage_account_name  = "testnodejssa12345"
  app_service_plan_name = "test-nodejs-plan"

  runtime_stack   = "node"
  runtime_version = "20"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "nodejs-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 2: .NET Function App with Managed Identity
# -----------------------------------------------------------------------------

module "dotnet_function" {
  source = "../../"

  function_app_name     = "test-dotnet-func-12345"
  resource_group_name   = "test-rg"
  location              = "West Europe"
  storage_account_name  = "testdotnetsa12345"
  app_service_plan_name = "test-dotnet-plan"

  runtime_stack               = "dotnet"
  runtime_version             = "8"
  use_dotnet_isolated_runtime = true

  # Enable System Assigned Managed Identity
  identity_type = "SystemAssigned"

  # Premium plan for better performance
  sku_name = "EP1"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "dotnet-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 3: Python Function App with CORS
# -----------------------------------------------------------------------------

module "python_function" {
  source = "../../"

  function_app_name     = "test-python-func-12345"
  resource_group_name   = "test-rg"
  location              = "Central US"
  storage_account_name  = "testpythonsa12345"
  app_service_plan_name = "test-python-plan"

  runtime_stack   = "python"
  runtime_version = "3.11"

  # CORS configuration
  cors_allowed_origins = [
    "https://example.com",
    "https://test.example.com"
  ]
  cors_support_credentials = true

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "python-cors-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 4: Windows Function App with Java
# -----------------------------------------------------------------------------

module "java_function" {
  source = "../../"

  function_app_name     = "test-java-func-12345"
  resource_group_name   = "test-rg"
  location              = "West US"
  storage_account_name  = "testjavasa12345"
  app_service_plan_name = "test-java-plan"

  os_type = "Windows"

  runtime_stack   = "java"
  runtime_version = "17"

  # Standard plan
  sku_name = "S1"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "java-windows-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 5: Function App without Application Insights
# -----------------------------------------------------------------------------

module "no_insights_function" {
  source = "../../"

  function_app_name     = "test-no-insights-12345"
  resource_group_name   = "test-rg"
  location              = "North Europe"
  storage_account_name  = "testnoinsightssa12"
  app_service_plan_name = "test-no-insights-plan"

  runtime_stack   = "node"
  runtime_version = "18"

  # Disable Application Insights
  enable_application_insights = false

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "no-insights-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 6: PowerShell Function App
# -----------------------------------------------------------------------------

module "powershell_function" {
  source = "../../"

  function_app_name     = "test-ps-func-12345"
  resource_group_name   = "test-rg"
  location              = "UK South"
  storage_account_name  = "testpssa12345"
  app_service_plan_name = "test-ps-plan"

  runtime_stack   = "powershell"
  runtime_version = "7.4"

  # Custom app settings
  app_settings = {
    "CUSTOM_SETTING" = "test-value"
    "ENVIRONMENT"    = "test"
  }

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "powershell-testing"
  }
}

# -----------------------------------------------------------------------------
# Test Outputs
# -----------------------------------------------------------------------------

output "nodejs_function_app_id" {
  description = "ID of the Node.js function app"
  value       = module.nodejs_function.function_app_id
}

output "nodejs_default_hostname" {
  description = "Default hostname of the Node.js function app"
  value       = module.nodejs_function.default_hostname
}

output "dotnet_function_identity_principal_id" {
  description = "Principal ID of the .NET function app managed identity"
  value       = module.dotnet_function.identity_principal_id
}

output "python_function_app_id" {
  description = "ID of the Python function app"
  value       = module.python_function.function_app_id
}

output "java_function_os_type" {
  description = "OS type of the Java function app"
  value       = module.java_function.os_type
}

output "no_insights_function_app_id" {
  description = "ID of the function app without Application Insights"
  value       = module.no_insights_function.function_app_id
}

output "powershell_function_runtime_stack" {
  description = "Runtime stack of the PowerShell function app"
  value       = module.powershell_function.runtime_stack
}
