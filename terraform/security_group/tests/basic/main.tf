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

  name       = "sg-test"
  cidr_block = "10.5.0.0/16"
}

module "security_group" {
  source = "../.."

  name        = "sg-test"
  description = "Test security group"
  vpc_id      = module.vpc.vpc_id
  ingress_rules = [
    {
      description = "Allow HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["10.5.0.0/16"]
    }
  ]
  egress_rules = []
}
