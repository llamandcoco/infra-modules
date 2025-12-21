# AWS Cognito

A production-ready Terraform module for AWS Cognito User Pools and Identity Pools with comprehensive authentication and authorization features.

## Features

- **User Pools** - User directory and authentication service
- **Identity Pools** - Provide AWS credentials to authenticated users
- **Hosted UI** - Pre-built authentication UI with OAuth 2.0 support
- **MFA Support** - SMS and TOTP-based multi-factor authentication
- **Advanced Security** - Adaptive authentication and compromised credentials detection
- **Custom Attributes** - Extend user profiles with custom data
- **Lambda Triggers** - Customize authentication flows with Lambda functions

## Quick Start

```hcl
module "cognito" {
  source = "github.com/llamandcoco/infra-modules//terraform/cognito?ref=<commit-sha>"

  user_pool_name = "my-app-users"

  # Email-based sign-in
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Optional MFA
  mfa_configuration = "OPTIONAL"

  # User pool client
  user_pool_clients = [
    {
      name = "web-client"
      explicit_auth_flows = [
        "ALLOW_USER_SRP_AUTH",
        "ALLOW_REFRESH_TOKEN_AUTH"
      ]
    }
  ]
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|----------|
| Basic - Simple user pool with email auth | [`tests/basic/main.tf`](tests/basic/main.tf) |
| Advanced - Full setup with identity pool and OAuth | [`tests/advanced/main.tf`](tests/advanced/main.tf) |

**Usage:**
```bash
# View example
cat tests/basic/main.tf

# Copy and adapt
cp -r tests/basic/ my-project/
```

## Use Cases

### 1. Basic Email Authentication

Simple user pool for web application:

```hcl
module "cognito" {
  source = "github.com/llamandcoco/infra-modules//terraform/cognito?ref=<commit-sha>"

  user_pool_name = "my-app-users"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  mfa_configuration        = "OPTIONAL"

  user_pool_clients = [
    {
      name = "web-app"
    }
  ]
}
```

### 2. With Hosted UI and OAuth 2.0

Use Cognito's hosted authentication UI:

```hcl
module "cognito" {
  source = "github.com/llamandcoco/infra-modules//terraform/cognito?ref=<commit-sha>"

  user_pool_name = "my-app-users"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  user_pool_clients = [
    {
      name = "web-app"

      # OAuth configuration
      allowed_oauth_flows = ["code", "implicit"]
      allowed_oauth_scopes = ["email", "openid", "profile"]
      allowed_oauth_flows_user_pool_client = true

      callback_urls = ["https://myapp.com/callback"]
      logout_urls   = ["https://myapp.com/logout"]

      supported_identity_providers = ["COGNITO"]
    }
  ]

  # Hosted UI domain
  user_pool_domain = "my-app-auth"
}
```

Login URL: `https://my-app-auth.auth.us-east-1.amazoncognito.com/login`

### 3. With Identity Pool for AWS Credentials

Give authenticated users access to AWS services:

```hcl
module "cognito" {
  source = "github.com/llamandcoco/infra-modules//terraform/cognito?ref=<commit-sha>"

  user_pool_name = "my-app-users"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  user_pool_clients = [
    {
      name                    = "web-app"
      server_side_token_check = true
    }
  ]

  # Identity pool
  create_identity_pool = true
  identity_pool_name   = "my-app-identity-pool"

  # IAM permissions for authenticated users
  authenticated_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    aws_iam_policy.bedrock_access.arn
  ]
}

# Custom policy for Bedrock access
resource "aws_iam_policy" "bedrock_access" {
  name = "bedrock-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = "*"
      }
    ]
  })
}
```

### 4. With Custom Attributes

Extend user profiles with application-specific data:

```hcl
module "cognito" {
  source = "github.com/llamandcoco/infra-modules//terraform/cognito?ref=<commit-sha>"

  user_pool_name = "my-app-users"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Custom attributes
  schema_attributes = [
    {
      name                = "tenant_id"
      attribute_data_type = "String"
      mutable             = false
      required            = true
      min_length          = 1
      max_length          = 256
    },
    {
      name                = "subscription_tier"
      attribute_data_type = "String"
      mutable             = true
      required            = false
      min_length          = 1
      max_length          = 50
    }
  ]

  user_pool_clients = [
    {
      name = "web-app"
      write_attributes = [
        "email",
        "custom:subscription_tier"
      ]
    }
  ]
}
```

### 5. With Advanced Security

Enable adaptive authentication and compromised credentials detection:

