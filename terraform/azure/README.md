# Azure Blob Storage Terraform Module

Production-ready Terraform module for creating secure, well-configured Azure Storage Accounts with Blob Storage containers, versioning, encryption, and lifecycle management.

## Features

- **Security First**: HTTPS-only traffic and TLS 1.2 minimum by default
- **Infrastructure Encryption**: Additional encryption layer enabled by default
- **Public Access Protection**: Public blob access blocked by default
- **Versioning**: Enabled by default to protect against accidental deletion
- **Soft Delete**: Configurable retention for deleted blobs and containers
- **Lifecycle Management**: Flexible lifecycle rules for cost optimization
- **Network Security**: Optional network rules for IP/VNet restrictions
- **Customer-Managed Keys**: Support for Azure Key Vault encryption keys
- **Compliance Ready**: Follows Azure security best practices
- **Fully Tested**: Includes test configurations and passes security scans

## Usage

### Basic Example

```hcl
module "blob_storage" {
  source = "github.com/your-org/infra-modules//terraform/azure?ref=v1.0.0"

  storage_account_name = "mystorageaccount123"
  resource_group_name  = "my-resource-group"
  location             = "eastus"
  container_name       = "my-container"

  tags = {
    Environment = "production"
    Application = "my-app"
    ManagedBy   = "terraform"
  }
}
```

### Advanced Example with Customer-Managed Keys

```hcl
# Create a Key Vault and key first
resource "azurerm_key_vault_key" "storage_key" {
  name         = "storage-encryption-key"
  key_vault_id = azurerm_key_vault.example.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

module "secure_storage" {
  source = "github.com/your-org/infra-modules//terraform/azure?ref=v1.0.0"

  storage_account_name = "securestorage123"
  resource_group_name  = "my-resource-group"
  location             = "eastus"
  container_name       = "secure-data"

  # Use customer-managed encryption key
  customer_managed_key_vault_key_id = azurerm_key_vault_key.storage_key.id

  # Enhanced security settings
  enable_https_traffic_only         = true
  min_tls_version                   = "TLS1_2"
  infrastructure_encryption_enabled = true

  # Enable versioning and soft delete
  versioning_enabled                   = true
  blob_soft_delete_retention_days      = 30
  container_soft_delete_retention_days = 30

  tags = {
    Environment = "production"
    Compliance  = "required"
    DataClass   = "sensitive"
  }
}
```

### Example with Network Restrictions

```hcl
module "restricted_storage" {
  source = "github.com/your-org/infra-modules//terraform/azure?ref=v1.0.0"

  storage_account_name = "restrictedstorage123"
  resource_group_name  = "my-resource-group"
  location             = "eastus"
  container_name       = "restricted-data"

  # Enable network rules
  network_rules_enabled        = true
  network_rules_default_action = "Deny"
  network_rules_bypass         = ["AzureServices", "Logging", "Metrics"]

  # Allow specific IPs and VNets
  network_rules_ip_rules = [
    "203.0.113.0/24",
    "198.51.100.42"
  ]
  network_rules_subnet_ids = [
    azurerm_subnet.trusted.id
  ]

  tags = {
    Environment = "production"
    Security    = "restricted"
  }
}
```

### Example with Lifecycle Management

```hcl
module "archive_storage" {
  source = "github.com/your-org/infra-modules//terraform/azure?ref=v1.0.0"

  storage_account_name = "archivestorage123"
  resource_group_name  = "my-resource-group"
  location             = "eastus"
  container_name       = "archive-data"

  # Enable last access time tracking for lifecycle policies
  last_access_time_enabled = true

  # Define lifecycle rules for cost optimization
  lifecycle_rules = [
    {
      name         = "archive-old-logs"
      enabled      = true
      prefix_match = ["logs/"]
      blob_types   = ["blockBlob"]

      base_blob_actions = {
        # Move to cool storage after 30 days
        tier_to_cool_after_days = 30

        # Move to archive after 90 days
        tier_to_archive_after_days = 90

        # Delete after 2 years
        delete_after_days = 730
      }

      # Manage snapshots
      snapshot_actions = {
        tier_to_archive_after_days = 30
        delete_after_days          = 90
      }

      # Manage old versions
      version_actions = {
        tier_to_archive_after_days = 30
        delete_after_days          = 90
      }
    },
    {
      name         = "cleanup-temp-files"
      enabled      = true
      prefix_match = ["temp/"]
      blob_types   = ["blockBlob"]

      base_blob_actions = {
        # Delete temp files after 7 days
        delete_after_days = 7
      }
    },
    {
      name         = "archive-based-on-access"
      enabled      = true
      prefix_match = ["documents/"]
      blob_types   = ["blockBlob"]

      base_blob_actions = {
        # Move to cool after 60 days of no access
        tier_to_cool_after_last_access_days = 60

        # Move to archive after 180 days of no access
        tier_to_archive_after_last_access_days = 180
      }
    }
  ]

  tags = {
    Environment = "production"
    Purpose     = "archival"
  }
}
```

