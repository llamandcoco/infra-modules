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

module "basic_target_group" {
  source = "../../"

  name        = "test-basic-tg"
  vpc_id      = "vpc-12345678"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"

  health_check = {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 20
    path                = "/healthz"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200-399"
  }

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
  }
}
