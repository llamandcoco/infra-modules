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

# Advanced launch template with multiple features
module "launch_template" {
  source = "../.."

  name          = "advanced-lt"
  description   = "Advanced launch template with multiple features"
  instance_type = "t3.medium"

  # Use a static AMI and disable the SSM lookup to keep the test CI-safe
  use_ssm_ami_lookup = false
  image_id           = "ami-00000000000000000"

  # SSH key
  key_name = "my-key"

  # Security groups
  vpc_security_group_ids = ["sg-12345678", "sg-87654321"]

  # IAM instance profile
  iam_instance_profile_name = "my-instance-profile"

  # User data
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello World"
    yum update -y
  EOF

  # Enable detailed monitoring
  enable_monitoring = true

  # Block device mappings
  block_device_mappings = [
    {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = 30
        volume_type           = "gp3"
        iops                  = 3000
        throughput            = 125
        encrypted             = true
        delete_on_termination = true
      }
    },
    {
      device_name = "/dev/sdf"
      ebs = {
        volume_size           = 100
        volume_type           = "gp3"
        encrypted             = true
        delete_on_termination = false
      }
    }
  ]

  # CPU credits for T3 instances
  cpu_credits = "unlimited"

  # Placement
  placement = {
    availability_zone = "us-east-1a"
    tenancy           = "default"
  }

  # Tag specifications - tag instances and volumes at launch
  tag_specifications = [
    {
      resource_type = "instance"
      tags = {
        Name        = "my-instance"
        Environment = "production"
        Application = "web"
      }
    },
    {
      resource_type = "volume"
      tags = {
        Name        = "my-volume"
        Environment = "production"
      }
    }
  ]

  # EBS optimized
  ebs_optimized = true

  # Spot instance configuration
  instance_market_options = {
    market_type = "spot"
    spot_options = {
      max_price                      = "0.05"
      spot_instance_type             = "one-time"
      instance_interruption_behavior = "terminate"
    }
  }

  # Tags for the launch template resource
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Owner       = "platform-team"
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
