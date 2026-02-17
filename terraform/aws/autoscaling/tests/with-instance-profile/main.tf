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

# Create instance profile with ECR, SSM, CloudWatch permissions
module "instance_profile" {
  source = "../../../instance-profile"

  name = "example-asg-profile"

  # Enable common permissions for containerized applications
  enable_ecr                 = true
  enable_ssm                 = true
  enable_ssm_session_manager = true
  enable_cw_logs             = true
  enable_cw_agent            = true

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# Create ASG with the instance profile
module "asg" {
  source = "../.."

  name              = "example-with-profile"
  vpc_subnet_ids    = ["subnet-123", "subnet-456"]
  target_group_arns = []

  min_size         = 1
  max_size         = 5
  desired_capacity = 2

  instance_type = "t3.small"

  # Use a static AMI and disable the SSM lookup to keep the test CI-safe
  use_ssm_ami_lookup = false
  ami_id             = "ami-00000000000000000"

  security_group_ids = ["sg-12345678"]

  # Attach the instance profile from the module
  iam_instance_profile_name = module.instance_profile.instance_profile_name

  # Enable target tracking scaling
  enable_target_tracking_cpu = true
  cpu_target_value           = 50

  tags = {
    Environment = "production"
    Application = "example-app"
  }
}

# Outputs
output "asg_name" {
  value = module.asg.asg_name
}

output "instance_profile_name" {
  value = module.instance_profile.instance_profile_name
}

output "instance_profile_arn" {
  value = module.instance_profile.instance_profile_arn
}

output "role_arn" {
  value = module.instance_profile.role_arn
}

output "inline_policy_names" {
  value = module.instance_profile.inline_policy_names
}
