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
# Basic Bedrock Knowledge Base Test
# Tests minimal knowledge base configuration with OpenSearch Serverless
# Creates a knowledge base with S3 data source
# -----------------------------------------------------------------------------

provider "aws" {
  region = "us-east-1"

  # Mock configuration for testing - no real AWS credentials needed for plan
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    bedrock      = "http://localhost:4566"
    bedrockagent = "http://localhost:4566"
    iam          = "http://localhost:4566"
    sts          = "http://localhost:4566"
    aoss         = "http://localhost:4566"
    s3           = "http://localhost:4566"
  }
}

# Mock S3 bucket for documents
resource "aws_s3_bucket" "documents" {
  bucket = "basic-kb-documents-bucket"
}

# Mock OpenSearch Serverless collection
resource "aws_opensearchserverless_collection" "kb" {
  name = "basic-kb-collection"
  type = "VECTORSEARCH"
}

# Create basic knowledge base
module "bedrock_knowledge_base" {
  source = "../.."

  # Knowledge base configuration
  name        = "basic-product-docs-kb"
  description = "Basic knowledge base for product documentation"

  # Embedding model - Amazon Titan
  embedding_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v1"

  # OpenSearch Serverless storage
  opensearch_serverless_configuration = {
    collection_arn    = aws_opensearchserverless_collection.kb.arn
    vector_index_name = "bedrock-knowledge-base-default-index"
    metadata_field    = "AMAZON_BEDROCK_METADATA"
    text_field        = "AMAZON_BEDROCK_TEXT_CHUNK"
    vector_field      = "bedrock-knowledge-base-default-vector"
  }

  # S3 data source
  s3_data_source_bucket_arn = aws_s3_bucket.documents.arn

  # Use default chunking configuration
  # - chunking_strategy: FIXED_SIZE
  # - fixed_size_max_tokens: 300
  # - fixed_size_overlap_percentage: 20

  tags = {
    Environment = "test"
    Purpose     = "basic-kb-test"
  }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "knowledge_base_id" {
  description = "ID of the knowledge base"
  value       = module.bedrock_knowledge_base.knowledge_base_id
}

output "knowledge_base_arn" {
  description = "ARN of the knowledge base"
  value       = module.bedrock_knowledge_base.knowledge_base_arn
}

output "data_source_id" {
  description = "ID of the data source"
  value       = module.bedrock_knowledge_base.data_source_id
}

output "kb_role_arn" {
  description = "ARN of the knowledge base IAM role"
  value       = module.bedrock_knowledge_base.kb_role_arn
}

output "start_ingestion_cli" {
  description = "CLI command to start ingestion"
  value       = module.bedrock_knowledge_base.start_ingestion_job_cli_example
}

output "retrieve_query_cli" {
  description = "CLI command to query the knowledge base"
  value       = module.bedrock_knowledge_base.retrieve_query_cli_example
}
