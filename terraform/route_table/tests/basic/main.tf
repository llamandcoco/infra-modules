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
  source = "../../../vpc"

  name       = "rt-test"
  cidr_block = "10.4.0.0/16"
}

module "subnets" {
  source = "../../../subnet"

  vpc_id               = module.vpc.vpc_id
  azs                  = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.4.0.0/24", "10.4.1.0/24"]
  private_subnet_cidrs = ["10.4.10.0/24", "10.4.11.0/24"]
}

module "igw" {
  source = "../../../internet_gateway"

  name   = "rt-test"
  vpc_id = module.vpc.vpc_id
}

module "nat" {
  source = "../../../nat_gateway"

  public_subnet_ids = module.subnets.public_subnet_ids
  create_per_az     = true
}

module "route_tables" {
  source = "../.."

  vpc_id                 = module.vpc.vpc_id
  internet_gateway_id    = module.igw.internet_gateway_id
  nat_gateway_ids        = module.nat.nat_gateway_ids
  public_subnet_ids      = module.subnets.public_subnet_ids
  private_subnet_ids     = module.subnets.private_subnet_ids
  database_subnet_ids    = []
  database_route_via_nat = false
}
