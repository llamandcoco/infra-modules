# -----------------------------------------------------------------------------
# Configuration Identification Outputs
# -----------------------------------------------------------------------------

output "configuration_id" {
  description = "The unique ID of the Amazon MQ configuration. Use this to reference the configuration in broker resources."
  value       = aws_mq_configuration.this.id
}

output "configuration_arn" {
  description = "The ARN of the Amazon MQ configuration. Use this for IAM policies and resource tagging."
  value       = aws_mq_configuration.this.arn
}

output "configuration_name" {
  description = "The name of the Amazon MQ configuration."
  value       = aws_mq_configuration.this.name
}

# -----------------------------------------------------------------------------
# Configuration Details Outputs
# -----------------------------------------------------------------------------

output "description" {
  description = "The description of the Amazon MQ configuration."
  value       = aws_mq_configuration.this.description
}

output "engine_type" {
  description = "The type of broker engine (always 'RABBITMQ' for this module)."
  value       = aws_mq_configuration.this.engine_type
}

output "engine_version" {
  description = "The version of the RabbitMQ broker engine."
  value       = aws_mq_configuration.this.engine_version
}

output "latest_revision" {
  description = "The latest revision number of the configuration."
  value       = aws_mq_configuration.this.latest_revision
}

# -----------------------------------------------------------------------------
# Resource Reference Outputs
# -----------------------------------------------------------------------------

output "tags" {
  description = "All tags applied to the configuration, including default and custom tags."
  value       = aws_mq_configuration.this.tags_all
}
