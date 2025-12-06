// terraform/s3/tests/basic/main.tf
terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock"
  secret_key                  = "mock"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

module "s3" {
  source = "../../"

  # Minimal required inputs for a plan
  bucket_name          = "tf-plan-test-llamandcoco"
  versioning_enabled   = true
  encryption_algorithm = "AES256"
  tags = {
    Test = "basic"
  }
}
