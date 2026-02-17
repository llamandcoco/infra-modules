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

# Warm pool example - pre-warmed instances for faster scale-out
module "asg" {
  source = "../.."

  name              = "example-warm-pool"
  vpc_subnet_ids    = ["subnet-123", "subnet-456"]
  target_group_arns = []

  min_size         = 2
  max_size         = 10
  desired_capacity = 2

  instance_type = "t3.medium"

  # Use a static AMI and disable the SSM lookup to keep the test CI-safe
  use_ssm_ami_lookup = false
  ami_id             = "ami-00000000000000000"

  security_group_ids        = ["sg-12345678"]
  iam_instance_profile_name = null

  # Enable Warm Pool for faster scale-out
  enable_warm_pool                      = true
  warm_pool_state                       = "Stopped" # Options: Stopped, Running, Hibernated
  warm_pool_min_size                    = 2         # Keep 2 instances warm at all times
  warm_pool_max_group_prepared_capacity = 12        # Total: 10 in-service + 2 warm = 12 max
  warm_pool_reuse_on_scale_in           = true      # Return instances to warm pool on scale-in

  # Faster instance warmup for warm pool instances
  default_instance_warmup = 60 # 60 seconds instead of default 300

  # Enable target tracking scaling
  enable_target_tracking_cpu = true
  cpu_target_value           = 60

  tags = {
    Environment = "production"
    WarmPool    = "enabled"
  }
}

output "asg_name" {
  value = module.asg.asg_name
}

output "launch_template_id" {
  value = module.asg.launch_template_id
}

output "tt_cpu_policy_arn" {
  value = module.asg.tt_cpu_policy_arn
}
