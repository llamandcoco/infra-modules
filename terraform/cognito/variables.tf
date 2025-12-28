# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "user_pool_name" {
  description = "Name of the Cognito User Pool. This will be displayed in the AWS console."
  type        = string

  validation {
    condition     = length(var.user_pool_name) > 0 && length(var.user_pool_name) <= 128
    error_message = "User pool name must be between 1 and 128 characters."
  }
}

# -----------------------------------------------------------------------------
# User Pool Configuration
# -----------------------------------------------------------------------------

variable "username_attributes" {
  description = "Whether email addresses or phone numbers can be used as usernames. Valid values: 'email', 'phone_number'. Cannot be changed after creation."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for attr in var.username_attributes : contains(["email", "phone_number"], attr)
    ])
    error_message = "Username attributes must be 'email' or 'phone_number'."
  }
}

variable "auto_verified_attributes" {
  description = "Attributes to auto-verify. Valid values: 'email', 'phone_number'."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for attr in var.auto_verified_attributes : contains(["email", "phone_number"], attr)
    ])
    error_message = "Auto verified attributes must be 'email' or 'phone_number'."
  }
}

variable "username_case_sensitive" {
  description = "Whether username is case sensitive. Cannot be changed after creation."
  type        = bool
  default     = false
}

variable "alias_attributes" {
  description = "Attributes that can be used as aliases for user pool sign-in. Valid values: 'email', 'phone_number', 'preferred_username'."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for attr in var.alias_attributes : contains(["email", "phone_number", "preferred_username"], attr)
    ])
    error_message = "Alias attributes must be 'email', 'phone_number', or 'preferred_username'."
  }
}

# -----------------------------------------------------------------------------
# Password Policy
# -----------------------------------------------------------------------------

variable "password_minimum_length" {
  description = "Minimum password length. Valid range: 6-99."
  type        = number
  default     = 8

  validation {
    condition     = var.password_minimum_length >= 6 && var.password_minimum_length <= 99
    error_message = "Password minimum length must be between 6 and 99."
  }
}

variable "password_require_lowercase" {
  description = "Whether password must contain at least one lowercase letter."
  type        = bool
  default     = true
}

variable "password_require_uppercase" {
  description = "Whether password must contain at least one uppercase letter."
  type        = bool
  default     = true
}

variable "password_require_numbers" {
  description = "Whether password must contain at least one number."
  type        = bool
  default     = true
}

variable "password_require_symbols" {
  description = "Whether password must contain at least one special character."
  type        = bool
  default     = true
}

variable "temporary_password_validity_days" {
  description = "Number of days a temporary password is valid. Valid range: 1-365."
  type        = number
  default     = 7

  validation {
    condition     = var.temporary_password_validity_days >= 1 && var.temporary_password_validity_days <= 365
    error_message = "Temporary password validity must be between 1 and 365 days."
  }
}

# -----------------------------------------------------------------------------
# MFA Configuration
# -----------------------------------------------------------------------------

variable "mfa_configuration" {
  description = "Multi-factor authentication configuration. Valid values: 'OFF', 'ON', 'OPTIONAL'."
  type        = string
  default     = "OPTIONAL"

  validation {
    condition     = contains(["OFF", "ON", "OPTIONAL"], var.mfa_configuration)
    error_message = "MFA configuration must be 'OFF', 'ON', or 'OPTIONAL'."
  }
}

variable "sms_configuration_external_id" {
  description = "External ID for SMS configuration. Used when assuming IAM role for SNS."
  type        = string
  default     = "cognito-sms"
}

variable "sms_configuration_sns_caller_arn" {
  description = "ARN of the IAM role for SNS SMS sending. If not specified, a role will be created."
  type        = string
  default     = null
}

