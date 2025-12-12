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

  name       = "test-stack"
  cidr_block = "10.6.0.0/16"
  azs        = ["us-east-1a", "us-east-1b"]

  # Using auto-calculated CIDRs (new feature!)
  # public_subnet_cidrs, private_subnet_cidrs, database_subnet_cidrs are auto-calculated

  workload_security_group_ingress = []
}

output "computed_cidrs" {
  description = "Auto-computed subnet CIDRs"
  value       = module.networking.computed_subnet_cidrs
}

locals {
  expected_names = {
    vpc              = "test-stack-vpc"
    internet_gateway = "test-stack-igw"
    subnets = {
      public  = ["test-stack-subnet-public-a", "test-stack-subnet-public-b"]
      private = ["test-stack-subnet-private-a", "test-stack-subnet-private-b"]
    }
    route_tables = {
      private = {
        "0" = "test-stack-rt-private-a"
        "1" = "test-stack-rt-private-b"
      }
      public = "test-stack-rt-public"
    }
    nat_gateways = ["test-stack-nat-a", "test-stack-nat-b"]
  }
}

check "naming" {
  assert {
    condition     = module.networking.resource_names.vpc == local.expected_names.vpc
    error_message = "VPC Name tag mismatch"
  }

  assert {
    condition     = module.networking.resource_names.internet_gateway == local.expected_names.internet_gateway
    error_message = "IGW Name tag mismatch"
  }

  assert {
    condition     = module.networking.resource_names.subnets.public[0] == local.expected_names.subnets.public[0]
    error_message = "Public subnet A Name tag mismatch"
  }

  assert {
    condition     = module.networking.resource_names.subnets.public[1] == local.expected_names.subnets.public[1]
    error_message = "Public subnet B Name tag mismatch"
  }

  assert {
    condition     = module.networking.resource_names.subnets.private[0] == local.expected_names.subnets.private[0]
    error_message = "Private subnet A Name tag mismatch"
  }

  assert {
    condition     = module.networking.resource_names.subnets.private[1] == local.expected_names.subnets.private[1]
    error_message = "Private subnet B Name tag mismatch"
  }

  assert {
    condition     = module.networking.resource_names.route_tables.public == local.expected_names.route_tables.public
    error_message = "Public route table Name tag mismatch"
  }

  assert {
    condition     = module.networking.resource_names.route_tables.private == local.expected_names.route_tables.private
    error_message = "Private route table Name tag mismatch"
  }

  assert {
    condition     = module.networking.resource_names.nat_gateways[0] == local.expected_names.nat_gateways[0]
    error_message = "NAT Gateway A Name tag mismatch"
  }

  assert {
    condition     = module.networking.resource_names.nat_gateways[1] == local.expected_names.nat_gateways[1]
    error_message = "NAT Gateway B Name tag mismatch"
  }

  assert {
    condition     = length(module.networking.resource_names.subnets.public) == 2
    error_message = "Expected two public subnets"
  }

  assert {
    condition     = length(module.networking.resource_names.subnets.private) == 2
    error_message = "Expected two private subnets"
  }
}
