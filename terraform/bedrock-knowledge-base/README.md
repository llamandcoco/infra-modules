# AWS Bedrock Knowledge Base

Production-ready Terraform module for creating Amazon Bedrock Knowledge Bases with vector database integration for Retrieval-Augmented Generation (RAG).

## Features

- Vector Knowledge Bases Enable RAG with foundation models
- Multiple Storage Backends OpenSearch Serverless, RDS (Aurora PostgreSQL), or Pinecone
- S3 Data Sources Automatic document ingestion from S3
- Chunking Strategies Fixed-size or no chunking for documents
- Embedding Models Amazon Titan, Cohere, and more
- IAM Management Automatic role and policy creation
- Document Filtering S3 inclusion prefixes for selective indexing
- Comprehensive Outputs Knowledge base IDs, ARNs, and ingestion examples

## Quick Start

```hcl
module "knowledge_base" {
  source = "github.com/llamandcoco/infra-modules//terraform/bedrock-knowledge-base?ref=<commit-sha>"

  name                = "product-docs-kb"
  embedding_model_arn = "arn:aws:bedrock:*::foundation-model/amazon.titan-embed-text-v1"

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
| Basic | [`tests/basic/main.tf`](tests/basic/main.tf) |
| Advanced | [`tests/advanced/main.tf`](tests/advanced/main.tf) |

**Usage:**
```bash
# View example
cat tests/basic/

# Copy and adapt
cp -r tests/basic/ my-project/
```

## Testing

```bash
cd tests/basic && terraform init && terraform plan
```

<details>
<summary>Terraform Documentation</summary>

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
</details>
