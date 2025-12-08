# -----------------------------------------------------------------------------
# Table Identification Outputs
# -----------------------------------------------------------------------------

output "table_name" {
  description = "The name of the DynamoDB table. Use this for table references in application code and other resources."
  value       = aws_dynamodb_table.this.name
}

output "table_id" {
  description = "The ID of the DynamoDB table (same as table_name). Provided for consistency with other AWS resources."
  value       = aws_dynamodb_table.this.id
}

output "table_arn" {
  description = "The ARN of the DynamoDB table. Use this for IAM policies and cross-account access configurations."
  value       = aws_dynamodb_table.this.arn
}

# -----------------------------------------------------------------------------
# Table Configuration Outputs
# -----------------------------------------------------------------------------

output "table_billing_mode" {
  description = "The billing mode of the table (PROVISIONED or PAY_PER_REQUEST)."
  value       = aws_dynamodb_table.this.billing_mode
}

output "table_hash_key" {
  description = "The hash (partition) key attribute name of the table."
  value       = aws_dynamodb_table.this.hash_key
}

output "table_range_key" {
  description = "The range (sort) key attribute name of the table, if configured."
  value       = aws_dynamodb_table.this.range_key
}

output "table_class" {
  description = "The storage class of the table (STANDARD or STANDARD_INFREQUENT_ACCESS)."
  value       = aws_dynamodb_table.this.table_class
}

# -----------------------------------------------------------------------------
# DynamoDB Streams Outputs
# -----------------------------------------------------------------------------

output "stream_enabled" {
  description = "Whether DynamoDB Streams is enabled for the table."
  value       = aws_dynamodb_table.this.stream_enabled
}

output "stream_arn" {
  description = "The ARN of the DynamoDB stream. Use this to configure Lambda event source mappings or other stream consumers."
  value       = var.stream_enabled ? aws_dynamodb_table.this.stream_arn : null
}

output "stream_label" {
  description = "The timestamp of the stream. Changes whenever the stream is enabled/disabled or the stream view type changes."
  value       = var.stream_enabled ? aws_dynamodb_table.this.stream_label : null
}

output "stream_view_type" {
  description = "The type of data written to the stream (KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, or NEW_AND_OLD_IMAGES)."
  value       = var.stream_enabled ? aws_dynamodb_table.this.stream_view_type : null
}

# -----------------------------------------------------------------------------
# Security Outputs
# -----------------------------------------------------------------------------

output "kms_key_arn" {
  description = "The ARN of the KMS key used for encryption. Null if using AWS owned key."
  value       = var.kms_key_arn
}

output "point_in_time_recovery_enabled" {
  description = "Whether point-in-time recovery is enabled. Important for compliance and data protection verification."
  value       = aws_dynamodb_table.this.point_in_time_recovery[0].enabled
}

# -----------------------------------------------------------------------------
# TTL Outputs
# -----------------------------------------------------------------------------

output "ttl_enabled" {
  description = "Whether Time To Live (TTL) is enabled on the table."
  value       = var.ttl_attribute_name != null ? var.ttl_enabled : false
}

output "ttl_attribute_name" {
  description = "The attribute name used for TTL, if configured."
  value       = var.ttl_attribute_name
}

# -----------------------------------------------------------------------------
# Global Secondary Index Outputs
# -----------------------------------------------------------------------------

output "global_secondary_indexes" {
  description = "List of Global Secondary Indexes configured on the table with their names and key attributes."
  value = [
    for gsi in aws_dynamodb_table.this.global_secondary_index :
    {
      name       = gsi.name
      hash_key   = gsi.hash_key
      range_key  = gsi.range_key
      projection = gsi.projection_type
    }
  ]
}

# -----------------------------------------------------------------------------
# Local Secondary Index Outputs
# -----------------------------------------------------------------------------

output "local_secondary_indexes" {
  description = "List of Local Secondary Indexes configured on the table with their names and key attributes."
  value = [
    for lsi in aws_dynamodb_table.this.local_secondary_index :
    {
      name       = lsi.name
      range_key  = lsi.range_key
      projection = lsi.projection_type
    }
  ]
}

# -----------------------------------------------------------------------------
# Auto Scaling Outputs
# -----------------------------------------------------------------------------

output "autoscaling_enabled" {
  description = "Whether auto-scaling is enabled for the table (only applicable for PROVISIONED billing mode)."
  value       = var.billing_mode == "PROVISIONED" && var.enable_autoscaling
}

output "read_capacity" {
  description = "The provisioned read capacity units for the table (only applicable for PROVISIONED billing mode)."
  value       = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
}

output "write_capacity" {
  description = "The provisioned write capacity units for the table (only applicable for PROVISIONED billing mode)."
  value       = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
}

# -----------------------------------------------------------------------------
# Resource Reference Outputs
# -----------------------------------------------------------------------------

output "tags" {
  description = "All tags applied to the table, including default and custom tags."
  value       = aws_dynamodb_table.this.tags_all
}
