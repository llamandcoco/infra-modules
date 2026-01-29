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

module "ecs_service" {
  source = "../.."

  cluster_id = "arn:aws:ecs:us-east-1:123456789012:cluster/test-cluster"

  service_name    = "test-service"
  container_name  = "test-container"
  container_image = "nginx:latest"
  container_port  = 80

  subnet_ids         = ["subnet-12345678"]
  security_group_ids = ["sg-12345678"]
  target_group_arn   = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/test/1234567890abcdef"

  execution_role_arn = "arn:aws:iam::123456789012:role/ecs-execution-role"

  tags = {
    Environment = "test"
  }
}
