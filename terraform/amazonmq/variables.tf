# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "broker_name" {
  description = <<-EOT
    Name of the AmazonMQ broker.
    Must be unique within your AWS account and region.

    Constraints:
    - Must be between 1 and 50 characters
    - Can only contain alphanumeric characters, dashes, and underscores
  EOT
  type        = string

  validation {
    condition     = length(var.broker_name) > 0 && length(var.broker_name) <= 50
    error_message = "Broker name must be between 1 and 50 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.broker_name))
    error_message = "Broker name can only contain alphanumeric characters, dashes, and underscores."
  }
}

variable "engine_type" {
  description = <<-EOT
    Type of broker engine.

    Valid values:
    - ActiveMQ: Apache ActiveMQ message broker
    - RabbitMQ: RabbitMQ message broker
  EOT
  type        = string

  validation {
    condition     = contains(["ActiveMQ", "RabbitMQ"], var.engine_type)
    error_message = "Engine type must be either 'ActiveMQ' or 'RabbitMQ'."
  }
}

variable "engine_version" {
  description = <<-EOT
    Version of the broker engine.

    ActiveMQ versions: 5.15.x, 5.16.x, 5.17.x, 5.18.x
    RabbitMQ versions: 3.8.x, 3.9.x, 3.10.x, 3.11.x, 3.12.x, 3.13.x

    For latest supported versions, check AWS documentation.
  EOT
  type        = string
}

variable "host_instance_type" {
  description = <<-EOT
    Instance type of the broker.

    ActiveMQ instance types:
    - mq.t3.micro: 2 vCPU, 1 GiB RAM (dev/test only, not for production)
    - mq.m5.large: 2 vCPU, 8 GiB RAM
    - mq.m5.xlarge: 4 vCPU, 16 GiB RAM
    - mq.m5.2xlarge: 8 vCPU, 32 GiB RAM
    - mq.m5.4xlarge: 16 vCPU, 64 GiB RAM

    RabbitMQ instance types:
    - mq.t3.micro: 2 vCPU, 1 GiB RAM (dev/test only, not for production)
    - mq.m5.large: 2 vCPU, 8 GiB RAM
    - mq.m5.xlarge: 4 vCPU, 16 GiB RAM
    - mq.m5.2xlarge: 8 vCPU, 32 GiB RAM
    - mq.m5.4xlarge: 16 vCPU, 64 GiB RAM
  EOT
  type        = string
}

variable "users" {
  description = <<-EOT
    List of broker users. This module currently supports exactly one user.

    Each user must have:
    - username: User login name
    - password: User password (stored securely, use sensitive variable)

    Optional fields:
    - console_access: Enable web console access (ActiveMQ only)
    - groups: List of groups for the user (ActiveMQ with LDAP only)
    - replication_user: Whether this user is for replication (ActiveMQ only)

    Example:
    [
      {
        username       = "admin"
        password       = "MySecurePassword123!"
        console_access = true
      }
    ]
  EOT
  type = list(object({
    username         = string
    password         = string
    console_access   = optional(bool)
    groups           = optional(list(string))
    replication_user = optional(bool)
  }))
  sensitive = true

  validation {
    condition     = length(var.users) > 0
    error_message = "At least one user must be defined."
  }

  validation {
    condition     = length(var.users) == 1
    error_message = "This module currently supports exactly one user."
  }
}

variable "subnet_ids" {
  description = <<-EOT
    List of subnet IDs for the broker.

    - SINGLE_INSTANCE deployment: Provide 1 subnet
    - ACTIVE_STANDBY_MULTI_AZ deployment: Provide 2 subnets in different AZs
    - CLUSTER_MULTI_AZ deployment: Provide 3 subnets in different AZs (RabbitMQ only)

    Subnets must be in a VPC with DNS resolution and DNS hostnames enabled.
  EOT
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 1 && length(var.subnet_ids) <= 3
    error_message = "Must provide between 1 and 3 subnet IDs."
  }
}

variable "security_groups" {
  description = <<-EOT
    List of security group IDs to assign to the broker.

    The security groups must allow inbound traffic on the appropriate ports:
    - ActiveMQ: 61617 (OpenWire), 8162 (Web Console), 5671 (AMQP), 61614 (STOMP), 1883 (MQTT)
    - RabbitMQ: 5671 (AMQP), 15671 (Web Console)

    Security groups must be in the same VPC as the subnets.
  EOT
  type        = list(string)
}

# -----------------------------------------------------------------------------
# Deployment Configuration
# -----------------------------------------------------------------------------

variable "deployment_mode" {
  description = <<-EOT
    Deployment mode for the broker.

    Valid values:
    - SINGLE_INSTANCE: Single broker in one AZ (dev/test, not HA)
    - ACTIVE_STANDBY_MULTI_AZ: Active/Standby pair across 2 AZs (HA for ActiveMQ)
    - CLUSTER_MULTI_AZ: Cluster of 3 nodes across 3 AZs (HA for RabbitMQ only)

    ActiveMQ supports: SINGLE_INSTANCE, ACTIVE_STANDBY_MULTI_AZ
    RabbitMQ supports: SINGLE_INSTANCE, CLUSTER_MULTI_AZ
  EOT
  type        = string
  default     = "SINGLE_INSTANCE"

  validation {
    condition     = contains(["SINGLE_INSTANCE", "ACTIVE_STANDBY_MULTI_AZ", "CLUSTER_MULTI_AZ"], var.deployment_mode)
    error_message = "Deployment mode must be SINGLE_INSTANCE, ACTIVE_STANDBY_MULTI_AZ, or CLUSTER_MULTI_AZ."
  }
}

