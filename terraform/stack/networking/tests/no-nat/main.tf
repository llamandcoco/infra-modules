terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  token                       = "mock_token"
  skip_credentials_validation = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

module "networking" {
  source = "../.."

  name       = "test-no-nat"
  cidr_block = "10.8.0.0/16"
  azs        = ["us-east-1a", "us-east-1b"]

  # No NAT gateway - fully isolated private network
  nat_gateway_mode = "none"

  # Only private subnets, no public subnets
  public_subnet_cidrs             = []
  internet_gateway_enabled        = false
  workload_security_group_ingress = []
}

output "nat_gateway_ids" {
  description = "Should be empty"
  value       = module.networking.nat_gateway_ids
}

output "internet_gateway_id" {
  description = "Should be null"
  value       = module.networking.internet_gateway_id
}

output "computed_cidrs" {
  description = "Auto-computed subnet CIDRs"
  value       = module.networking.computed_subnet_cidrs
}