variable "sms_configuration_sns_region" {
  description = "AWS region for SNS. If not specified, uses current region."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Account Recovery
# -----------------------------------------------------------------------------

variable "account_recovery_mechanisms" {
  description = "List of account recovery mechanisms with priorities. Valid names: 'verified_email', 'verified_phone_number', 'admin_only'."
  type = list(object({
    name     = string
    priority = number
  }))
  default = [
    {
      name     = "verified_email"
      priority = 1
    }
  ]

  validation {
    condition = alltrue([
      for mechanism in var.account_recovery_mechanisms : contains(["verified_email", "verified_phone_number", "admin_only"], mechanism.name)
    ])
    error_message = "Recovery mechanism names must be 'verified_email', 'verified_phone_number', or 'admin_only'."
  }
}

# -----------------------------------------------------------------------------
# Email Configuration
# -----------------------------------------------------------------------------

variable "email_configuration" {
  description = "Email configuration for the user pool. Use SES for production."
  type = object({
    email_sending_account  = string
    from_email_address     = optional(string)
    reply_to_email_address = optional(string)
    source_arn             = optional(string)
    configuration_set      = optional(string)
  })
  default = null

  validation {
    condition = var.email_configuration == null || (
      contains(["COGNITO_DEFAULT", "DEVELOPER"], var.email_configuration.email_sending_account)
    )
    error_message = "email_sending_account must be 'COGNITO_DEFAULT' or 'DEVELOPER'."
  }
}

# -----------------------------------------------------------------------------
# Custom Attributes Schema
# -----------------------------------------------------------------------------

variable "schema_attributes" {
  description = "List of custom schema attributes for the user pool."
  type = list(object({
    name                     = string
    attribute_data_type      = string
    developer_only_attribute = optional(bool, false)
    mutable                  = optional(bool, true)
    required                 = optional(bool, false)
    min_length               = optional(number)
    max_length               = optional(number)
    min_value                = optional(number)
    max_value                = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for attr in var.schema_attributes : contains(["String", "Number", "DateTime", "Boolean"], attr.attribute_data_type)
    ])
    error_message = "Attribute data type must be 'String', 'Number', 'DateTime', or 'Boolean'."
  }
}

# -----------------------------------------------------------------------------
# Lambda Triggers
# -----------------------------------------------------------------------------

variable "lambda_config" {
  description = "Lambda trigger configuration for user pool events."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Advanced Security
# -----------------------------------------------------------------------------

variable "enable_advanced_security" {
  description = "Enable advanced security features (adaptive authentication, compromised credentials detection)."
  type        = bool
  default     = false
}

variable "advanced_security_mode" {
  description = "Advanced security mode. Valid values: 'OFF', 'AUDIT', 'ENFORCED'. Requires enable_advanced_security = true."
  type        = string
  default     = "AUDIT"

  validation {
    condition     = contains(["OFF", "AUDIT", "ENFORCED"], var.advanced_security_mode)
    error_message = "Advanced security mode must be 'OFF', 'AUDIT', or 'ENFORCED'."
  }
}

# -----------------------------------------------------------------------------
# Device Tracking
# -----------------------------------------------------------------------------

variable "device_tracking" {
  description = "Device tracking configuration."
  type = object({
    challenge_required_on_new_device      = bool
    device_only_remembered_on_user_prompt = bool
  })
  default = null
}

# -----------------------------------------------------------------------------
# Deletion Protection
# -----------------------------------------------------------------------------

variable "deletion_protection" {
  description = "Enable deletion protection for the user pool. Valid values: 'ACTIVE', 'INACTIVE'."
  type        = string
  default     = "INACTIVE"

  validation {
    condition     = contains(["ACTIVE", "INACTIVE"], var.deletion_protection)
    error_message = "Deletion protection must be 'ACTIVE' or 'INACTIVE'."
  }
}

# -----------------------------------------------------------------------------
# User Pool Clients
# -----------------------------------------------------------------------------

variable "user_pool_clients" {
  description = "List of user pool client configurations."
  type = list(object({
    name                                 = string
    allowed_oauth_flows                  = optional(list(string), [])
    allowed_oauth_scopes                 = optional(list(string), [])
    allowed_oauth_flows_user_pool_client = optional(bool, false)
    callback_urls                        = optional(list(string), [])
    logout_urls                          = optional(list(string), [])
    supported_identity_providers         = optional(list(string), [])
    access_token_validity                = optional(number, 60)
    id_token_validity                    = optional(number, 60)
    refresh_token_validity               = optional(number, 30)
    access_token_validity_unit           = optional(string, "minutes")
    id_token_validity_unit               = optional(string, "minutes")
    refresh_token_validity_unit          = optional(string, "days")
    generate_secret                      = optional(bool, false)
    prevent_user_existence_errors        = optional(string, "ENABLED")
    read_attributes                      = optional(list(string), [])
    write_attributes                     = optional(list(string), [])
    enable_token_revocation              = optional(bool, true)
    explicit_auth_flows                  = optional(list(string), ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"])
    server_side_token_check              = optional(bool, false)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# User Pool Domain
# -----------------------------------------------------------------------------

variable "user_pool_domain" {
  description = "Domain name for the hosted UI. If specified, a Cognito domain will be created."
  type        = string
  default     = null
}

variable "user_pool_domain_certificate_arn" {
  description = "ARN of ACM certificate for custom domain. Required for custom domains."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Identity Pool Configuration
# -----------------------------------------------------------------------------

variable "create_identity_pool" {
  description = "Whether to create a Cognito Identity Pool for AWS credentials."
  type        = bool
  default     = false
}

variable "identity_pool_name" {
  description = "Name of the Cognito Identity Pool. If not specified, defaults to '<user_pool_name>-identity-pool'."
  type        = string
  default     = null
}

variable "allow_unauthenticated_identities" {
  description = "Whether to allow unauthenticated identities in the identity pool."
  type        = bool
  default     = false
}

variable "allow_classic_flow" {
  description = "Enable classic (basic) authentication flow for identity pool."
  type        = bool
  default     = false
}

variable "authenticated_role_policy_arns" {
  description = "List of IAM policy ARNs to attach to the authenticated role."
  type        = list(string)
  default     = []
}

variable "unauthenticated_role_policy_arns" {
  description = "List of IAM policy ARNs to attach to the unauthenticated role."
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to all resources. Use this for cost allocation, resource organization, and governance."
  type        = map(string)
  default     = {}
}
