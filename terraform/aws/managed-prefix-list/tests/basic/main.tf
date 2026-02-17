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

module "prefix_list" {
  source = "../.."

  name           = "test-prefix-list"
  address_family = "IPv4"
  max_entries    = 10

  entries = [
    {
      cidr        = "10.0.0.0/8"
      description = "Private network A"
    },
    {
      cidr        = "172.16.0.0/12"
      description = "Private network B"
    },
    {
      cidr        = "192.168.0.0/16"
      description = "Private network C"
    }
  ]

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
  }
}
