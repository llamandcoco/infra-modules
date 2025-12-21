# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the Bedrock knowledge base. This will be displayed in the AWS console and used in resource naming."
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 100
    error_message = "Knowledge base name must be between 1 and 100 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.name))
    error_message = "Knowledge base name must contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "embedding_model_arn" {
  description = "ARN of the foundation model to use for generating embeddings. Common models: 'arn:aws:bedrock:<region>::foundation-model/amazon.titan-embed-text-v1', 'arn:aws:bedrock:<region>::foundation-model/cohere.embed-english-v3', 'arn:aws:bedrock:<region>::foundation-model/cohere.embed-multilingual-v3'."
  type        = string

  validation {
    condition     = length(var.embedding_model_arn) > 0
    error_message = "Embedding model ARN must not be empty."
  }
}

# -----------------------------------------------------------------------------
# Knowledge Base Configuration
# -----------------------------------------------------------------------------

variable "description" {
  description = "Description of the knowledge base. Helps document the purpose and contents."
  type        = string
  default     = null
}

variable "kb_role_name" {
  description = "Name of the IAM role for the knowledge base. If not specified, defaults to '<name>-kb-role'."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Storage Configuration Variables
# Only one of these should be specified
# -----------------------------------------------------------------------------

variable "opensearch_serverless_configuration" {
  description = "Configuration for OpenSearch Serverless as the vector database. This is the recommended option for most use cases."
  type = object({
    collection_arn    = string
    vector_index_name = string
    metadata_field    = string
    text_field        = string
    vector_field      = string
  })
  default = null
}

variable "rds_configuration" {
  description = "Configuration for RDS (Aurora PostgreSQL with pgvector) as the vector database."
  type = object({
    credentials_secret_arn = string
    database_name          = string
    resource_arn           = string
    table_name             = string
    metadata_field         = string
    primary_key_field      = string
    text_field             = string
    vector_field           = string
  })
  default = null
}

variable "pinecone_configuration" {
  description = "Configuration for Pinecone as the vector database."
  type = object({
    connection_string      = string
    credentials_secret_arn = string
    namespace              = string
    metadata_field         = string
    text_field             = string
  })
  default = null
}

# -----------------------------------------------------------------------------
# Data Source Configuration (S3)
# -----------------------------------------------------------------------------

variable "s3_data_source_bucket_arn" {
  description = "ARN of the S3 bucket containing documents for the knowledge base. If specified, a data source will be created."
  type        = string
  default     = null
}

variable "data_source_name" {
  description = "Name of the data source. If not specified, defaults to '<name>-s3-data-source'."
  type        = string
  default     = null
}

variable "data_source_description" {
  description = "Description of the data source."
  type        = string
  default     = null
}

variable "s3_bucket_owner_account_id" {
  description = "AWS account ID of the S3 bucket owner. Required if the bucket is in a different account."
  type        = string
  default     = null
}

variable "s3_inclusion_prefixes" {
  description = "List of S3 prefixes to include when ingesting documents. Use this to limit which files are indexed."
  type        = list(string)
  default     = []
}

variable "data_deletion_policy" {
  description = "Policy for deleting data from the knowledge base when the data source is deleted. Valid values: 'RETAIN', 'DELETE'."
  type        = string
  default     = "RETAIN"

  validation {
    condition     = contains(["RETAIN", "DELETE"], var.data_deletion_policy)
    error_message = "Data deletion policy must be either 'RETAIN' or 'DELETE'."
  }
}

# -----------------------------------------------------------------------------
# Chunking Configuration
# -----------------------------------------------------------------------------

variable "chunking_strategy" {
  description = "Strategy for chunking documents. Valid values: 'FIXED_SIZE', 'NONE'. FIXED_SIZE splits documents into chunks, NONE keeps documents whole."
  type        = string
  default     = "FIXED_SIZE"

  validation {
    condition     = contains(["FIXED_SIZE", "NONE"], var.chunking_strategy)
    error_message = "Chunking strategy must be either 'FIXED_SIZE' or 'NONE'."
  }
}

variable "fixed_size_max_tokens" {
  description = "Maximum number of tokens per chunk when using FIXED_SIZE chunking strategy. Valid range: 20-8192."
  type        = number
  default     = 300

  validation {
    condition     = var.fixed_size_max_tokens >= 20 && var.fixed_size_max_tokens <= 8192
    error_message = "Max tokens must be between 20 and 8192."
  }
}

variable "fixed_size_overlap_percentage" {
  description = "Percentage of overlap between consecutive chunks. Valid range: 1-99. Higher values preserve more context but increase storage."
  type        = number
  default     = 20

  validation {
    condition     = var.fixed_size_overlap_percentage >= 1 && var.fixed_size_overlap_percentage <= 99
    error_message = "Overlap percentage must be between 1 and 99."
  }
}

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to all resources. Use this for cost allocation, resource organization, and governance."
  type        = map(string)
  default     = {}
}
