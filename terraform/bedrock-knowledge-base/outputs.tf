# -----------------------------------------------------------------------------
# Knowledge Base Outputs
# -----------------------------------------------------------------------------

output "knowledge_base_id" {
  description = "The unique identifier of the Bedrock knowledge base. Use this to associate with agents or query directly."
  value       = aws_bedrockagent_knowledge_base.this.id
}

output "knowledge_base_arn" {
  description = "The ARN of the Bedrock knowledge base. Use this for IAM policies and cross-account access."
  value       = aws_bedrockagent_knowledge_base.this.arn
}

output "knowledge_base_name" {
  description = "The name of the Bedrock knowledge base."
  value       = aws_bedrockagent_knowledge_base.this.name
}

# -----------------------------------------------------------------------------
# Data Source Outputs
# -----------------------------------------------------------------------------

output "data_source_id" {
  description = "The ID of the data source. Use this to trigger ingestion jobs."
  value       = var.s3_data_source_bucket_arn != null ? aws_bedrockagent_data_source.this[0].data_source_id : null
}

output "data_source_name" {
  description = "The name of the data source."
  value       = var.s3_data_source_bucket_arn != null ? aws_bedrockagent_data_source.this[0].name : null
}

# -----------------------------------------------------------------------------
# IAM Role Outputs
# -----------------------------------------------------------------------------

output "kb_role_arn" {
  description = "The ARN of the IAM role used by the knowledge base."
  value       = aws_iam_role.knowledge_base.arn
}

output "kb_role_name" {
  description = "The name of the IAM role used by the knowledge base."
  value       = aws_iam_role.knowledge_base.name
}

output "kb_role_id" {
  description = "The unique ID of the IAM role."
  value       = aws_iam_role.knowledge_base.id
}

# -----------------------------------------------------------------------------
# Configuration Outputs
# -----------------------------------------------------------------------------

output "embedding_model_arn" {
  description = "The ARN of the embedding model used by the knowledge base."
  value       = var.embedding_model_arn
}

output "storage_type" {
  description = "The type of vector database storage used (OPENSEARCH_SERVERLESS, RDS, or PINECONE)."
  value       = local.storage_type
}

output "chunking_strategy" {
  description = "The chunking strategy used for document processing."
  value       = var.chunking_strategy
}

# -----------------------------------------------------------------------------
# Region and Account Outputs
# -----------------------------------------------------------------------------

output "region" {
  description = "The AWS region where the knowledge base is deployed."
  value       = "*"
}

output "account_id" {
  description = "The AWS account ID where the knowledge base is deployed."
  value       = data.aws_caller_identity.current.account_id
}

# -----------------------------------------------------------------------------
# Common Embedding Model ARNs
# -----------------------------------------------------------------------------

output "titan_embed_text_v1_arn" {
  description = "ARN for Amazon Titan Text Embeddings v1 model."
  value       = "arn:aws:bedrock:${"*"}::foundation-model/amazon.titan-embed-text-v1"
}

output "titan_embed_text_v2_arn" {
  description = "ARN for Amazon Titan Text Embeddings v2 model."
  value       = "arn:aws:bedrock:${"*"}::foundation-model/amazon.titan-embed-text-v2:0"
}

output "cohere_embed_english_v3_arn" {
  description = "ARN for Cohere Embed English v3 model."
  value       = "arn:aws:bedrock:${"*"}::foundation-model/cohere.embed-english-v3"
}

output "cohere_embed_multilingual_v3_arn" {
  description = "ARN for Cohere Embed Multilingual v3 model."
  value       = "arn:aws:bedrock:${"*"}::foundation-model/cohere.embed-multilingual-v3"
}

# -----------------------------------------------------------------------------
# Ingestion Job Commands
# -----------------------------------------------------------------------------

output "start_ingestion_job_cli_example" {
  description = "AWS CLI example command to start an ingestion job for the data source."
  value = var.s3_data_source_bucket_arn != null ? (
    "aws bedrock-agent start-ingestion-job --knowledge-base-id ${aws_bedrockagent_knowledge_base.this.id} --data-source-id ${aws_bedrockagent_data_source.this[0].data_source_id}"
  ) : "No data source configured"
}

output "boto3_ingestion_example" {
  description = "Python boto3 example code to start an ingestion job."
  value = var.s3_data_source_bucket_arn != null ? <<-EOT
    import boto3

    bedrock_agent = boto3.client('bedrock-agent')

    response = bedrock_agent.start_ingestion_job(
        knowledgeBaseId='${aws_bedrockagent_knowledge_base.this.id}',
        dataSourceId='${aws_bedrockagent_data_source.this[0].data_source_id}'
    )

    print(f"Ingestion job started: {response['ingestionJob']['ingestionJobId']}")
  EOT
  : "No data source configured"
}

output "retrieve_query_cli_example" {
  description = "AWS CLI example command to query the knowledge base."
  value = <<-EOT
    aws bedrock-agent-runtime retrieve \
      --knowledge-base-id ${aws_bedrockagent_knowledge_base.this.id} \
      --retrieval-query text="Your search query here"
  EOT
}

output "boto3_retrieve_example" {
  description = "Python boto3 example code to query the knowledge base."
  value = <<-EOT
    import boto3

    bedrock_agent_runtime = boto3.client('bedrock-agent-runtime')

    response = bedrock_agent_runtime.retrieve(
        knowledgeBaseId='${aws_bedrockagent_knowledge_base.this.id}',
        retrievalQuery={
            'text': 'Your search query here'
        }
    )

    for result in response['retrievalResults']:
        print(f"Score: {result['score']}")
        print(f"Content: {result['content']['text']}")
        print("---")
  EOT
}
