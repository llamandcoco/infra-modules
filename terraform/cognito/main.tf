terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Local Variables
# -----------------------------------------------------------------------------

locals {
  # Common tags to apply to all resources
  common_tags = merge(
    var.tags,
    {
      ManagedBy = "Terraform"
      Module    = "cognito"
    }
  )

  # Determine if we should create identity pool
  create_identity_pool = var.create_identity_pool

  # Determine if we should create user pool domain
  create_domain = var.user_pool_domain != null
}

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# -----------------------------------------------------------------------------
# Cognito User Pool
# Manages user directory and authentication
# -----------------------------------------------------------------------------
resource "aws_cognito_user_pool" "this" {
  name = var.user_pool_name

  # Username configuration
  username_attributes      = var.username_attributes
  auto_verified_attributes = var.auto_verified_attributes

  # Username case sensitivity
  username_configuration {
    case_sensitive = var.username_case_sensitive
  }

  # Alias attributes (alternative login methods)
  dynamic "alias_attributes" {
    for_each = length(var.alias_attributes) > 0 ? [1] : []
    content {
      alias_attributes = var.alias_attributes
    }
  }

  # Password policy
  password_policy {
    minimum_length                   = var.password_minimum_length
    require_lowercase                = var.password_require_lowercase
    require_uppercase                = var.password_require_uppercase
    require_numbers                  = var.password_require_numbers
    require_symbols                  = var.password_require_symbols
    temporary_password_validity_days = var.temporary_password_validity_days
  }

  # MFA configuration
  mfa_configuration = var.mfa_configuration

  # Software token MFA (TOTP)
  dynamic "software_token_mfa_configuration" {
    for_each = var.mfa_configuration != "OFF" ? [1] : []

    content {
      enabled = true
    }
  }

  # SMS MFA configuration
  dynamic "sms_configuration" {
    for_each = var.mfa_configuration == "ON" || var.mfa_configuration == "OPTIONAL" ? [1] : []

    content {
      external_id    = var.sms_configuration_external_id
      sns_caller_arn = var.sms_configuration_sns_caller_arn != null ? var.sms_configuration_sns_caller_arn : aws_iam_role.sms[0].arn
      sns_region     = var.sms_configuration_sns_region != null ? var.sms_configuration_sns_region : data.aws_region.current.name
    }
  }

  # Account recovery settings
  dynamic "account_recovery_setting" {
    for_each = length(var.account_recovery_mechanisms) > 0 ? [1] : []

    content {
      dynamic "recovery_mechanism" {
        for_each = var.account_recovery_mechanisms

        content {
          name     = recovery_mechanism.value.name
          priority = recovery_mechanism.value.priority
        }
      }
    }
  }

  # Email configuration
  dynamic "email_configuration" {
    for_each = var.email_configuration != null ? [var.email_configuration] : []

    content {
      email_sending_account  = email_configuration.value.email_sending_account
      from_email_address     = email_configuration.value.from_email_address
      reply_to_email_address = email_configuration.value.reply_to_email_address
      source_arn             = email_configuration.value.source_arn
      configuration_set      = email_configuration.value.configuration_set
    }
  }

  # User attribute schema (custom attributes)
  dynamic "schema" {
    for_each = var.schema_attributes

    content {
      name                     = schema.value.name
      attribute_data_type      = schema.value.attribute_data_type
      developer_only_attribute = lookup(schema.value, "developer_only_attribute", false)
      mutable                  = lookup(schema.value, "mutable", true)
      required                 = lookup(schema.value, "required", false)

      dynamic "string_attribute_constraints" {
        for_each = schema.value.attribute_data_type == "String" ? [1] : []

        content {
          min_length = lookup(schema.value, "min_length", 0)
          max_length = lookup(schema.value, "max_length", 2048)
        }
      }

      dynamic "number_attribute_constraints" {
        for_each = schema.value.attribute_data_type == "Number" ? [1] : []

        content {
          min_value = lookup(schema.value, "min_value", 0)
          max_value = lookup(schema.value, "max_value", 2048)
        }
      }
    }
  }

  # Lambda triggers
  dynamic "lambda_config" {
    for_each = length(var.lambda_config) > 0 ? [var.lambda_config] : []

    content {
      pre_sign_up                    = lookup(lambda_config.value, "pre_sign_up", null)
      post_confirmation              = lookup(lambda_config.value, "post_confirmation", null)
      pre_authentication             = lookup(lambda_config.value, "pre_authentication", null)
      post_authentication            = lookup(lambda_config.value, "post_authentication", null)
      pre_token_generation           = lookup(lambda_config.value, "pre_token_generation", null)
      user_migration                 = lookup(lambda_config.value, "user_migration", null)
      custom_message                 = lookup(lambda_config.value, "custom_message", null)
      define_auth_challenge          = lookup(lambda_config.value, "define_auth_challenge", null)
      create_auth_challenge          = lookup(lambda_config.value, "create_auth_challenge", null)
      verify_auth_challenge_response = lookup(lambda_config.value, "verify_auth_challenge_response", null)
    }
  }

  # User pool add-ons
  dynamic "user_pool_add_ons" {
    for_each = var.enable_advanced_security ? [1] : []

    content {
      advanced_security_mode = var.advanced_security_mode
    }
  }

  # Device tracking
  dynamic "device_configuration" {
    for_each = var.device_tracking != null ? [1] : []

    content {
      challenge_required_on_new_device      = var.device_tracking.challenge_required_on_new_device
      device_only_remembered_on_user_prompt = var.device_tracking.device_only_remembered_on_user_prompt
    }
  }

  # Deletion protection
  deletion_protection = var.deletion_protection

  tags = merge(
    local.common_tags,
    {
      Name = var.user_pool_name
    }
  )
}

