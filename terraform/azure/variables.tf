# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "function_app_name" {
  description = "Name of the Azure Function App. Must be globally unique across Azure."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.function_app_name))
    error_message = "Function app name must start and end with a lowercase letter or number, and can only contain lowercase letters, numbers, and hyphens."
  }

  validation {
    condition     = length(var.function_app_name) >= 2 && length(var.function_app_name) <= 60
    error_message = "Function app name must be between 2 and 60 characters long."
  }
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group where resources will be created."
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created (e.g., 'East US', 'West Europe')."
  type        = string
}

variable "storage_account_name" {
  description = "Name of the storage account for the Function App. Must be globally unique, 3-24 characters, lowercase letters and numbers only."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be between 3 and 24 characters long and can only contain lowercase letters and numbers."
  }
}

# -----------------------------------------------------------------------------
# Service Plan Configuration
# -----------------------------------------------------------------------------

variable "app_service_plan_name" {
  description = "Name of the App Service Plan for the Function App."
  type        = string
}

variable "os_type" {
  description = "Operating system type for the Function App. Must be either 'Linux' or 'Windows'."
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "OS type must be either 'Linux' or 'Windows'."
  }
}

variable "sku_name" {
  description = "SKU name for the App Service Plan. For Consumption plan use 'Y1'. For Premium use 'EP1', 'EP2', or 'EP3'. For Dedicated use 'B1', 'B2', 'B3', 'S1', 'S2', 'S3', 'P1v2', 'P2v2', 'P3v2'."
  type        = string
  default     = "Y1" # Consumption plan

  validation {
    condition = contains([
      "Y1",                   # Consumption
      "EP1", "EP2", "EP3",    # Premium
      "B1", "B2", "B3",       # Basic
      "S1", "S2", "S3",       # Standard
      "P1v2", "P2v2", "P3v2", # Premium v2
      "P1v3", "P2v3", "P3v3", # Premium v3
      "I1v2", "I2v2", "I3v2", # Isolated v2
    ], var.sku_name)
    error_message = "Invalid SKU name. Please use a valid Azure App Service Plan SKU."
  }
}

# -----------------------------------------------------------------------------
# Storage Account Configuration
# -----------------------------------------------------------------------------

variable "storage_account_tier" {
  description = "Performance tier of the storage account. Standard for general purpose, Premium for high performance."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Storage account tier must be either 'Standard' or 'Premium'."
  }
}

variable "storage_account_replication_type" {
  description = "Replication type for the storage account. Options: LRS (Locally Redundant), GRS (Geo-Redundant), RAGRS (Read-Access Geo-Redundant), ZRS (Zone-Redundant), GZRS (Geo-Zone-Redundant), RAGZRS (Read-Access Geo-Zone-Redundant)."
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_account_replication_type)
    error_message = "Storage account replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

# -----------------------------------------------------------------------------
# Runtime Configuration
# -----------------------------------------------------------------------------

variable "runtime_stack" {
  description = "Runtime stack for the Function App. Options: 'dotnet', 'node', 'python', 'java', 'powershell'. Set to null to configure manually."
  type        = string
  default     = null

  validation {
    condition     = var.runtime_stack == null || contains(["dotnet", "node", "python", "java", "powershell"], var.runtime_stack)
    error_message = "Runtime stack must be one of: dotnet, node, python, java, powershell, or null."
  }
}

variable "runtime_version" {
  description = "Version of the runtime stack. Required if runtime_stack is specified. Examples: '8' for .NET, '20' for Node.js, '3.11' for Python."
  type        = string
  default     = null
}

variable "use_dotnet_isolated_runtime" {
  description = "Use .NET isolated runtime model. Only applicable when runtime_stack is 'dotnet'."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Application Insights Configuration
# -----------------------------------------------------------------------------

variable "enable_application_insights" {
  description = "Enable Application Insights for monitoring and diagnostics. Recommended for production environments."
  type        = bool
  default     = true
}

variable "application_insights_name" {
  description = "Name of the Application Insights resource. If not specified, defaults to '{function_app_name}-insights'."
  type        = string
  default     = null
}

variable "application_insights_type" {
  description = "Application type for Application Insights. Use 'web' for most scenarios."
  type        = string
  default     = "web"

  validation {
    condition     = contains(["web", "other"], var.application_insights_type)
    error_message = "Application Insights type must be either 'web' or 'other'."
  }
}

# -----------------------------------------------------------------------------
# Security Configuration
# -----------------------------------------------------------------------------

variable "https_only" {
  description = "Force HTTPS only traffic. Recommended for production environments."
  type        = bool
  default     = true
}

variable "minimum_tls_version" {
  description = "Minimum TLS version for the Function App. Recommended: '1.2' or higher."
  type        = string
  default     = "1.2"

  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "Minimum TLS version must be one of: 1.0, 1.1, 1.2."
  }
}

variable "ftps_state" {
  description = "FTPS state for the Function App. Options: 'AllAllowed', 'FtpsOnly', 'Disabled'. Recommended: 'Disabled' or 'FtpsOnly'."
  type        = string
  default     = "Disabled"

  validation {
    condition     = contains(["AllAllowed", "FtpsOnly", "Disabled"], var.ftps_state)
    error_message = "FTPS state must be one of: AllAllowed, FtpsOnly, Disabled."
  }
}

# -----------------------------------------------------------------------------
# Identity Configuration
# -----------------------------------------------------------------------------

variable "identity_type" {
  description = "Type of Managed Identity for the Function App. Options: 'SystemAssigned', 'UserAssigned', 'SystemAssigned, UserAssigned'. Set to null to disable."
  type        = string
  default     = null

  validation {
    condition     = var.identity_type == null ? true : contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "Identity type must be one of: SystemAssigned, UserAssigned, 'SystemAssigned, UserAssigned', or null."
  }
}

variable "identity_ids" {
  description = "List of User Assigned Identity IDs. Required when identity_type includes 'UserAssigned'."
  type        = list(string)
  default     = null
}

# -----------------------------------------------------------------------------
# Network and CORS Configuration
# -----------------------------------------------------------------------------

variable "http2_enabled" {
  description = "Enable HTTP/2 protocol. Recommended for better performance."
  type        = bool
  default     = true
}

variable "cors_allowed_origins" {
  description = "List of allowed origins for CORS. Use ['*'] to allow all origins (not recommended for production)."
  type        = list(string)
  default     = []
}

variable "cors_support_credentials" {
  description = "Enable credentials support for CORS requests."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Application Settings
# -----------------------------------------------------------------------------

variable "app_settings" {
  description = "Map of application settings for the Function App. These are exposed as environment variables to your functions."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to all resources. Use this to add consistent tagging across your infrastructure."
  type        = map(string)
  default     = {}
}
