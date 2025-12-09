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

module "vpc" {
  source = "../../vpc"

  name       = "nat-test"
  cidr_block = "10.3.0.0/16"
}

module "subnets" {
  source = "../../subnet"

  vpc_id              = module.vpc.vpc_id
  azs                 = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs = ["10.3.0.0/24", "10.3.1.0/24"]
}

module "nat" {
  source = "../.."

  public_subnet_ids = module.subnets.public_subnet_ids
  create_per_az     = true
  name_prefix       = "nat-test"
}
