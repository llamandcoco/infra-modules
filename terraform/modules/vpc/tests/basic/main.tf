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

module "test_vpc" {
  source = "../../"

  name                                 = "test-vpc"
  cidr_block                           = "10.0.0.0/16"
  enable_dns_support                   = true
  enable_dns_hostnames                 = true
  enable_ipv6                          = false
  enable_network_address_usage_metrics = false

  tags = {
    Environment = "test"
  }
}