```hcl
module "cognito" {
  source = "github.com/llamandcoco/infra-modules//terraform/cognito?ref=<commit-sha>"

  user_pool_name = "my-app-users"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  mfa_configuration        = "ON"

  # Advanced security
  enable_advanced_security = true
  advanced_security_mode   = "ENFORCED"

  # Strong password policy
  password_minimum_length    = 12
  password_require_lowercase = true
  password_require_uppercase = true
  password_require_numbers   = true
  password_require_symbols   = true

  user_pool_clients = [
    {
      name = "web-app"
    }
  ]

  deletion_protection = "ACTIVE"
}
```

### 6. Multi-Tenant SaaS Application

Separate users by tenant with custom attributes:

```hcl
module "cognito" {
  source = "github.com/llamandcoco/infra-modules//terraform/cognito?ref=<commit-sha>"

  user_pool_name = "saas-app-users"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  username_case_sensitive  = false

  schema_attributes = [
    {
      name                = "tenant_id"
      attribute_data_type = "String"
      mutable             = false
      required            = true
      min_length          = 1
      max_length          = 256
    },
    {
      name                = "role"
      attribute_data_type = "String"
      mutable             = true
      required            = false
      min_length          = 1
      max_length          = 50
    }
  ]

  user_pool_clients = [
    {
      name = "web-app"

      # Include tenant_id in token
      read_attributes = [
        "email",
        "custom:tenant_id",
        "custom:role"
      ]
    }
  ]
}
```

## Authentication Flows

### User Password Auth (SRP)

Secure Remote Password protocol (recommended):

```python
import boto3
from warrant import Cognito

cognito = Cognito(
    user_pool_id='<pool-id>',
    client_id='<client-id>',
    user_pool_region='us-east-1'
)

# Authenticate
cognito.authenticate(password='user_password')

# Get tokens
id_token = cognito.id_token
access_token = cognito.access_token
refresh_token = cognito.refresh_token
```

### OAuth 2.0 Authorization Code Flow

For web applications with hosted UI:

```javascript
// Redirect to hosted UI
const loginUrl = `https://${domain}.auth.us-east-1.amazoncognito.com/login?` +
  `client_id=${clientId}&` +
  `response_type=code&` +
  `scope=email+openid+profile&` +
  `redirect_uri=${encodeURIComponent(callbackUrl)}`;

window.location.href = loginUrl;

// Handle callback
const code = new URLSearchParams(window.location.search).get('code');

// Exchange code for tokens
const response = await fetch(`https://${domain}.auth.us-east-1.amazoncognito.com/oauth2/token`, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/x-www-form-urlencoded'
  },
  body: new URLSearchParams({
    grant_type: 'authorization_code',
    client_id: clientId,
    code: code,
    redirect_uri: callbackUrl
  })
});

const tokens = await response.json();
```

### Getting AWS Credentials

Use Identity Pool to get temporary AWS credentials:

```python
import boto3

# Get ID token from User Pool authentication (see above)
id_token = cognito.id_token

# Get credentials from Identity Pool
cognito_identity = boto3.client('cognito-identity')

# Get identity ID
identity_response = cognito_identity.get_id(
    IdentityPoolId='<identity-pool-id>',
    Logins={
        '<user-pool-endpoint>': id_token
    }
)

# Get credentials
credentials_response = cognito_identity.get_credentials_for_identity(
    IdentityId=identity_response['IdentityId'],
    Logins={
        '<user-pool-endpoint>': id_token
    }
)

# Use credentials
credentials = credentials_response['Credentials']

# Create AWS client with credentials
s3 = boto3.client(
    's3',
    aws_access_key_id=credentials['AccessKeyId'],
    aws_secret_access_key=credentials['SecretKey'],
    aws_session_token=credentials['SessionToken']
)
```

## MFA Configuration

### TOTP (Software Token) MFA

Recommended for most applications:

```hcl
mfa_configuration = "OPTIONAL"  # or "ON" to require MFA
```

Users can use authenticator apps like Google Authenticator, Authy, etc.

### SMS MFA

Requires SNS permissions:

```hcl
module "cognito" {
  source = "github.com/llamandcoco/infra-modules//terraform/cognito?ref=<commit-sha>"

  user_pool_name    = "my-app-users"
  mfa_configuration = "ON"

  # SMS configuration (role created automatically)
  sms_configuration_external_id = "my-app-sms"
}
```

**Note**: SMS MFA has additional costs and regional restrictions.

## API Gateway Integration

Use Cognito as an authorizer for API Gateway:

```hcl
# API Gateway
resource "aws_api_gateway_rest_api" "this" {
  name = "my-api"
}

# Cognito authorizer
resource "aws_api_gateway_authorizer" "cognito" {
  name          = "cognito-authorizer"
  rest_api_id   = aws_api_gateway_rest_api.this.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [module.cognito.user_pool_arn]
}

