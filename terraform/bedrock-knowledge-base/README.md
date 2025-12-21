# AWS Bedrock Knowledge Base

A production-ready Terraform module for creating Amazon Bedrock Knowledge Bases with vector database integration for Retrieval-Augmented Generation (RAG).

## Features

- **Vector Knowledge Bases** - Enable RAG with foundation models
- **Multiple Storage Backends** - OpenSearch Serverless, RDS (Aurora PostgreSQL), or Pinecone
- **S3 Data Sources** - Automatic document ingestion from S3
- **Chunking Strategies** - Fixed-size or no chunking
- **Embedding Models** - Amazon Titan, Cohere, and more
- **IAM Management** - Automatic role and policy creation

## Quick Start

```hcl
# Create S3 bucket for documents
resource "aws_s3_bucket" "docs" {
  bucket = "my-knowledge-base-docs"
}

# Create OpenSearch Serverless collection
resource "aws_opensearchserverless_collection" "kb" {
  name = "my-kb-collection"
  type = "VECTORSEARCH"
}

# Create knowledge base
module "knowledge_base" {
  source = "github.com/llamandcoco/infra-modules//terraform/bedrock-knowledge-base?ref=<commit-sha>"

  name                = "product-documentation-kb"
  embedding_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v1"

  opensearch_serverless_configuration = {
    collection_arn    = aws_opensearchserverless_collection.kb.arn
    vector_index_name = "bedrock-knowledge-base-default-index"
    metadata_field    = "AMAZON_BEDROCK_METADATA"
    text_field        = "AMAZON_BEDROCK_TEXT_CHUNK"
    vector_field      = "bedrock-knowledge-base-default-vector"
  }

  s3_data_source_bucket_arn = aws_s3_bucket.docs.arn
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory |
|---------|----------|
| Basic - Simple knowledge base with S3 | [`tests/basic/main.tf`](tests/basic/main.tf) |
| Advanced - Full production setup with OpenSearch | [`tests/advanced/main.tf`](tests/advanced/main.tf) |

**Usage:**
```bash
# View example
cat tests/basic/main.tf

# Copy and adapt
cp -r tests/basic/ my-project/
```

## Use Cases

### 1. Basic RAG with S3 Documents

Simple knowledge base for document Q&A:

```hcl
module "kb" {
  source = "github.com/llamandcoco/infra-modules//terraform/bedrock-knowledge-base?ref=<commit-sha>"

  name                = "faq-kb"
  embedding_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v1"

  opensearch_serverless_configuration = {
    collection_arn    = aws_opensearchserverless_collection.kb.arn
    vector_index_name = "bedrock-knowledge-base-default-index"
    metadata_field    = "AMAZON_BEDROCK_METADATA"
    text_field        = "AMAZON_BEDROCK_TEXT_CHUNK"
    vector_field      = "bedrock-knowledge-base-default-vector"
  }

  s3_data_source_bucket_arn = aws_s3_bucket.faq_docs.arn
}
```

### 2. Knowledge Base with Custom Chunking

Optimize chunk size and overlap for your use case:

```hcl
module "kb" {
  source = "github.com/llamandcoco/infra-modules//terraform/bedrock-knowledge-base?ref=<commit-sha>"

  name                = "technical-docs-kb"
  embedding_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/cohere.embed-english-v3"

  opensearch_serverless_configuration = {
    collection_arn    = aws_opensearchserverless_collection.kb.arn
    vector_index_name = "bedrock-knowledge-base-default-index"
    metadata_field    = "AMAZON_BEDROCK_METADATA"
    text_field        = "AMAZON_BEDROCK_TEXT_CHUNK"
    vector_field      = "bedrock-knowledge-base-default-vector"
  }

  s3_data_source_bucket_arn = aws_s3_bucket.docs.arn

  # Custom chunking for technical content
  chunking_strategy             = "FIXED_SIZE"
  fixed_size_max_tokens         = 512    # Larger chunks
  fixed_size_overlap_percentage = 25     # More overlap
}
```

### 3. Knowledge Base with Filtered Data Source

Index only specific document types or directories:

```hcl
module "kb" {
  source = "github.com/llamandcoco/infra-modules//terraform/bedrock-knowledge-base?ref=<commit-sha>"

  name                = "filtered-kb"
  embedding_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v1"

  opensearch_serverless_configuration = {
    collection_arn    = aws_opensearchserverless_collection.kb.arn
    vector_index_name = "bedrock-knowledge-base-default-index"
    metadata_field    = "AMAZON_BEDROCK_METADATA"
    text_field        = "AMAZON_BEDROCK_TEXT_CHUNK"
    vector_field      = "bedrock-knowledge-base-default-vector"
  }

  s3_data_source_bucket_arn = aws_s3_bucket.docs.arn

