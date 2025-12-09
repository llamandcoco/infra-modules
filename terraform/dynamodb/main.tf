terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# DynamoDB Table
# Creates the main DynamoDB table resource
resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = var.billing_mode

  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity

  hash_key  = var.hash_key
  range_key = var.range_key

  attribute = var.attributes

  ttl {
    attribute_name = var.ttl_attribute_name
    enabled        = var.ttl_enabled
  }

  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_view_type

  tags = merge(
    var.tags,
    {
      Name = var.table_name
    }
  )
}