# Protected method
resource "aws_api_gateway_method" "protected" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}
```

## Lambda Triggers

Customize authentication flows with Lambda:

```hcl
# Lambda function for pre-signup validation
resource "aws_lambda_function" "pre_signup" {
  function_name = "cognito-pre-signup"
  handler       = "index.handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda.arn
  filename      = "lambda.zip"
}

# Lambda permission
resource "aws_lambda_permission" "cognito" {
  statement_id  = "AllowCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pre_signup.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = module.cognito.user_pool_arn
}

# Cognito with Lambda trigger
module "cognito" {
  source = "github.com/llamandcoco/infra-modules//terraform/cognito?ref=<commit-sha>"

  user_pool_name           = "my-app-users"
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  lambda_config = {
    pre_sign_up = aws_lambda_function.pre_signup.arn
  }

  user_pool_clients = [
    {
      name = "web-app"
    }
  ]
}
```

**Available Lambda Triggers:**
- `pre_sign_up` - Before user registration
- `post_confirmation` - After user confirms account
- `pre_authentication` - Before sign-in
- `post_authentication` - After successful sign-in
- `pre_token_generation` - Before token generation
- `custom_message` - Customize email/SMS messages
- `user_migration` - Migrate users from external system

## Password Policy

Configure password requirements:

```hcl
module "cognito" {
  source = "github.com/llamandcoco/infra-modules//terraform/cognito?ref=<commit-sha>"

  user_pool_name = "my-app-users"

  # Strong password policy
  password_minimum_length            = 12
  password_require_lowercase         = true
  password_require_uppercase         = true
  password_require_numbers           = true
  password_require_symbols           = true
  temporary_password_validity_days   = 3

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  user_pool_clients = [
    {
      name = "web-app"
    }
  ]
}
```

## User Pool Clients

### Web Application Client

```hcl
{
  name = "web-app"

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  # Token validity
  access_token_validity       = 60
  id_token_validity           = 60
  refresh_token_validity      = 30
  access_token_validity_unit  = "minutes"
  id_token_validity_unit      = "minutes"
  refresh_token_validity_unit = "days"
}
```

### Mobile Application Client

```hcl
{
  name = "mobile-app"

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_CUSTOM_AUTH"
  ]

  # Longer refresh token for mobile
  refresh_token_validity      = 90
  refresh_token_validity_unit = "days"
}
```

### Server-Side Application Client

```hcl
{
  name            = "backend-service"
  generate_secret = true

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  server_side_token_check = true
}
```

## Testing

```bash
# Basic test
cd tests/basic && terraform init && terraform plan

# Advanced test
cd tests/advanced && terraform init && terraform plan
```

## Notes

- **Username Attributes**: Cannot be changed after user pool creation
- **Custom Attributes**: Cannot be deleted or made required after creation
- **MFA**: SMS MFA requires SNS spend limits to be increased
- **Identity Pools**: Require user pool clients with `server_side_token_check = true`
- **Hosted UI**: Requires a user pool domain
- **Token Expiration**: Balance security with user experience
- **Deletion Protection**: Enable for production user pools

## Best Practices

1. **Use Email for Username**: More user-friendly than usernames
2. **Enable MFA**: At least optional MFA for security
3. **Strong Password Policy**: 12+ characters with complexity requirements
4. **Advanced Security**: Enable for production environments
5. **Token Validity**: Short-lived access tokens (60 min), longer refresh tokens (30 days)
6. **Custom Attributes**: Plan carefully - they cannot be deleted
7. **Deletion Protection**: Always enable for production
8. **Identity Pool**: Use for giving users AWS access (S3, DynamoDB, Bedrock, etc.)

## Common Patterns

### AI Agent Authentication

Authenticate users before they access your AI agents:

```hcl
# Cognito for user authentication
module "cognito" {
  source = "github.com/llamandcoco/infra-modules//terraform/cognito?ref=<commit-sha>"

  user_pool_name           = "ai-agent-users"
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  mfa_configuration        = "OPTIONAL"

  user_pool_clients = [
    {
      name                    = "agent-app"
      server_side_token_check = true
    }
  ]

  # Identity pool for Bedrock access
  create_identity_pool = true

  authenticated_role_policy_arns = [
    aws_iam_policy.bedrock_agent_access.arn
  ]
}

# IAM policy for Bedrock agent access
resource "aws_iam_policy" "bedrock_agent_access" {
  name = "bedrock-agent-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeAgent"
        ]
        Resource = module.bedrock_agent.agent_arn
      }
    ]
  })
}
```

### Multi-Tenant SaaS

Use custom attributes for tenant isolation:

```hcl
schema_attributes = [
  {
    name                = "tenant_id"
    attribute_data_type = "String"
    mutable             = false  # Cannot change once set
    required            = true
  }
]
```

Then in your Lambda functions, extract tenant_id from the JWT token and enforce tenant isolation.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
