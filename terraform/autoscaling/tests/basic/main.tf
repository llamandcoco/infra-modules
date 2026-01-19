terraform {
  required_version = ">= 1.3.0"
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

# Basic module invocation that can plan without talking to AWS
module "asg" {
  source = "../.."

  name              = "example"
  vpc_subnet_ids    = ["subnet-123", "subnet-456"]
  target_group_arns = []

  min_size         = 1
  max_size         = 3
  desired_capacity = 1

  instance_type = "t3.micro"

  # Use a static AMI and disable the SSM lookup to keep the test CI-safe
  use_ssm_ami_lookup = false
  ami_id             = "ami-00000000000000000"

  # Attach existing security group (mock values)
  security_group_ids        = ["sg-12345678"]
  iam_instance_profile_name = null

  enable_target_tracking_cpu = true
  cpu_target_value           = 50
}

# Inspect a few key outputs for sanity
output "asg_name" {
  description = "Auto Scaling Group name"
  value       = module.asg.asg_name
}

output "launch_template_id" {
  description = "Launch template ID"
  value       = module.asg.launch_template_id
}

output "tt_cpu_policy_arn" {
  description = "CPU target tracking policy ARN"
  value       = module.asg.tt_cpu_policy_arn
}
