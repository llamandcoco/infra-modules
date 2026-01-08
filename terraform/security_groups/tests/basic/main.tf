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

module "security_groups" {
  source = "../.."

  vpc_id = "vpc-12345678"

  security_groups = {
    control = {
      name        = "test-control-sg"
      description = "Control plane"
      ingress_rules = [
        {
          description = "API"
          from_port   = 6443
          to_port     = 6443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          description   = "kubelet from workers"
          from_port     = 10250
          to_port       = 10250
          protocol      = "tcp"
          source_sg_key = "worker"
        }
      ]
    }

    worker = {
      name        = "test-worker-sg"
      description = "Workers"
      ingress_rules = [
        {
          description   = "kubelet from control"
          from_port     = 10250
          to_port       = 10250
          protocol      = "tcp"
          source_sg_key = "control"
        },
        {
          description = "nodeport"
          from_port   = 30000
          to_port     = 32767
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          description = "self allow"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          self        = true
        }
      ]
    }
  }
}

output "security_group_ids" {
  value = module.security_groups.security_group_ids
}
