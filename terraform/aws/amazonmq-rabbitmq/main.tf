terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Amazon MQ RabbitMQ Configuration
# Creates a RabbitMQ configuration for use with Amazon MQ brokers
resource "aws_mq_configuration" "this" {
  name           = var.configuration_name
  description    = var.description
  engine_type    = "RABBITMQ"
  engine_version = var.engine_version

  data = var.configuration_data

  tags = merge(
    var.tags,
    {
      Name = var.configuration_name
    }
  )
}
