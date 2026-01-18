terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

module "instance_profile" {
  source = "../.."

  name = "test-profile"

  enable_ecr      = true
  enable_ssm      = true
  enable_cw_logs  = true
  enable_cw_agent = true

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
  }
}

output "instance_profile_name" {
  value = module.instance_profile.instance_profile_name
}

output "role_name" {
  value = module.instance_profile.role_name
}
