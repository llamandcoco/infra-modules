terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Mock AWS provider for testing without credentials
provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  access_key = "test"
  secret_key = "test"
}

module "test_eks_node_role" {
  source = "../../"

  role_name         = "test-eks-node-role"
  enable_ssm        = true
  enable_cloudwatch = true

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
  }
}

output "role_arn" {
  description = "ARN of the EKS node IAM role"
  value       = module.test_eks_node_role.role_arn
}

output "role_name" {
  description = "Name of the EKS node IAM role"
  value       = module.test_eks_node_role.role_name
}

output "role_id" {
  description = "ID of the EKS node IAM role"
  value       = module.test_eks_node_role.role_id
}