  # Only index specific folders
  s3_inclusion_prefixes = [
    "public-docs/",
    "product-manuals/",
    "faq/"
  ]
}
```

### 4. Using with Bedrock Agent

Integrate knowledge base with an agent for RAG:

```hcl
# Create knowledge base
module "kb" {
  source = "github.com/llamandcoco/infra-modules//terraform/bedrock-knowledge-base?ref=<commit-sha>"

  name                = "agent-kb"
  embedding_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v1"

  opensearch_serverless_configuration = {
    collection_arn    = aws_opensearchserverless_collection.kb.arn
    vector_index_name = "bedrock-knowledge-base-default-index"
    metadata_field    = "AMAZON_BEDROCK_METADATA"
    text_field        = "AMAZON_BEDROCK_TEXT_CHUNK"
    vector_field      = "bedrock-knowledge-base-default-vector"
  }

  s3_data_source_bucket_arn = aws_s3_bucket.docs.arn
}

# Create agent with knowledge base
module "agent" {
  source = "github.com/llamandcoco/infra-modules//terraform/bedrock-agent?ref=<commit-sha>"

  agent_name       = "support-agent"
  foundation_model = "anthropic.claude-3-5-sonnet-20241022-v2:0"
  instruction      = "You are a support agent. Use the knowledge base to answer questions."

  # Associate knowledge base
  knowledge_base_ids = [
    module.kb.knowledge_base_id
  ]
}
```

## Vector Database Options

### OpenSearch Serverless (Recommended)

Fully managed, serverless vector database:

```hcl
opensearch_serverless_configuration = {
  collection_arn    = aws_opensearchserverless_collection.kb.arn
  vector_index_name = "bedrock-knowledge-base-default-index"
  metadata_field    = "AMAZON_BEDROCK_METADATA"
  text_field        = "AMAZON_BEDROCK_TEXT_CHUNK"
  vector_field      = "bedrock-knowledge-base-default-vector"
}
```

### Aurora PostgreSQL with pgvector

Use RDS for more control:

```hcl
rds_configuration = {
  credentials_secret_arn = aws_secretsmanager_secret.db_creds.arn
  database_name          = "knowledge_base"
  resource_arn           = aws_rds_cluster.kb.arn
  table_name             = "bedrock_kb"
  metadata_field         = "metadata"
  primary_key_field      = "id"
  text_field             = "text"
  vector_field           = "embedding"
}
```

### Pinecone

Use external vector database:

```hcl
pinecone_configuration = {
  connection_string      = "https://your-index.pinecone.io"
  credentials_secret_arn = aws_secretsmanager_secret.pinecone.arn
  namespace              = "bedrock-kb"
  metadata_field         = "metadata"
  text_field             = "text"
}
```

## Embedding Models

Choose the right embedding model for your use case:

| Model | ARN | Use Case | Dimensions |
|-------|-----|----------|------------|
| Amazon Titan Text v1 | `amazon.titan-embed-text-v1` | General purpose, cost-effective | 1,536 |
| Amazon Titan Text v2 | `amazon.titan-embed-text-v2:0` | Improved accuracy | 1,024 |
| Cohere English v3 | `cohere.embed-english-v3` | English text only | 1,024 |
| Cohere Multilingual v3 | `cohere.embed-multilingual-v3` | 100+ languages | 1,024 |

```hcl
# Use module outputs for embedding model ARNs
embedding_model_arn = module.knowledge_base.titan_embed_text_v1_arn
```

## Document Ingestion

After creating the knowledge base, ingest documents:

### Using AWS CLI

```bash
# Start ingestion job
aws bedrock-agent start-ingestion-job \
  --knowledge-base-id <kb-id> \
  --data-source-id <data-source-id>

# Check ingestion job status
aws bedrock-agent get-ingestion-job \
  --knowledge-base-id <kb-id> \
  --data-source-id <data-source-id> \
  --ingestion-job-id <job-id>
```

### Using Python (boto3)

```python
import boto3

bedrock_agent = boto3.client('bedrock-agent')

# Start ingestion
response = bedrock_agent.start_ingestion_job(
    knowledgeBaseId='YOUR-KB-ID',
    dataSourceId='YOUR-DATA-SOURCE-ID'
)

job_id = response['ingestionJob']['ingestionJobId']
print(f"Ingestion job started: {job_id}")

# Monitor status
job = bedrock_agent.get_ingestion_job(
    knowledgeBaseId='YOUR-KB-ID',
    dataSourceId='YOUR-DATA-SOURCE-ID',
    ingestionJobId=job_id
)

print(f"Status: {job['ingestionJob']['status']}")
```

## Querying the Knowledge Base

### Retrieve API (Direct Query)

Query the knowledge base directly without an agent:

```python
import boto3

bedrock_runtime = boto3.client('bedrock-agent-runtime')

