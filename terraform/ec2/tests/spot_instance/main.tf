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

# Test the module with spot instance configuration
# This demonstrates cost-effective compute for fault-tolerant workloads
# Use cases: batch processing, CI/CD runners, dev/test environments
module "test_spot_instance" {
  source = "../../"

  # Required variables
  instance_name = "test-spot-instance"
  ami_id        = "ami-0c55b159cbfafe1f0" # Example Amazon Linux 2023 AMI
  instance_type = "c6i.large"             # Compute-optimized for batch processing
  subnet_id     = "subnet-12345678"

  # Use existing security group (mock)
  vpc_security_group_ids = ["sg-12345678"]

  # Spot instance configuration
  enable_spot_instance                = true
  spot_price                          = "0.05" # Maximum price per hour (optional, defaults to on-demand price)
  spot_instance_interruption_behavior = "terminate"
  spot_instance_type                  = "one-time"

  # Root volume configuration
  root_block_device = {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  # IMDSv2 required (security best practice)
  metadata_options = {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Environment = "development"
    ManagedBy   = "terraform"
    Purpose     = "batch-processing"
    TestType    = "spot-instance"
    CostCenter  = "engineering"
  }
}

# Test outputs
output "instance_id" {
  description = "The ID of the spot instance"
  value       = module.test_spot_instance.instance_id
}

output "spot_request_id" {
  description = "The ID of the spot instance request"
  value       = module.test_spot_instance.spot_request_id
}

output "spot_request_state" {
  description = "The state of the spot instance request"
  value       = module.test_spot_instance.spot_request_state
}

output "spot_bid_status" {
  description = "The bid status of the spot instance request"
  value       = module.test_spot_instance.spot_bid_status
}

output "private_ip" {
  description = "The private IP address of the instance"
  value       = module.test_spot_instance.private_ip
}

output "instance_state" {
  description = "The state of the instance"
  value       = module.test_spot_instance.instance_state
}
