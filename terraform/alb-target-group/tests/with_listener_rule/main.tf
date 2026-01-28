terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Mock AWS provider for testing without credentials
provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  access_key = "test"
  secret_key = "test"
}

module "target_group_with_rule" {
  source = "../../"

  name        = "test-rule-tg"
  vpc_id      = "vpc-12345678"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"

  listener_arn      = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/test/50dc6c495c0c9188/6f6f8b3a59f7b8c0"
  listener_priority = 10
  listener_conditions = [
    {
      path_pattern = {
        values = ["/ecs/*"]
      }
    }
  ]
}
