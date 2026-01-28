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

module "test_vpc_no_default_nacl" {
  source = "../../"

  name                                 = "test-vpc-no-default-nacl"
  cidr_block                           = "10.1.0.0/16"
  enable_dns_support                   = true
  enable_dns_hostnames                 = true
  enable_ipv6                          = false
  enable_network_address_usage_metrics = false

  manage_default_nacl            = false
  ignore_default_nacl_subnet_ids = true

  tags = {
    Environment = "test"
  }
}
