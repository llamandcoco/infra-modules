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
      Module    = "bedrock-knowledge-base"
    }
  )

  # Determine storage configuration type
  storage_type = var.opensearch_serverless_configuration != null ? "OPENSEARCH_SERVERLESS" : (
    var.rds_configuration != null ? "RDS" : (
      var.pinecone_configuration != null ? "PINECONE" : "OPENSEARCH_SERVERLESS"
    )
  )
}

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# -----------------------------------------------------------------------------
# IAM Role for Knowledge Base
# Allows Bedrock to access the data source and vector database
# -----------------------------------------------------------------------------
resource "aws_iam_role" "knowledge_base" {
  name        = var.kb_role_name != null ? var.kb_role_name : "${var.name}-kb-role"
  description = "IAM role for Bedrock Knowledge Base ${var.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:knowledge-base/*"
          }
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = var.kb_role_name != null ? var.kb_role_name : "${var.name}-kb-role"
    }
  )
}

# -----------------------------------------------------------------------------
# IAM Policy for Foundation Model Access (for embeddings)
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy" "bedrock_model" {
  name = "bedrock-model-policy"
  role = aws_iam_role.knowledge_base.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = var.embedding_model_arn
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# IAM Policy for S3 Data Source Access
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy" "s3_data_source" {
  count = var.s3_data_source_bucket_arn != null ? 1 : 0

  name = "s3-data-source-policy"
  role = aws_iam_role.knowledge_base.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.s3_data_source_bucket_arn,
          "${var.s3_data_source_bucket_arn}/*"
        ]
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# IAM Policy for OpenSearch Serverless Access
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy" "opensearch" {
  count = var.opensearch_serverless_configuration != null ? 1 : 0

  name = "opensearch-policy"
  role = aws_iam_role.knowledge_base.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "aoss:APIAccessAll"
        ]
        Resource = var.opensearch_serverless_configuration.collection_arn
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# Bedrock Knowledge Base
# -----------------------------------------------------------------------------
resource "aws_bedrockagent_knowledge_base" "this" {
  name        = var.name
  description = var.description
  role_arn    = aws_iam_role.knowledge_base.arn

  knowledge_base_configuration {
    type = "VECTOR"

    vector_knowledge_base_configuration {
      embedding_model_arn = var.embedding_model_arn
    }
  }

  storage_configuration {
    type = local.storage_type

    # OpenSearch Serverless configuration
    dynamic "opensearch_serverless_configuration" {
      for_each = var.opensearch_serverless_configuration != null ? [var.opensearch_serverless_configuration] : []

      content {
        collection_arn    = opensearch_serverless_configuration.value.collection_arn
        vector_index_name = opensearch_serverless_configuration.value.vector_index_name

        field_mapping {
          metadata_field = opensearch_serverless_configuration.value.metadata_field
          text_field     = opensearch_serverless_configuration.value.text_field
          vector_field   = opensearch_serverless_configuration.value.vector_field
        }
      }
    }

    # RDS configuration
    dynamic "rds_configuration" {
      for_each = var.rds_configuration != null ? [var.rds_configuration] : []

      content {
        credentials_secret_arn = rds_configuration.value.credentials_secret_arn
        database_name          = rds_configuration.value.database_name
        resource_arn           = rds_configuration.value.resource_arn
        table_name             = rds_configuration.value.table_name

        field_mapping {
          metadata_field    = rds_configuration.value.metadata_field
          primary_key_field = rds_configuration.value.primary_key_field
          text_field        = rds_configuration.value.text_field
          vector_field      = rds_configuration.value.vector_field
        }
      }
    }

    # Pinecone configuration
    dynamic "pinecone_configuration" {
      for_each = var.pinecone_configuration != null ? [var.pinecone_configuration] : []

      content {
        connection_string      = pinecone_configuration.value.connection_string
        credentials_secret_arn = pinecone_configuration.value.credentials_secret_arn
        namespace              = pinecone_configuration.value.namespace

        field_mapping {
          metadata_field = pinecone_configuration.value.metadata_field
          text_field     = pinecone_configuration.value.text_field
        }
      }
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = var.name
    }
  )

  depends_on = [
    aws_iam_role_policy.bedrock_model,
    aws_iam_role_policy.s3_data_source,
    aws_iam_role_policy.opensearch
  ]
}

# -----------------------------------------------------------------------------
# Data Source (S3)
# Creates a data source pointing to S3 bucket with documents
# -----------------------------------------------------------------------------
resource "aws_bedrockagent_data_source" "this" {
  count = var.s3_data_source_bucket_arn != null ? 1 : 0

  knowledge_base_id = aws_bedrockagent_knowledge_base.this.id
  name              = var.data_source_name != null ? var.data_source_name : "${var.name}-s3-data-source"
  description       = var.data_source_description

  data_source_configuration {
    type = "S3"

    s3_configuration {
      bucket_arn = var.s3_data_source_bucket_arn

      dynamic "bucket_owner_account_id" {
        for_each = var.s3_bucket_owner_account_id != null ? [var.s3_bucket_owner_account_id] : []
        content {
          bucket_owner_account_id = bucket_owner_account_id.value
        }
      }

      dynamic "inclusion_prefixes" {
        for_each = length(var.s3_inclusion_prefixes) > 0 ? [1] : []
        content {
          inclusion_prefixes = var.s3_inclusion_prefixes
        }
      }
    }
  }

  # Vector ingestion configuration
  dynamic "vector_ingestion_configuration" {
    for_each = var.chunking_strategy != null ? [1] : []

    content {
      chunking_configuration {
        chunking_strategy = var.chunking_strategy

        # Fixed size chunking
        dynamic "fixed_size_chunking_configuration" {
          for_each = var.chunking_strategy == "FIXED_SIZE" ? [1] : []

          content {
            max_tokens         = var.fixed_size_max_tokens
            overlap_percentage = var.fixed_size_overlap_percentage
          }
        }
      }
    }
  }

  data_deletion_policy = var.data_deletion_policy
}
