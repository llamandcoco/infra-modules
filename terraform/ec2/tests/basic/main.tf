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

# Test the module with minimal configuration
# This creates a basic EC2 instance in a private subnet with default settings
module "test_basic_ec2" {
  source = "../../"

  # Required variables
  instance_name = "test-basic-instance"
  ami_id        = "ami-0c55b159cbfafe1f0" # Example Amazon Linux 2023 AMI
  instance_type = "t3.micro"
  subnet_id     = "subnet-12345678"

  # Use existing security group (mock)
  vpc_security_group_ids = ["sg-12345678"]

  # No public IP (private instance)
  associate_public_ip_address = false

  # Default root volume (8 GB gp3, encrypted)
  root_block_device = {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  # Enable detailed monitoring for production readiness
  monitoring = false

  # IMDSv2 required (security best practice)
  metadata_options = {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "module-testing"
    TestType    = "basic"
  }
}

# Test outputs
output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.test_basic_ec2.instance_id
}

output "private_ip" {
  description = "The private IP address of the instance"
  value       = module.test_basic_ec2.private_ip
}

output "instance_state" {
  description = "The state of the instance"
  value       = module.test_basic_ec2.instance_state
}

output "root_volume_id" {
  description = "The volume ID of the root block device"
  value       = module.test_basic_ec2.root_block_device_volume_id
}
