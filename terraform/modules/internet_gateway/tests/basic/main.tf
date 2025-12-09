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

  name       = "igw-test"
  cidr_block = "10.2.0.0/16"
}

module "igw" {
  source = "../.."

  name   = "igw-test"
  vpc_id = module.vpc.vpc_id
}
