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
# Advanced Bedrock Knowledge Base Test
# Tests comprehensive knowledge base configuration with:
# - OpenSearch Serverless with custom field mappings
# - S3 data source with inclusion prefixes
# - Custom chunking configuration
# - Multiple tags and metadata
# -----------------------------------------------------------------------------

provider "aws" {
  region = "us-west-2"

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
    kms          = "http://localhost:4566"
  }
}

# -----------------------------------------------------------------------------
# S3 Bucket for Documents
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "documents" {
  bucket = "advanced-kb-enterprise-docs"
}

# Upload sample documents (mocked for testing)
resource "aws_s3_bucket_versioning" "documents" {
  bucket = aws_s3_bucket.documents.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "documents" {
  bucket = aws_s3_bucket.documents.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# -----------------------------------------------------------------------------
# OpenSearch Serverless Collection
# -----------------------------------------------------------------------------

# Encryption policy for the collection
resource "aws_opensearchserverless_security_policy" "encryption" {
  name = "advanced-kb-encryption-policy"
  type = "encryption"

  policy = jsonencode({
    Rules = [
      {
        Resource = [
          "collection/advanced-kb-*"
        ]
        ResourceType = "collection"
      }
    ]
    AWSOwnedKey = true
  })
}

# Network policy for the collection
resource "aws_opensearchserverless_security_policy" "network" {
  name = "advanced-kb-network-policy"
  type = "network"

  policy = jsonencode([
    {
      Rules = [
        {
          Resource = [
            "collection/advanced-kb-*"
          ]
          ResourceType = "collection"
        }
      ]
      AllowFromPublic = true
    }
  ])
}

# Data access policy
resource "aws_opensearchserverless_access_policy" "data" {
  name = "advanced-kb-data-policy"
  type = "data"

  policy = jsonencode([
    {
      Rules = [
        {
          Resource = [
            "collection/advanced-kb-*"
          ]
          Permission = [
            "aoss:CreateCollectionItems",
            "aoss:UpdateCollectionItems",
            "aoss:DescribeCollectionItems"
          ]
          ResourceType = "collection"
        },
        {
          Resource = [
            "index/advanced-kb-*/*"
          ]
          Permission = [
            "aoss:CreateIndex",
            "aoss:UpdateIndex",
            "aoss:DescribeIndex",
            "aoss:ReadDocument",
            "aoss:WriteDocument"
          ]
          ResourceType = "index"
        }
      ]
      Principal = [
        "*"
      ]
    }
  ])
}

# OpenSearch Serverless collection
resource "aws_opensearchserverless_collection" "kb" {
  name = "advanced-kb-collection"
  type = "VECTORSEARCH"

  depends_on = [
    aws_opensearchserverless_security_policy.encryption,
    aws_opensearchserverless_security_policy.network
  ]
}

# -----------------------------------------------------------------------------
# Bedrock Knowledge Base with Advanced Configuration
# -----------------------------------------------------------------------------

module "bedrock_knowledge_base" {
  source = "../.."

  # Knowledge base configuration
  name         = "advanced-enterprise-kb"
  description  = "Advanced enterprise knowledge base with comprehensive documentation and policies"
  kb_role_name = "advanced-enterprise-kb-role"

  # Embedding model - Cohere Multilingual for better global support
  embedding_model_arn = "arn:aws:bedrock:us-west-2::foundation-model/cohere.embed-multilingual-v3"

  # OpenSearch Serverless storage with custom field mappings
  opensearch_serverless_configuration = {
    collection_arn    = aws_opensearchserverless_collection.kb.arn
    vector_index_name = "enterprise-vector-index"
    metadata_field    = "metadata"
    text_field        = "text_content"
    vector_field      = "embedding_vector"
  }

  # S3 data source with inclusion prefixes
  s3_data_source_bucket_arn = aws_s3_bucket.documents.arn
  data_source_name          = "enterprise-docs-source"
  data_source_description   = "Enterprise documentation including product manuals, policies, and guides"

  # Only include specific document types
  s3_inclusion_prefixes = [
    "docs/product-manuals/",
    "docs/policies/",
    "docs/guides/"
  ]

  # Custom chunking configuration for larger context
  chunking_strategy             = "FIXED_SIZE"
  fixed_size_max_tokens         = 512
  fixed_size_overlap_percentage = 25

  # Data deletion policy
  data_deletion_policy = "DELETE"

  tags = {
    Environment = "production"
    Purpose     = "advanced-kb-test"
    Team        = "knowledge-management"
    CostCenter  = "engineering"
    Compliance  = "required"
    DataClass   = "internal"
  }

  depends_on = [
    aws_opensearchserverless_collection.kb,
    aws_opensearchserverless_access_policy.data
  ]
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

output "storage_type" {
  description = "Vector database storage type"
  value       = module.bedrock_knowledge_base.storage_type
}

output "chunking_strategy" {
  description = "Document chunking strategy"
  value       = module.bedrock_knowledge_base.chunking_strategy
}

output "opensearch_collection_endpoint" {
  description = "OpenSearch Serverless collection endpoint"
  value       = aws_opensearchserverless_collection.kb.collection_endpoint
}

output "opensearch_dashboard_endpoint" {
  description = "OpenSearch Serverless dashboard endpoint"
  value       = aws_opensearchserverless_collection.kb.dashboard_endpoint
}

output "start_ingestion_cli" {
  description = "CLI command to start ingestion"
  value       = module.bedrock_knowledge_base.start_ingestion_job_cli_example
}

output "boto3_ingestion_example" {
  description = "Python boto3 code to start ingestion"
  value       = module.bedrock_knowledge_base.boto3_ingestion_example
}

output "retrieve_query_cli" {
  description = "CLI command to query the knowledge base"
  value       = module.bedrock_knowledge_base.retrieve_query_cli_example
}

output "boto3_retrieve_example" {
  description = "Python boto3 code to query the knowledge base"
  value       = module.bedrock_knowledge_base.boto3_retrieve_example
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for documents"
  value       = aws_s3_bucket.documents.id
}

output "embedding_models" {
  description = "Available embedding model ARNs"
  value = {
    titan_v1            = module.bedrock_knowledge_base.titan_embed_text_v1_arn
    titan_v2            = module.bedrock_knowledge_base.titan_embed_text_v2_arn
    cohere_english      = module.bedrock_knowledge_base.cohere_embed_english_v3_arn
    cohere_multilingual = module.bedrock_knowledge_base.cohere_embed_multilingual_v3_arn
  }
}
