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
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

module "networking" {
  source = "../.."

  name       = "stack-test"
  cidr_block = "10.6.0.0/16"
  azs        = ["us-east-1a", "us-east-1b"]

  public_subnet_cidrs   = ["10.6.0.0/24", "10.6.1.0/24"]
  private_subnet_cidrs  = ["10.6.10.0/24", "10.6.11.0/24"]
  database_subnet_cidrs = ["10.6.20.0/24", "10.6.21.0/24"]

  workload_security_group_ingress = []
}
