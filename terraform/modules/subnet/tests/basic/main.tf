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

module "vpc" {
  source = "../../vpc"

  name       = "subnet-test"
  cidr_block = "10.1.0.0/16"
}

module "subnets" {
  source = "../.."

  vpc_id                  = module.vpc.vpc_id
  azs                     = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs     = ["10.1.0.0/24", "10.1.1.0/24"]
  private_subnet_cidrs    = ["10.1.10.0/24", "10.1.11.0/24"]
  database_subnet_cidrs   = ["10.1.20.0/24", "10.1.21.0/24"]
  map_public_ip_on_launch = true
  name_prefix             = "subnet-test"
}
