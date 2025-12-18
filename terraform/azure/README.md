# Azure Functions Terraform Module

Production-ready Terraform module for creating secure, well-configured Azure Functions with monitoring, identity management, and flexible runtime configuration.

## Features

- **Multiple Runtime Support**: .NET, Node.js, Python, Java, and PowerShell
- **OS Flexibility**: Deploy on Linux or Windows
- **Built-in Monitoring**: Application Insights integration for observability
- **Managed Identity**: SystemAssigned and UserAssigned identity support
- **Security First**: HTTPS-only by default, configurable TLS version, secure storage
- **Flexible Scaling**: Support for Consumption, Premium, and Dedicated plans
- **CORS Configuration**: Built-in CORS support for web applications
- **Production Ready**: Follows Azure best practices and security guidelines

## Usage

### Basic Example - Node.js Function on Linux

```hcl
module "my_function" {
  source = "github.com/your-org/infra-modules//terraform/azure?ref=v1.0.0"

  function_app_name      = "my-nodejs-function"
  resource_group_name    = "my-resource-group"
  location               = "East US"
  storage_account_name   = "mystorageacct12345"
  app_service_plan_name  = "my-app-service-plan"

  # Node.js runtime configuration
  runtime_stack   = "node"
  runtime_version = "20"

  tags = {
    Environment = "production"
    Application = "my-app"
    ManagedBy   = "terraform"
  }
}
```

### Advanced Example - .NET Function with Managed Identity

```hcl
module "dotnet_function" {
  source = "github.com/your-org/infra-modules//terraform/azure?ref=v1.0.0"

  function_app_name      = "my-dotnet-function"
  resource_group_name    = "my-resource-group"
  location               = "West Europe"
  storage_account_name   = "mydotnetstorage123"
  app_service_plan_name  = "my-premium-plan"

  # Use Premium plan for better performance
  sku_name = "EP1"

  # .NET isolated runtime
  runtime_stack              = "dotnet"
  runtime_version            = "8"
  use_dotnet_isolated_runtime = true

  # Enable System Assigned Managed Identity
  identity_type = "SystemAssigned"

  # Application Insights for monitoring
  enable_application_insights = true

  # Custom application settings
  app_settings = {
    "CUSTOM_SETTING" = "value"
    "ENVIRONMENT"    = "production"
  }

  tags = {
    Environment = "production"
    Team        = "platform"
    CostCenter  = "engineering"
  }
}
```

### Example - Python Function with CORS

```hcl
module "python_api" {
  source = "github.com/your-org/infra-modules//terraform/azure?ref=v1.0.0"

  function_app_name      = "my-python-api"
  resource_group_name    = "my-resource-group"
  location               = "Central US"
  storage_account_name   = "mypythonapi12345"
  app_service_plan_name  = "my-consumption-plan"

  # Python runtime
  runtime_stack   = "python"
  runtime_version = "3.11"

  # CORS configuration for web apps
  cors_allowed_origins = [
    "https://myapp.example.com",
    "https://staging.myapp.example.com"
  ]
  cors_support_credentials = true

  tags = {
    Environment = "production"
    Purpose     = "api"
  }
}
```

### Example - Windows Function with Java

```hcl
module "java_function" {
  source = "github.com/your-org/infra-modules//terraform/azure?ref=v1.0.0"

  function_app_name      = "my-java-function"
  resource_group_name    = "my-resource-group"
  location               = "East US"
  storage_account_name   = "myjavastorage123"
  app_service_plan_name  = "my-java-plan"

  # Windows OS for Java
  os_type = "Windows"

  # Java runtime
  runtime_stack   = "java"
  runtime_version = "17"

  # Standard plan for dedicated resources
  sku_name = "S1"

  tags = {
    Environment = "production"
    Runtime     = "java"
  }
}
```

### Example - Function without Application Insights

