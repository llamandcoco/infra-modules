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
# Go Lambda Test
# Tests Go runtime with provided.al2023
# Demonstrates Go-specific handler naming (bootstrap)
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

# Create Lambda function using Go runtime
# Go Lambda functions must be compiled to a binary named "bootstrap"
module "lambda_go" {
  source = "../.."

  # Required variables
  function_name = "go-processor-lambda"
  runtime       = "provided.al2023"
  # Go Lambda handler is always "bootstrap" (the binary name)
  handler = "bootstrap"

  # S3 deployment method
  # In production, Go binary would be compiled and uploaded to S3
  s3_bucket         = "my-lambda-deployments"
  s3_key            = "functions/go-processor/v1.5.0/lambda.zip"
  s3_object_version = "def456"

  # Function configuration
  description = "High-performance Go Lambda for data processing"
  timeout     = 120
  memory_size = 1024

  # Environment variables
  environment_variables = {
    ENVIRONMENT      = "production"
    LOG_LEVEL        = "info"
    WORKER_COUNT     = "10"
    BATCH_SIZE       = "100"
    ENABLE_PROFILING = "false"
  }

  # CloudWatch Logs configuration
  log_retention_days = 90

  # Additional IAM permissions
  # Example: Grant access to Kinesis and DynamoDB for stream processing
  additional_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonKinesisReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  ]

  # Concurrency control for high-throughput processing
  reserved_concurrent_executions = 100

  tags = {
    Environment  = "production"
    Application  = "data-processor"
    Runtime      = "go"
    Architecture = "provided.al2023"
    Performance  = "high"
  }
}

# -----------------------------------------------------------------------------
# Example Go Code
# -----------------------------------------------------------------------------

# Project structure:
# ├── main.go
# ├── go.mod
# ├── go.sum
# ├── internal/
# │   ├── handler/
# │   │   └── handler.go
# │   └── processor/
# │       └── processor.go
# └── lambda.zip (contains bootstrap binary)

# main.go:
#
# package main
#
# import (
#     "context"
#     "encoding/json"
#     "log"
#     "os"
#
#     "github.com/aws/aws-lambda-go/events"
#     "github.com/aws/aws-lambda-go/lambda"
#     "github.com/aws/aws-sdk-go-v2/config"
#     "github.com/aws/aws-sdk-go-v2/service/dynamodb"
#     "github.com/aws/aws-sdk-go-v2/service/kinesis"
# )
#
# type Response struct {
#     StatusCode int               `json:"statusCode"`
#     Headers    map[string]string `json:"headers"`
#     Body       string             `json:"body"`
# }
#
# type LambdaHandler struct {
#     dynamoClient  *dynamodb.Client
#     kinesisClient *kinesis.Client
#     workerCount   int
# }
#
# func NewLambdaHandler(ctx context.Context) (*LambdaHandler, error) {
#     cfg, err := config.LoadDefaultConfig(ctx)
#     if err != nil {
#         return nil, err
#     }
#
#     return &LambdaHandler{
#         dynamoClient:  dynamodb.NewFromConfig(cfg),
#         kinesisClient: kinesis.NewFromConfig(cfg),
#         workerCount:   10,
#     }, nil
# }
#
# func (h *LambdaHandler) HandleRequest(ctx context.Context, event events.APIGatewayProxyRequest) (Response, error) {
#     log.Printf("Processing request: %s", event.RequestContext.RequestID)
#
#     // Your business logic here
#     // Process data from Kinesis, write to DynamoDB, etc.
#
#     responseBody := map[string]string{
#         "message": "Processing complete",
#         "requestId": event.RequestContext.RequestID,
#     }
#
#     body, err := json.Marshal(responseBody)
#     if err != nil {
#         return Response{}, err
#     }
#
#     return Response{
#         StatusCode: 200,
#         Headers: map[string]string{
#             "Content-Type": "application/json",
#         },
#         Body: string(body),
#     }, nil
# }
#
# func main() {
#     ctx := context.Background()
#     handler, err := NewLambdaHandler(ctx)
#     if err != nil {
#         log.Fatalf("Failed to initialize handler: %v", err)
#     }
#
#     lambda.Start(handler.HandleRequest)
# }

# go.mod:
# module github.com/example/go-lambda
#
# go 1.21
#
# require (
#     github.com/aws/aws-lambda-go v1.41.0
#     github.com/aws/aws-sdk-go-v2 v1.24.0
#     github.com/aws/aws-sdk-go-v2/config v1.26.0
#     github.com/aws/aws-sdk-go-v2/service/dynamodb v1.26.0
#     github.com/aws/aws-sdk-go-v2/service/kinesis v1.24.0
# )

# Build and package commands:
# GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o bootstrap main.go
# zip lambda.zip bootstrap

# For ARM architecture (Graviton2):
# GOOS=linux GOARCH=arm64 go build -o bootstrap main.go
# zip lambda.zip bootstrap

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda_go.function_arn
}

output "invoke_arn" {
  description = "Invoke ARN for event source mapping"
  value       = module.lambda_go.invoke_arn
}

output "role_arn" {
  description = "ARN of the execution role with Kinesis and DynamoDB permissions"
  value       = module.lambda_go.role_arn
}

output "memory_size" {
  description = "Configured memory size"
  value       = module.lambda_go.memory_size
}
