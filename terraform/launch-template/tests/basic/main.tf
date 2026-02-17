terraform {
  required_version = ">= 1.0"
}

# Mock AWS provider for offline testing (no credentials required)
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

# Basic launch template with minimal configuration
module "launch_template" {
  source = "../.."

  name          = "example-lt"
  instance_type = "t3.micro"

  # Use a static AMI and disable the SSM lookup to keep the test CI-safe
  use_ssm_ami_lookup = false
  image_id           = "ami-00000000000000000"

  # Security groups
  vpc_security_group_ids = ["sg-12345678"]

  # IMDSv2 enforced by default
  # metadata_options defaults to http_tokens = "required"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
  }
}

# Outputs to verify the module works
output "launch_template_id" {
  description = "Launch template ID"
  value       = module.launch_template.id
}

output "launch_template_arn" {
  description = "Launch template ARN"
  value       = module.launch_template.arn
}

output "latest_version" {
  description = "Latest version of the launch template"
  value       = module.launch_template.latest_version
}