response = bedrock_runtime.retrieve(
    knowledgeBaseId='YOUR-KB-ID',
    retrievalQuery={
        'text': 'What is the return policy?'
    },
    retrievalConfiguration={
        'vectorSearchConfiguration': {
            'numberOfResults': 5  # Number of chunks to retrieve
        }
    }
)

for result in response['retrievalResults']:
    print(f"Score: {result['score']}")
    print(f"Text: {result['content']['text']}")
    print(f"Source: {result['location']['s3Location']['uri']}")
    print("---")
```

### RetrieveAndGenerate API (With Foundation Model)

Combine retrieval with generation for answers:

```python
response = bedrock_runtime.retrieve_and_generate(
    input={
        'text': 'What is the return policy?'
    },
    retrieveAndGenerateConfiguration={
        'type': 'KNOWLEDGE_BASE',
        'knowledgeBaseConfiguration': {
            'knowledgeBaseId': 'YOUR-KB-ID',
            'modelArn': 'arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-5-sonnet-20241022-v2:0'
        }
    }
)

print(response['output']['text'])

# View sources
for citation in response['citations']:
    for reference in citation['retrievedReferences']:
        print(f"Source: {reference['location']['s3Location']['uri']}")
```

## Chunking Strategies

### Fixed Size Chunking

Split documents into fixed-size chunks:

```hcl
chunking_strategy             = "FIXED_SIZE"
fixed_size_max_tokens         = 300  # Tokens per chunk
fixed_size_overlap_percentage = 20   # Overlap between chunks
```

**Guidelines:**
- **Small chunks (200-300 tokens)**: Better for precise retrieval, more chunks
- **Large chunks (500-800 tokens)**: More context, fewer chunks
- **Overlap (10-30%)**: Prevents information loss at boundaries

### No Chunking

Keep documents whole (not recommended for large documents):

```hcl
chunking_strategy = "NONE"
```

## Supported Document Formats

Amazon Bedrock Knowledge Bases supports:

- PDF (.pdf)
- Microsoft Word (.doc, .docx)
- Markdown (.md)
- Plain text (.txt)
- HTML (.html)
- CSV (.csv)
- Microsoft Excel (.xls, .xlsx)
- Microsoft PowerPoint (.ppt, .pptx)

## OpenSearch Serverless Setup

Create an OpenSearch Serverless collection for your knowledge base:

```hcl
# Encryption policy
resource "aws_opensearchserverless_security_policy" "encryption" {
  name = "kb-encryption-policy"
  type = "encryption"

  policy = jsonencode({
    Rules = [{
      Resource     = ["collection/my-kb-*"]
      ResourceType = "collection"
    }]
    AWSOwnedKey = true
  })
}

# Network policy
resource "aws_opensearchserverless_security_policy" "network" {
  name = "kb-network-policy"
  type = "network"

  policy = jsonencode([{
    Rules = [{
      Resource     = ["collection/my-kb-*"]
      ResourceType = "collection"
    }]
    AllowFromPublic = true
  }])
}

# Data access policy
resource "aws_opensearchserverless_access_policy" "data" {
  name = "kb-data-policy"
  type = "data"

  policy = jsonencode([{
    Rules = [
      {
        Resource     = ["collection/my-kb-*"]
        Permission   = ["aoss:CreateCollectionItems", "aoss:UpdateCollectionItems", "aoss:DescribeCollectionItems"]
        ResourceType = "collection"
      },
      {
        Resource     = ["index/my-kb-*/*"]
        Permission   = ["aoss:CreateIndex", "aoss:UpdateIndex", "aoss:DescribeIndex", "aoss:ReadDocument", "aoss:WriteDocument"]
        ResourceType = "index"
      }
    ]
    Principal = ["*"]
  }])
}

# Collection
resource "aws_opensearchserverless_collection" "kb" {
  name = "my-kb-collection"
  type = "VECTORSEARCH"

  depends_on = [
    aws_opensearchserverless_security_policy.encryption,
    aws_opensearchserverless_security_policy.network
  ]
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

- **Ingestion Time**: Depends on document size and count. Monitor with `get-ingestion-job`.
- **Costs**: Includes vector database storage, embedding model inference, and retrieval costs.
- **Regional Availability**: Check AWS documentation for Bedrock availability in your region.
- **Vector Dimensions**: Ensure your vector database supports the dimensions of your chosen embedding model.
- **Document Limits**: S3 data sources support up to 10,000 documents by default (can be increased).

## Best Practices

1. **Choose Appropriate Chunk Size**: Balance between context and precision
2. **Use Inclusion Prefixes**: Filter documents to only index relevant content
3. **Monitor Ingestion Jobs**: Check for failures and retry if needed
4. **Test Retrieval Quality**: Adjust chunking and embedding models based on results
5. **Secure S3 Buckets**: Use encryption and access controls for document buckets
6. **Set Retention Policies**: Use `data_deletion_policy` appropriately for compliance

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
