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

# Step scaling example - aggressive scaling for sudden CPU/RPS spikes
module "asg" {
  source = "../.."

  name              = "example-step-scaling"
  vpc_subnet_ids    = ["subnet-123", "subnet-456"]
  target_group_arns = ["arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/example/50dc6c495c0c9188"]

  min_size         = 2
  max_size         = 10
  desired_capacity = 2

  instance_type = "t3.small"

  # Use a static AMI and disable the SSM lookup to keep the test CI-safe
  use_ssm_ami_lookup = false
  ami_id             = "ami-00000000000000000"

  security_group_ids        = ["sg-12345678"]
  iam_instance_profile_name = null

  # Enable Step Scaling for CPU (aggressive scaling above 75%)
  enable_step_scaling_cpu     = true
  cpu_step_threshold          = 75
  cpu_step_evaluation_periods = 1
  cpu_step_instance_warmup    = 60 # Fast warmup for aggressive scaling
  cpu_step_adjustments = [
    {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 10 # 75-85% CPU
      scaling_adjustment          = 1  # Add 1 instance
    },
    {
      metric_interval_lower_bound = 10 # 85%+ CPU
      scaling_adjustment          = 3  # Add 3 instances aggressively
    }
  ]

  # Enable Step Scaling for RPS (aggressive scaling above 150 RPS/target)
  enable_step_scaling_rps         = true
  rps_step_threshold              = 150
  rps_step_evaluation_periods     = 1
  rps_step_instance_warmup        = 60
  alb_target_group_resource_label = "targetgroup/example/50dc6c495c0c9188"
  rps_step_adjustments = [
    {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 50 # 150-200 RPS
      scaling_adjustment          = 2
    },
    {
      metric_interval_lower_bound = 50 # 200+ RPS
      scaling_adjustment          = 4
    }
  ]

  # Also enable target tracking as baseline (slower, steady-state scaling)
  enable_target_tracking_cpu = true
  cpu_target_value           = 50

  enable_target_tracking_alb = true
  alb_target_value           = 100

  tags = {
    Environment = "production"
    ScalingType = "step-scaling"
  }
}

output "asg_name" {
  value = module.asg.asg_name
}

output "step_cpu_policy_arn" {
  value = module.asg.step_cpu_policy_arn
}

output "step_rps_policy_arn" {
  value = module.asg.step_rps_policy_arn
}

output "cpu_high_step_alarm_arn" {
  value = module.asg.cpu_high_step_alarm_arn
}

output "rps_high_step_alarm_arn" {
  value = module.asg.rps_high_step_alarm_arn
}