# -----------------------------------------------------------------------------
# IAM Role for SMS MFA
# Allows Cognito to send SMS via SNS
# -----------------------------------------------------------------------------
resource "aws_iam_role" "sms" {
  count = (var.mfa_configuration == "ON" || var.mfa_configuration == "OPTIONAL") && var.sms_configuration_sns_caller_arn == null ? 1 : 0

  name        = "${var.user_pool_name}-sms-role"
  description = "IAM role for Cognito User Pool to send SMS messages"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cognito-idp.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.sms_configuration_external_id
          }
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${var.user_pool_name}-sms-role"
    }
  )
}

resource "aws_iam_role_policy" "sms" {
  count = (var.mfa_configuration == "ON" || var.mfa_configuration == "OPTIONAL") && var.sms_configuration_sns_caller_arn == null ? 1 : 0

  name = "cognito-sms-policy"
  role = aws_iam_role.sms[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = "*"
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# User Pool Clients
# Applications that can authenticate users
# -----------------------------------------------------------------------------
resource "aws_cognito_user_pool_client" "this" {
  for_each = { for client in var.user_pool_clients : client.name => client }

  name         = each.value.name
  user_pool_id = aws_cognito_user_pool.this.id

  # OAuth configuration
  allowed_oauth_flows                  = lookup(each.value, "allowed_oauth_flows", [])
  allowed_oauth_scopes                 = lookup(each.value, "allowed_oauth_scopes", [])
  allowed_oauth_flows_user_pool_client = lookup(each.value, "allowed_oauth_flows_user_pool_client", false)
  callback_urls                        = lookup(each.value, "callback_urls", [])
  logout_urls                          = lookup(each.value, "logout_urls", [])
  supported_identity_providers         = lookup(each.value, "supported_identity_providers", [])

  # Token validity
  access_token_validity  = lookup(each.value, "access_token_validity", 60)
  id_token_validity      = lookup(each.value, "id_token_validity", 60)
  refresh_token_validity = lookup(each.value, "refresh_token_validity", 30)

  token_validity_units {
    access_token  = lookup(each.value, "access_token_validity_unit", "minutes")
    id_token      = lookup(each.value, "id_token_validity_unit", "minutes")
    refresh_token = lookup(each.value, "refresh_token_validity_unit", "days")
  }

  # Client secret
  generate_secret = lookup(each.value, "generate_secret", false)

  # Prevent user existence errors
  prevent_user_existence_errors = lookup(each.value, "prevent_user_existence_errors", "ENABLED")

  # Read and write attributes
  read_attributes  = lookup(each.value, "read_attributes", [])
  write_attributes = lookup(each.value, "write_attributes", [])

  # Enable token revocation
  enable_token_revocation = lookup(each.value, "enable_token_revocation", true)

  # Explicit auth flows
  explicit_auth_flows = lookup(each.value, "explicit_auth_flows", [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ])
}

# -----------------------------------------------------------------------------
# User Pool Domain
# Hosted UI domain for authentication
# -----------------------------------------------------------------------------
resource "aws_cognito_user_pool_domain" "this" {
  count = local.create_domain ? 1 : 0

  domain          = var.user_pool_domain
  user_pool_id    = aws_cognito_user_pool.this.id
  certificate_arn = var.user_pool_domain_certificate_arn
}

# -----------------------------------------------------------------------------
# Identity Pool
# Provides AWS credentials to authenticated users
# -----------------------------------------------------------------------------
resource "aws_cognito_identity_pool" "this" {
  count = local.create_identity_pool ? 1 : 0

  identity_pool_name               = var.identity_pool_name != null ? var.identity_pool_name : "${var.user_pool_name}-identity-pool"
  allow_unauthenticated_identities = var.allow_unauthenticated_identities
  allow_classic_flow               = var.allow_classic_flow

  # Cognito Identity Providers (User Pools)
  dynamic "cognito_identity_providers" {
    for_each = var.user_pool_clients

    content {
      client_id               = aws_cognito_user_pool_client.this[cognito_identity_providers.value.name].id
      provider_name           = aws_cognito_user_pool.this.endpoint
      server_side_token_check = lookup(cognito_identity_providers.value, "server_side_token_check", false)
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = var.identity_pool_name != null ? var.identity_pool_name : "${var.user_pool_name}-identity-pool"
    }
  )
}

# -----------------------------------------------------------------------------
# IAM Roles for Identity Pool
# -----------------------------------------------------------------------------

# Authenticated role
resource "aws_iam_role" "authenticated" {
  count = local.create_identity_pool ? 1 : 0

  name        = "${var.user_pool_name}-authenticated-role"
  description = "IAM role for authenticated Cognito users"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.this[0].id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${var.user_pool_name}-authenticated-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "authenticated" {
  for_each = local.create_identity_pool ? toset(var.authenticated_role_policy_arns) : []

  role       = aws_iam_role.authenticated[0].name
  policy_arn = each.value
}

# Unauthenticated role (if allowed)
resource "aws_iam_role" "unauthenticated" {
  count = local.create_identity_pool && var.allow_unauthenticated_identities ? 1 : 0

  name        = "${var.user_pool_name}-unauthenticated-role"
  description = "IAM role for unauthenticated Cognito users"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.this[0].id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "unauthenticated"
          }
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${var.user_pool_name}-unauthenticated-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "unauthenticated" {
  for_each = local.create_identity_pool && var.allow_unauthenticated_identities ? toset(var.unauthenticated_role_policy_arns) : []

  role       = aws_iam_role.unauthenticated[0].name
  policy_arn = each.value
}

# Attach roles to identity pool
resource "aws_cognito_identity_pool_roles_attachment" "this" {
  count = local.create_identity_pool ? 1 : 0

  identity_pool_id = aws_cognito_identity_pool.this[0].id

  roles = merge(
    {
      authenticated = aws_iam_role.authenticated[0].arn
    },
    var.allow_unauthenticated_identities ? {
      unauthenticated = aws_iam_role.unauthenticated[0].arn
    } : {}
  )
}
