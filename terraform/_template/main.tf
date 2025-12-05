terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# TODO: Add your resource definitions here
# Example:
# resource "aws_example_resource" "main" {
#   name = var.resource_name
#   tags = var.tags
# }
