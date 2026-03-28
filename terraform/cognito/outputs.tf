# -----------------------------------------------------------------------------
# User Pool Outputs
# -----------------------------------------------------------------------------

output "user_pool_id" {
  description = "The ID of the Cognito User Pool. Use this for SDK calls and API Gateway authorizers."
  value       = aws_cognito_user_pool.this.id
}

output "user_pool_arn" {
  description = "The ARN of the Cognito User Pool. Use this for IAM policies and resource permissions."
  value       = aws_cognito_user_pool.this.arn
}

output "user_pool_name" {
  description = "The name of the Cognito User Pool."
  value       = aws_cognito_user_pool.this.name
}

output "user_pool_endpoint" {
  description = "The endpoint URL of the Cognito User Pool."
  value       = aws_cognito_user_pool.this.endpoint
}

# -----------------------------------------------------------------------------
# User Pool Client Outputs
# -----------------------------------------------------------------------------

output "user_pool_client_ids" {
  description = "Map of client names to their IDs. Use these for authentication in your applications."
  value = {
    for name, client in aws_cognito_user_pool_client.this :
    name => client.id
  }
}

output "user_pool_client_secrets" {
  description = "Map of client names to their secrets. Only populated for clients with generate_secret = true."
  value = {
    for name, client in aws_cognito_user_pool_client.this :
    name => client.client_secret if client.client_secret != null
  }
  sensitive = true
}

# -----------------------------------------------------------------------------
# User Pool Domain Outputs
# -----------------------------------------------------------------------------

output "user_pool_domain" {
  description = "The Cognito User Pool domain."
  value       = local.create_domain ? aws_cognito_user_pool_domain.this[0].domain : null
}

output "user_pool_domain_cloudfront_distribution" {
  description = "The CloudFront distribution ARN for the domain."
  value       = local.create_domain ? aws_cognito_user_pool_domain.this[0].cloudfront_distribution : null
}

output "hosted_ui_url" {
  description = "The URL for the hosted UI login page."
  value       = local.create_domain ? "https://${aws_cognito_user_pool_domain.this[0].domain}.auth.${provider::aws::region}.amazoncognito.com" : null
}

# -----------------------------------------------------------------------------
# Identity Pool Outputs
# -----------------------------------------------------------------------------

output "identity_pool_id" {
  description = "The ID of the Cognito Identity Pool. Use this to get AWS credentials for authenticated users."
  value       = local.create_identity_pool ? aws_cognito_identity_pool.this[0].id : null
}

output "identity_pool_arn" {
  description = "The ARN of the Cognito Identity Pool."
  value       = local.create_identity_pool ? aws_cognito_identity_pool.this[0].arn : null
}

output "identity_pool_name" {
  description = "The name of the Cognito Identity Pool."
  value       = local.create_identity_pool ? aws_cognito_identity_pool.this[0].identity_pool_name : null
}

# -----------------------------------------------------------------------------
# IAM Role Outputs
# -----------------------------------------------------------------------------

output "authenticated_role_arn" {
  description = "The ARN of the IAM role for authenticated users."
  value       = local.create_identity_pool ? aws_iam_role.authenticated[0].arn : null
}

output "authenticated_role_name" {
  description = "The name of the IAM role for authenticated users."
  value       = local.create_identity_pool ? aws_iam_role.authenticated[0].name : null
}

output "unauthenticated_role_arn" {
  description = "The ARN of the IAM role for unauthenticated users."
  value       = local.create_identity_pool && var.allow_unauthenticated_identities ? aws_iam_role.unauthenticated[0].arn : null
}

output "unauthenticated_role_name" {
  description = "The name of the IAM role for unauthenticated users."
  value       = local.create_identity_pool && var.allow_unauthenticated_identities ? aws_iam_role.unauthenticated[0].name : null
}

# -----------------------------------------------------------------------------
# Configuration Outputs
# -----------------------------------------------------------------------------