### Example with Geo-Replication

```hcl
module "geo_replicated_storage" {
  source = "github.com/your-org/infra-modules//terraform/azure?ref=v1.0.0"

  storage_account_name = "geostorage123"
  resource_group_name  = "my-resource-group"
  location             = "eastus"
  container_name       = "replicated-data"

  # Enable geo-redundant replication
  replication_type = "RAGRS"  # Read-Access Geo-Redundant Storage

  # Standard tier for geo-replication
  account_tier = "Standard"

  tags = {
    Environment     = "production"
    HighAvailability = "true"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_management_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | Name of the blob container. Must be between 3-63 characters, lowercase letters, numbers, and hyphens only. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region where the storage account will be created (e.g., 'eastus', 'westeurope'). | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group where the storage account will be created. | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name of the Azure Storage Account. Must be globally unique, between 3-24 characters, and contain only lowercase letters and numbers. | `string` | n/a | yes |
| <a name="input_account_kind"></a> [account\_kind](#input\_account\_kind) | Storage account kind. StorageV2 is recommended for most scenarios. | `string` | `"StorageV2"` | no |
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | Storage account tier. Standard for general-purpose v2, Premium for high-performance scenarios. | `string` | `"Standard"` | no |
| <a name="input_allow_public_access"></a> [allow\_public\_access](#input\_allow\_public\_access) | Allow public access to blobs. Recommended to keep disabled (false) for security. | `bool` | `false` | no |
| <a name="input_blob_soft_delete_retention_days"></a> [blob\_soft\_delete\_retention\_days](#input\_blob\_soft\_delete\_retention\_days) | Number of days to retain deleted blobs. Set to 0 to disable soft delete. Recommended: 7-30 days. | `number` | `7` | no |
| <a name="input_change_feed_enabled"></a> [change\_feed\_enabled](#input\_change\_feed\_enabled) | Enable change feed to track create, update, and delete changes to blobs. Useful for auditing and event-driven architectures. | `bool` | `false` | no |
| <a name="input_container_access_type"></a> [container\_access\_type](#input\_container\_access\_type) | Access type for the container. Options: 'private' (no public access), 'blob' (public read for blobs only), 'container' (public read for container and blobs). | `string` | `"private"` | no |
| <a name="input_container_metadata"></a> [container\_metadata](#input\_container\_metadata) | Metadata to assign to the container as key-value pairs. | `map(string)` | `{}` | no |
| <a name="input_container_soft_delete_retention_days"></a> [container\_soft\_delete\_retention\_days](#input\_container\_soft\_delete\_retention\_days) | Number of days to retain deleted containers. Set to 0 to disable soft delete. Recommended: 7-30 days. | `number` | `7` | no |
| <a name="input_customer_managed_key_user_assigned_identity_id"></a> [customer\_managed\_key\_user\_assigned\_identity\_id](#input\_customer\_managed\_key\_user\_assigned\_identity\_id) | User-assigned managed identity ID for accessing the customer-managed key. If not specified, system-assigned identity will be used. | `string` | `null` | no |
| <a name="input_customer_managed_key_vault_key_id"></a> [customer\_managed\_key\_vault\_key\_id](#input\_customer\_managed\_key\_vault\_key\_id) | Key Vault Key ID for customer-managed encryption keys. If not specified, Microsoft-managed keys will be used. | `string` | `null` | no |
| <a name="input_enable_https_traffic_only"></a> [enable\_https\_traffic\_only](#input\_enable\_https\_traffic\_only) | Enforce HTTPS-only traffic to the storage account. Recommended to keep enabled for security. | `bool` | `true` | no |
| <a name="input_infrastructure_encryption_enabled"></a> [infrastructure\_encryption\_enabled](#input\_infrastructure\_encryption\_enabled) | Enable infrastructure encryption for additional security layer. Recommended for sensitive data. | `bool` | `true` | no |
| <a name="input_last_access_time_enabled"></a> [last\_access\_time\_enabled](#input\_last\_access\_time\_enabled) | Enable last access time tracking for lifecycle management policies based on access patterns. | `bool` | `false` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | List of lifecycle management rules for optimizing storage costs.<br/>Each rule can include:<br/>- name: Unique name for the rule<br/>- enabled: Whether the rule is active<br/>- prefix\_match: List of blob prefixes to match (optional)<br/>- blob\_types: Types of blobs to apply the rule to (e.g., ["blockBlob"])<br/>- base\_blob\_actions: Actions for current versions<br/>  - tier\_to\_cool\_after\_days: Days to tier to cool storage<br/>  - tier\_to\_cool\_after\_last\_access\_days: Days since last access to tier to cool<br/>  - tier\_to\_archive\_after\_days: Days to tier to archive storage<br/>  - tier\_to\_archive\_after\_last\_access\_days: Days since last access to tier to archive<br/>  - delete\_after\_days: Days to delete blobs<br/>  - delete\_after\_last\_access\_days: Days since last access to delete<br/>- snapshot\_actions: Actions for snapshots<br/>- version\_actions: Actions for older versions | <pre>list(object({<br/>    name         = string<br/>    enabled      = bool<br/>    prefix_match = optional(list(string), [])<br/>    blob_types   = list(string)<br/>    base_blob_actions = optional(object({<br/>      tier_to_cool_after_days                = optional(number)<br/>      tier_to_cool_after_last_access_days    = optional(number)<br/>      tier_to_archive_after_days             = optional(number)<br/>      tier_to_archive_after_last_access_days = optional(number)<br/>      delete_after_days                      = optional(number)<br/>      delete_after_last_access_days          = optional(number)<br/>    }))<br/>    snapshot_actions = optional(object({<br/>      tier_to_cool_after_days    = optional(number)<br/>      tier_to_archive_after_days = optional(number)<br/>      delete_after_days          = optional(number)<br/>    }))<br/>    version_actions = optional(object({<br/>      tier_to_cool_after_days    = optional(number)<br/>      tier_to_archive_after_days = optional(number)<br/>      delete_after_days          = optional(number)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_min_tls_version"></a> [min\_tls\_version](#input\_min\_tls\_version) | Minimum TLS version for requests to the storage account. | `string` | `"TLS1_2"` | no |
| <a name="input_network_rules_bypass"></a> [network\_rules\_bypass](#input\_network\_rules\_bypass) | Services that can bypass network rules. Options: 'AzureServices', 'Logging', 'Metrics', 'None'. | `list(string)` | <pre>[<br/>  "AzureServices"<br/>]</pre> | no |
| <a name="input_network_rules_default_action"></a> [network\_rules\_default\_action](#input\_network\_rules\_default\_action) | Default action for network rules. 'Deny' blocks all traffic except allowed IPs/VNets. 'Allow' permits all traffic. | `string` | `"Deny"` | no |
| <a name="input_network_rules_enabled"></a> [network\_rules\_enabled](#input\_network\_rules\_enabled) | Enable network rules to restrict access to the storage account. | `bool` | `false` | no |
| <a name="input_network_rules_ip_rules"></a> [network\_rules\_ip\_rules](#input\_network\_rules\_ip\_rules) | List of public IP addresses or CIDR ranges that can access the storage account. | `list(string)` | `[]` | no |
| <a name="input_network_rules_subnet_ids"></a> [network\_rules\_subnet\_ids](#input\_network\_rules\_subnet\_ids) | List of virtual network subnet IDs that can access the storage account. | `list(string)` | `[]` | no |
| <a name="input_replication_type"></a> [replication\_type](#input\_replication\_type) | Storage account replication type. Options: LRS (Locally Redundant), GRS (Geo-Redundant), RAGRS (Read-Access Geo-Redundant), ZRS (Zone-Redundant), GZRS (Geo-Zone-Redundant), RAGZRS (Read-Access Geo-Zone-Redundant). | `string` | `"LRS"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. Use this to add consistent tagging across your infrastructure. | `map(string)` | `{}` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Enable blob versioning to protect against accidental deletion and provide object history. Recommended for production. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_kind"></a> [account\_kind](#output\_account\_kind) | The kind of the storage account. |
| <a name="output_account_tier"></a> [account\_tier](#output\_account\_tier) | The tier of the storage account (Standard or Premium). |
| <a name="output_container_id"></a> [container\_id](#output\_container\_id) | The ID of the blob container. |
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | The name of the blob container. |
| <a name="output_https_traffic_only"></a> [https\_traffic\_only](#output\_https\_traffic\_only) | Whether HTTPS-only traffic is enforced. |
| <a name="output_identity"></a> [identity](#output\_identity) | The managed identity configuration of the storage account. |
| <a name="output_infrastructure_encryption_enabled"></a> [infrastructure\_encryption\_enabled](#output\_infrastructure\_encryption\_enabled) | Whether infrastructure encryption is enabled for additional security. |
| <a name="output_location"></a> [location](#output\_location) | The Azure region where the storage account is deployed. |
| <a name="output_min_tls_version"></a> [min\_tls\_version](#output\_min\_tls\_version) | The minimum TLS version required for requests. |
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | The primary access key for the storage account. Use this for authentication when accessing the storage account. |
| <a name="output_primary_blob_connection_string"></a> [primary\_blob\_connection\_string](#output\_primary\_blob\_connection\_string) | The primary blob service connection string. Use this for blob-specific SDK connections. |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | The primary blob service endpoint. Use this for accessing blobs in the storage account. |
| <a name="output_primary_blob_host"></a> [primary\_blob\_host](#output\_primary\_blob\_host) | The hostname for the primary blob service endpoint. |
| <a name="output_primary_connection_string"></a> [primary\_connection\_string](#output\_primary\_connection\_string) | The primary connection string for the storage account. Use this for SDK and tool connections. |
| <a name="output_replication_type"></a> [replication\_type](#output\_replication\_type) | The replication type of the storage account. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group containing the storage account. |
| <a name="output_secondary_access_key"></a> [secondary\_access\_key](#output\_secondary\_access\_key) | The secondary access key for the storage account. Use this for key rotation scenarios. |
| <a name="output_secondary_blob_connection_string"></a> [secondary\_blob\_connection\_string](#output\_secondary\_blob\_connection\_string) | The secondary blob service connection string. Use this for blob-specific failover scenarios. |
| <a name="output_secondary_blob_endpoint"></a> [secondary\_blob\_endpoint](#output\_secondary\_blob\_endpoint) | The secondary blob service endpoint. Available when geo-replication is enabled. |
| <a name="output_secondary_blob_host"></a> [secondary\_blob\_host](#output\_secondary\_blob\_host) | The hostname for the secondary blob service endpoint. Available when geo-replication is enabled. |
| <a name="output_secondary_connection_string"></a> [secondary\_connection\_string](#output\_secondary\_connection\_string) | The secondary connection string for the storage account. Use this for failover scenarios. |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The ID of the storage account. Use this for resource references and configurations. |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the storage account. Use this for accessing the storage account. |
| <a name="output_tags"></a> [tags](#output\_tags) | All tags applied to the storage account, including default and custom tags. |
| <a name="output_versioning_enabled"></a> [versioning\_enabled](#output\_versioning\_enabled) | Whether blob versioning is enabled. Important for compliance and data protection verification. |
<!-- END_TF_DOCS -->

## Security Considerations

### Default Security Posture

This module implements Azure security best practices by default:

1. **HTTPS-Only Traffic**: All connections must use HTTPS
2. **TLS 1.2 Minimum**: Modern TLS version enforced
3. **Infrastructure Encryption**: Additional encryption layer enabled
4. **Public Access**: Public blob access blocked by default
5. **Versioning**: Enabled by default to protect against accidental deletion
6. **Soft Delete**: 7-day retention for deleted blobs and containers

### Encryption Options

**Microsoft-Managed Keys (Default)**
- Automatic key management by Azure
- No additional configuration required
- Suitable for most scenarios

**Customer-Managed Keys (CMK)**
- Full control over encryption keys
- Key rotation and lifecycle management
- Audit trail in Azure Key Vault
- Requires Azure Key Vault setup

```hcl
customer_managed_key_vault_key_id = azurerm_key_vault_key.example.id
```

### Network Security

Restrict access using network rules:

```hcl
network_rules_enabled        = true
network_rules_default_action = "Deny"
network_rules_ip_rules       = ["203.0.113.0/24"]
network_rules_subnet_ids     = [azurerm_subnet.trusted.id]
```

Benefits:
- Prevent unauthorized access from the internet
- Allow only trusted networks and IPs
- Maintain access for Azure services (optional)

### Replication Options

- **LRS** (Locally Redundant): 3 copies in one datacenter (lowest cost)
- **ZRS** (Zone-Redundant): 3 copies across availability zones
- **GRS** (Geo-Redundant): 6 copies across two regions
- **RAGRS** (Read-Access Geo-Redundant): GRS with read access to secondary region
- **GZRS** (Geo-Zone-Redundant): ZRS + geo-replication
- **RAGZRS** (Read-Access Geo-Zone-Redundant): GZRS with read access to secondary

### Lifecycle Best Practices

Use lifecycle rules to:
1. Reduce storage costs by tiering to Cool or Archive storage
2. Meet compliance requirements for data retention
3. Automatically delete old data
4. Manage versioned blobs and snapshots efficiently

## Comparison with AWS S3

| Feature | Azure Blob Storage | AWS S3 |
|---------|-------------------|---------|
| **Storage Tiers** | Hot, Cool, Archive | Standard, IA, Glacier |
| **Versioning** | Yes | Yes |
| **Encryption** | Microsoft/Customer-managed | SSE-S3, SSE-KMS |
| **Lifecycle** | Tiering and deletion | Tiering and expiration |
| **Replication** | LRS, ZRS, GRS, RAGRS | None (use S3 replication) |
| **Access Tiers** | Hot, Cool, Archive | Standard, IA, Glacier |

## Testing

Run the basic test:

```bash
cd tests/basic
terraform init -backend=false
terraform plan
```

## Support and Contributions

For issues, questions, or contributions, please see the repository guidelines.

## License

See [LICENSE](../../LICENSE) file for details.