```hcl
module "simple_function" {
  source = "github.com/your-org/infra-modules//terraform/azure?ref=v1.0.0"

  function_app_name      = "my-simple-function"
  resource_group_name    = "my-resource-group"
  location               = "West US"
  storage_account_name   = "mysimplefunc12345"
  app_service_plan_name  = "my-simple-plan"

  runtime_stack   = "node"
  runtime_version = "18"

  # Disable Application Insights for development
  enable_application_insights = false

  tags = {
    Environment = "development"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_linux_function_app.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_service_plan.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_windows_function_app.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_function_app) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_service_plan_name"></a> [app\_service\_plan\_name](#input\_app\_service\_plan\_name) | Name of the App Service Plan for the Function App. | `string` | n/a | yes |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | Map of application settings for the Function App. These are exposed as environment variables to your functions. | `map(string)` | `{}` | no |
| <a name="input_application_insights_name"></a> [application\_insights\_name](#input\_application\_insights\_name) | Name of the Application Insights resource. If not specified, defaults to '{function\_app\_name}-insights'. | `string` | `null` | no |
| <a name="input_application_insights_type"></a> [application\_insights\_type](#input\_application\_insights\_type) | Application type for Application Insights. Use 'web' for most scenarios. | `string` | `"web"` | no |
| <a name="input_cors_allowed_origins"></a> [cors\_allowed\_origins](#input\_cors\_allowed\_origins) | List of allowed origins for CORS. Use ['*'] to allow all origins (not recommended for production). | `list(string)` | `[]` | no |
| <a name="input_cors_support_credentials"></a> [cors\_support\_credentials](#input\_cors\_support\_credentials) | Enable credentials support for CORS requests. | `bool` | `false` | no |
| <a name="input_enable_application_insights"></a> [enable\_application\_insights](#input\_enable\_application\_insights) | Enable Application Insights for monitoring and diagnostics. Recommended for production environments. | `bool` | `true` | no |
| <a name="input_ftps_state"></a> [ftps\_state](#input\_ftps\_state) | FTPS state for the Function App. Options: 'AllAllowed', 'FtpsOnly', 'Disabled'. Recommended: 'Disabled' or 'FtpsOnly'. | `string` | `"Disabled"` | no |
| <a name="input_function_app_name"></a> [function\_app\_name](#input\_function\_app\_name) | Name of the Azure Function App. Must be globally unique across Azure. | `string` | n/a | yes |
| <a name="input_http2_enabled"></a> [http2\_enabled](#input\_http2\_enabled) | Enable HTTP/2 protocol. Recommended for better performance. | `bool` | `true` | no |
| <a name="input_https_only"></a> [https\_only](#input\_https\_only) | Force HTTPS only traffic. Recommended for production environments. | `bool` | `true` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | List of User Assigned Identity IDs. Required when identity\_type includes 'UserAssigned'. | `list(string)` | `null` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | Type of Managed Identity for the Function App. Options: 'SystemAssigned', 'UserAssigned', 'SystemAssigned, UserAssigned'. Set to null to disable. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region where resources will be created (e.g., 'East US', 'West Europe'). | `string` | n/a | yes |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | Minimum TLS version for the Function App. Recommended: '1.2' or higher. | `string` | `"1.2"` | no |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | Operating system type for the Function App. Must be either 'Linux' or 'Windows'. | `string` | `"Linux"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Azure Resource Group where resources will be created. | `string` | n/a | yes |
| <a name="input_runtime_stack"></a> [runtime\_stack](#input\_runtime\_stack) | Runtime stack for the Function App. Options: 'dotnet', 'node', 'python', 'java', 'powershell'. Set to null to configure manually. | `string` | `null` | no |
| <a name="input_runtime_version"></a> [runtime\_version](#input\_runtime\_version) | Version of the runtime stack. Required if runtime\_stack is specified. Examples: '8' for .NET, '20' for Node.js, '3.11' for Python. | `string` | `null` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU name for the App Service Plan. For Consumption plan use 'Y1'. For Premium use 'EP1', 'EP2', or 'EP3'. For Dedicated use 'B1', 'B2', 'B3', 'S1', 'S2', 'S3', 'P1v2', 'P2v2', 'P3v2'. | `string` | `"Y1"` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name of the storage account for the Function App. Must be globally unique, 3-24 characters, lowercase letters and numbers only. | `string` | n/a | yes |
| <a name="input_storage_account_replication_type"></a> [storage\_account\_replication\_type](#input\_storage\_account\_replication\_type) | Replication type for the storage account. Options: LRS (Locally Redundant), GRS (Geo-Redundant), RAGRS (Read-Access Geo-Redundant), ZRS (Zone-Redundant), GZRS (Geo-Zone-Redundant), RAGZRS (Read-Access Geo-Zone-Redundant). | `string` | `"LRS"` | no |
| <a name="input_storage_account_tier"></a> [storage\_account\_tier](#input\_storage\_account\_tier) | Performance tier of the storage account. Standard for general purpose, Premium for high performance. | `string` | `"Standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. Use this to add consistent tagging across your infrastructure. | `map(string)` | `{}` | no |
| <a name="input_use_dotnet_isolated_runtime"></a> [use\_dotnet\_isolated\_runtime](#input\_use\_dotnet\_isolated\_runtime) | Use .NET isolated runtime model. Only applicable when runtime\_stack is 'dotnet'. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_insights_app_id"></a> [application\_insights\_app\_id](#output\_application\_insights\_app\_id) | The App ID of Application Insights. Use this for API access to Application Insights data. |
| <a name="output_application_insights_connection_string"></a> [application\_insights\_connection\_string](#output\_application\_insights\_connection\_string) | The connection string for Application Insights. Sensitive - handle with care. |
| <a name="output_application_insights_id"></a> [application\_insights\_id](#output\_application\_insights\_id) | The ID of the Application Insights resource. Only available if Application Insights is enabled. |
| <a name="output_application_insights_instrumentation_key"></a> [application\_insights\_instrumentation\_key](#output\_application\_insights\_instrumentation\_key) | The instrumentation key for Application Insights. Sensitive - handle with care. |
| <a name="output_default_hostname"></a> [default\_hostname](#output\_default\_hostname) | The default hostname of the Function App. Use this to access your functions via HTTPS. |
| <a name="output_function_app_id"></a> [function\_app\_id](#output\_function\_app\_id) | The ID of the Function App. Use this for resource references and dependencies. |
| <a name="output_function_app_name"></a> [function\_app\_name](#output\_function\_app\_name) | The name of the Function App. |
| <a name="output_https_only"></a> [https\_only](#output\_https\_only) | Whether the Function App enforces HTTPS only traffic. |
| <a name="output_identity_principal_id"></a> [identity\_principal\_id](#output\_identity\_principal\_id) | The Principal ID of the System Assigned Managed Identity. Use this to grant permissions to Azure resources. |
| <a name="output_identity_tenant_id"></a> [identity\_tenant\_id](#output\_identity\_tenant\_id) | The Tenant ID of the System Assigned Managed Identity. |
| <a name="output_location"></a> [location](#output\_location) | The Azure region where resources are deployed. |
| <a name="output_os_type"></a> [os\_type](#output\_os\_type) | The operating system type of the Function App (Linux or Windows). |
| <a name="output_outbound_ip_addresses"></a> [outbound\_ip\_addresses](#output\_outbound\_ip\_addresses) | A comma-separated list of outbound IP addresses used by the Function App. |
| <a name="output_possible_outbound_ip_addresses"></a> [possible\_outbound\_ip\_addresses](#output\_possible\_outbound\_ip\_addresses) | A comma-separated list of possible outbound IP addresses. Use this for firewall allowlisting. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the Resource Group where resources are deployed. |
| <a name="output_runtime_stack"></a> [runtime\_stack](#output\_runtime\_stack) | The runtime stack configured for the Function App. |
| <a name="output_runtime_version"></a> [runtime\_version](#output\_runtime\_version) | The runtime version configured for the Function App. |
| <a name="output_service_plan_id"></a> [service\_plan\_id](#output\_service\_plan\_id) | The ID of the App Service Plan. |
| <a name="output_service_plan_name"></a> [service\_plan\_name](#output\_service\_plan\_name) | The name of the App Service Plan. |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The ID of the Storage Account used by the Function App. |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the Storage Account used by the Function App. |
| <a name="output_storage_account_primary_connection_string"></a> [storage\_account\_primary\_connection\_string](#output\_storage\_account\_primary\_connection\_string) | The primary connection string for the Storage Account. Sensitive - handle with care. |
| <a name="output_tags"></a> [tags](#output\_tags) | All tags applied to the Function App. |
<!-- END_TF_DOCS -->

## Security Considerations

### Default Security Posture

This module implements security best practices by default:

1. **HTTPS Only**: All traffic is forced over HTTPS by default
2. **TLS 1.2**: Minimum TLS version is set to 1.2 for secure communications
3. **Storage Encryption**: Storage account uses HTTPS-only traffic
4. **FTPS Disabled**: FTP/FTPS is disabled by default to prevent insecure file transfers
5. **Application Insights**: Enabled by default for security monitoring and diagnostics

### Using Managed Identity

Enable Managed Identity to securely access Azure resources without storing credentials:

```hcl
# System Assigned Identity
identity_type = "SystemAssigned"

# User Assigned Identity
identity_type = "UserAssigned"
identity_ids  = [azurerm_user_assigned_identity.example.id]
```

Benefits:
- No credentials in code or configuration
- Automatic credential rotation
- Fine-grained access control via Azure RBAC
- Audit trail in Azure Activity Log

### Choosing the Right SKU

- **Y1 (Consumption)**: Pay-per-execution, auto-scaling, best for variable workloads
- **EP1/EP2/EP3 (Premium)**: Pre-warmed instances, VNet integration, unlimited execution time
- **B1/S1/P1v2 (Dedicated)**: Dedicated VM instances, predictable pricing

### Application Insights

Enable Application Insights for:
1. Performance monitoring and diagnostics
2. Distributed tracing across services
3. Custom metrics and logging
4. Security and compliance auditing

### CORS Configuration

Configure CORS carefully:
- Never use `["*"]` in production environments
- List specific origins that need access
- Enable `cors_support_credentials` only when necessary

## Testing

Run the basic test:

```bash
cd tests/basic
terraform init -backend=false
terraform plan
```

Run module validation:

```bash
make test-module MODULE=azure
```

## SKU Reference

### Consumption Plan (Serverless)
- **Y1**: Pay per execution, automatic scaling

### Premium Plans (Enhanced Features)
- **EP1**: 1 core, 3.5 GB RAM
- **EP2**: 2 cores, 7 GB RAM
- **EP3**: 4 cores, 14 GB RAM

### Dedicated Plans (Predictable Pricing)
- **Basic**: B1, B2, B3
- **Standard**: S1, S2, S3
- **Premium v2**: P1v2, P2v2, P3v2
- **Premium v3**: P1v3, P2v3, P3v3

## Runtime Support

| Runtime | Supported Versions | OS Support |
|---------|-------------------|------------|
| .NET | 6, 7, 8 | Linux, Windows |
| Node.js | 16, 18, 20 | Linux, Windows |
| Python | 3.8, 3.9, 3.10, 3.11 | Linux only |
| Java | 8, 11, 17 | Linux, Windows |
| PowerShell | 7.2, 7.4 | Linux, Windows |

## Important Notes

1. **Storage Account Names**: Must be globally unique across all of Azure
2. **Function App Names**: Must be globally unique across all of Azure
3. **Resource Group**: Must be created before using this module
4. **Python**: Only supported on Linux OS
5. **.NET Isolated**: Recommended for .NET 6+ for better performance and flexibility
