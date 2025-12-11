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
# TypeScript (Node.js) Lambda Test
# Tests Node.js 20.x runtime with compiled TypeScript
# Demonstrates handler naming for compiled code in dist/ directory
# -----------------------------------------------------------------------------

provider "aws" {
  region = "us-east-1"

  # Mock configuration for testing - no real AWS credentials needed for plan
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    lambda         = "http://localhost:4566"
    iam            = "http://localhost:4566"
    cloudwatchlogs = "http://localhost:4566"
    s3             = "http://localhost:4566"
  }
}

# Create Lambda function using Node.js 20.x runtime
# This demonstrates TypeScript Lambda deployment
module "lambda_typescript" {
  source = "../.."

  # Required variables
  function_name = "typescript-api-lambda"
  runtime       = "nodejs20.x"
  # Handler points to compiled JS in dist/ directory
  handler       = "dist/index.handler"

  # S3 deployment method
  # In production, TypeScript would be compiled and uploaded to S3
  s3_bucket         = "my-lambda-deployments"
  s3_key            = "functions/typescript-api/v2.0.0/lambda.zip"
  s3_object_version = "xyz789"

  # Function configuration
  description  = "TypeScript Lambda function for API processing"
  timeout      = 30
  memory_size  = 512

  # Environment variables
  environment_variables = {
    NODE_ENV        = "production"
    LOG_LEVEL       = "debug"
    API_VERSION     = "v2"
    CORS_ORIGIN     = "*"
    MAX_RETRY       = "3"
  }

  # CloudWatch Logs configuration
  log_retention_days = 30

  # Additional IAM permissions
  # Example: Grant access to SQS and SNS
  additional_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
  ]

  # Concurrency control
  reserved_concurrent_executions = 10

  tags = {
    Environment = "production"
    Application = "typescript-api"
    Runtime     = "nodejs20.x"
    Language    = "TypeScript"
  }
}

# -----------------------------------------------------------------------------
# Example TypeScript Code Structure
# -----------------------------------------------------------------------------

# Project structure:
# ├── src/
# │   ├── index.ts          # Main handler
# │   ├── services/
# │   │   └── processor.ts  # Business logic
# │   └── types/
# │       └── events.ts     # Type definitions
# ├── dist/                 # Compiled JavaScript (created by build)
# │   └── index.js
# ├── package.json
# ├── tsconfig.json
# └── lambda.zip            # Contains dist/ and node_modules/

# src/index.ts:
#
# import { APIGatewayProxyEvent, APIGatewayProxyResult, Context } from 'aws-lambda';
# import { ProcessingService } from './services/processor';
#
# const processor = new ProcessingService();
#
# export const handler = async (
#   event: APIGatewayProxyEvent,
#   context: Context
# ): Promise<APIGatewayProxyResult> => {
#   console.log('Event:', JSON.stringify(event));
#   console.log('Context:', JSON.stringify(context));
#
#   try {
#     const result = await processor.process(event.body);
#
#     return {
#       statusCode: 200,
#       headers: {
#         'Content-Type': 'application/json',
#         'Access-Control-Allow-Origin': process.env.CORS_ORIGIN || '*',
#       },
#       body: JSON.stringify(result),
#     };
#   } catch (error) {
#     console.error('Error:', error);
#
#     return {
#       statusCode: 500,
#       headers: {
#         'Content-Type': 'application/json',
#       },
#       body: JSON.stringify({
#         error: 'Internal server error',
#       }),
#     };
#   }
# };

# package.json:
# {
#   "name": "typescript-lambda",
#   "version": "2.0.0",
#   "scripts": {
#     "build": "tsc",
#     "package": "npm run build && cd dist && zip -r ../lambda.zip . && cd .. && zip -r lambda.zip node_modules"
#   },
#   "dependencies": {
#     "@aws-sdk/client-sqs": "^3.0.0",
#     "@aws-sdk/client-sns": "^3.0.0"
#   },
#   "devDependencies": {
#     "@types/aws-lambda": "^8.10.0",
#     "@types/node": "^20.0.0",
#     "typescript": "^5.0.0"
#   }
# }

# tsconfig.json:
# {
#   "compilerOptions": {
#     "target": "ES2020",
#     "module": "commonjs",
#     "outDir": "./dist",
#     "rootDir": "./src",
#     "strict": true,
#     "esModuleInterop": true,
#     "skipLibCheck": true,
#     "forceConsistentCasingInFileNames": true
#   },
#   "include": ["src/**/*"],
#   "exclude": ["node_modules", "dist"]
# }

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda_typescript.function_arn
}

output "invoke_arn" {
  description = "Invoke ARN for API Gateway integration"
  value       = module.lambda_typescript.invoke_arn
}

output "function_qualified_arn" {
  description = "Qualified ARN with version"
  value       = module.lambda_typescript.function_qualified_arn
}