output "mfa_configuration" {
  description = "The MFA configuration for the user pool."
  value       = aws_cognito_user_pool.this.mfa_configuration
}

output "region" {
  description = "The AWS region where Cognito resources are deployed."
  value       = provider::aws::region
}

output "account_id" {
  description = "The AWS account ID where Cognito resources are deployed."
  value       = "*"
}

# -----------------------------------------------------------------------------
# SDK Configuration Examples
# -----------------------------------------------------------------------------

output "aws_cli_login_example" {
  description = "AWS CLI example for user authentication."
  value = length(var.user_pool_clients) > 0 ? <<-EOT
    aws cognito-idp initiate-auth \
      --auth-flow USER_SRP_AUTH \
      --client-id ${aws_cognito_user_pool_client.this[var.user_pool_clients[0].name].id} \
      --auth-parameters USERNAME=user@example.com,SRP_A=<srp_a_value>
  EOT
  : "No user pool clients configured"
}

output "boto3_authentication_example" {
  description = "Python boto3 example for user authentication."
  value = length(var.user_pool_clients) > 0 ? <<-EOT
    import boto3
    from warrant import Cognito

    # Using python-jose-cryptodome library
    cognito = Cognito(
        user_pool_id='${aws_cognito_user_pool.this.id}',
        client_id='${aws_cognito_user_pool_client.this[var.user_pool_clients[0].name].id}',
        user_pool_region='${provider::aws::region}'
    )

    # Authenticate user
    cognito.authenticate(password='user_password')

    # Get ID token
    id_token = cognito.id_token

    # Get access token
    access_token = cognito.access_token
  EOT
  : "No user pool clients configured"
}

output "javascript_authentication_example" {
  description = "JavaScript example for user authentication with AWS Amplify."
  value = length(var.user_pool_clients) > 0 ? <<-EOT
    import { Amplify, Auth } from 'aws-amplify';

    Amplify.configure({
      Auth: {
        region: '${provider::aws::region}',
        userPoolId: '${aws_cognito_user_pool.this.id}',
        userPoolWebClientId: '${aws_cognito_user_pool_client.this[var.user_pool_clients[0].name].id}'
      }
    });

    // Sign in
    const user = await Auth.signIn('username', 'password');

    // Get current session
    const session = await Auth.currentSession();
    const idToken = session.getIdToken().getJwtToken();
    const accessToken = session.getAccessToken().getJwtToken();
  EOT
  : "No user pool clients configured"
}

output "identity_pool_credentials_example" {
  description = "Example for getting AWS credentials from Identity Pool."
  value = local.create_identity_pool && length(var.user_pool_clients) > 0 ? <<-EOT
    import boto3
    from warrant import Cognito

    # Step 1: Authenticate with User Pool
    cognito = Cognito(
        user_pool_id='${aws_cognito_user_pool.this.id}',
        client_id='${aws_cognito_user_pool_client.this[var.user_pool_clients[0].name].id}',
        user_pool_region='${provider::aws::region}'
    )
    cognito.authenticate(password='user_password')
    id_token = cognito.id_token

    # Step 2: Get credentials from Identity Pool
    cognito_identity = boto3.client('cognito-identity')

    # Get identity ID
    identity_response = cognito_identity.get_id(
        IdentityPoolId='${aws_cognito_identity_pool.this[0].id}',
        Logins={
            '${aws_cognito_user_pool.this.endpoint}': id_token
        }
    )

    # Get credentials
    credentials_response = cognito_identity.get_credentials_for_identity(
        IdentityId=identity_response['IdentityId'],
        Logins={
            '${aws_cognito_user_pool.this.endpoint}': id_token
        }
    )

    # Use AWS credentials
    credentials = credentials_response['Credentials']
    access_key = credentials['AccessKeyId']
    secret_key = credentials['SecretKey']
    session_token = credentials['SessionToken']
  EOT
  : "No identity pool or clients configured"
}