variable "publicly_accessible" {
  description = <<-EOT
    Enable public accessibility for the broker.

    - true: Broker endpoints are accessible from the internet (requires public subnets)
    - false: Broker endpoints are only accessible from within the VPC (recommended)

    For production workloads, set to false and access via VPC/VPN/Direct Connect.
  EOT
  type        = bool
  default     = false
}

variable "storage_type" {
  description = <<-EOT
    Storage type for the broker.

    Valid values:
    - EBS: Elastic Block Store (default, recommended for most use cases)
    - EFS: Elastic File System (ActiveMQ only, for shared storage in multi-AZ)

    RabbitMQ only supports EBS.
  EOT
  type        = string
  default     = "EBS"

  validation {
    condition     = contains(["EBS", "EFS"], var.storage_type)
    error_message = "Storage type must be either 'EBS' or 'EFS'."
  }
}

# -----------------------------------------------------------------------------
# Authentication Configuration
# -----------------------------------------------------------------------------

variable "authentication_strategy" {
  description = <<-EOT
    Authentication strategy for the broker.

    Valid values:
    - SIMPLE: Simple username/password authentication (default)
    - LDAP: LDAP-based authentication (ActiveMQ only, requires ldap_server_metadata)

    RabbitMQ only supports SIMPLE authentication.
  EOT
  type        = string
  default     = "SIMPLE"

  validation {
    condition     = contains(["SIMPLE", "LDAP"], var.authentication_strategy)
    error_message = "Authentication strategy must be either 'SIMPLE' or 'LDAP'."
  }
}

variable "ldap_server_metadata" {
  description = <<-EOT
    LDAP server configuration for authentication (ActiveMQ only).
    Only used when authentication_strategy = "LDAP".

    Required fields:
    - hosts: List of LDAP server hosts (e.g., ["ldap://example.com:389"])
    - role_base: Base DN for role search
    - role_search_matching: LDAP search filter for roles
    - service_account_username: DN of service account
    - service_account_password: Password for service account
    - user_base: Base DN for user search
    - user_search_matching: LDAP search filter for users

    Optional fields:
    - role_name: Attribute for role name
    - role_search_subtree: Search role subtree (default: false)
    - user_role_name: Attribute for user role name
    - user_search_subtree: Search user subtree (default: false)
  EOT
  type = object({
    hosts                    = list(string)
    role_base                = string
    role_search_matching     = string
    service_account_password = string
    service_account_username = string
    user_base                = string
    user_search_matching     = string
    role_name                = optional(string)
    role_search_subtree      = optional(bool)
    user_role_name           = optional(string)
    user_search_subtree      = optional(bool)
  })
  default   = null
  sensitive = true
}

# -----------------------------------------------------------------------------
# Security Configuration
# -----------------------------------------------------------------------------

variable "kms_key_id" {
  description = <<-EOT
    ARN of AWS KMS key for encryption at rest.

    - If specified: Uses customer-managed KMS key
    - If null: Uses AWS-owned key (default, no additional cost)

    Customer-managed KMS keys provide:
    - Control over key policies and rotation
    - CloudTrail audit logs of key usage
    - Required for compliance scenarios
  EOT
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Monitoring Configuration
# -----------------------------------------------------------------------------

variable "enable_general_log" {
  description = <<-EOT
    Enable general logging to CloudWatch Logs.

    General logs contain informational messages about the broker's operation.
    Useful for troubleshooting and monitoring.
  EOT
  type        = bool
  default     = false
}

variable "enable_audit_log" {
  description = <<-EOT
    Enable audit logging to CloudWatch Logs (ActiveMQ only).

    Audit logs track management actions and user authentication.
    Recommended for compliance and security monitoring.
  EOT
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Maintenance Configuration
# -----------------------------------------------------------------------------

variable "auto_minor_version_upgrade" {
  description = <<-EOT
    Enable automatic minor version upgrades during maintenance windows.

    - true: Automatically upgrade to newer minor versions (recommended)
    - false: Manual control over version upgrades

    Minor version upgrades include bug fixes and security patches.
  EOT
  type        = bool
  default     = true
}

variable "maintenance_day_of_week" {
  description = <<-EOT
    Day of the week for maintenance window.

    Valid values: MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY

    Default is SUNDAY.
  EOT
  type        = string
  default     = "SUNDAY"

  validation {
    condition     = contains(["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"], var.maintenance_day_of_week)
    error_message = "Maintenance day must be a valid day of the week."
  }
}

variable "maintenance_time_of_day" {
  description = <<-EOT
    Time of day for maintenance window in HH:MM format (24-hour clock).

    Example: "03:00" for 3:00 AM

    Only used when maintenance_day_of_week is set.
  EOT
  type        = string
  default     = "03:00"

  validation {
    condition     = can(regex("^([0-1][0-9]|2[0-3]):[0-5][0-9]$", var.maintenance_time_of_day))
    error_message = "Maintenance time must be in HH:MM format (24-hour clock)."
  }
}

variable "maintenance_time_zone" {
  description = <<-EOT
    Time zone for the maintenance window.

    Example: "America/New_York", "UTC", "Europe/London"

    Only used when maintenance_day_of_week is set.
    For valid time zones, see IANA Time Zone Database.
  EOT
  type        = string
  default     = "UTC"
}

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to all resources. Use this for consistent resource tagging across your infrastructure."
  type        = map(string)
  default     = {}
}
