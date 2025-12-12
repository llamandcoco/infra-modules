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

# Test the module with additional EBS volumes
# This demonstrates attaching multiple EBS volumes with different types and configurations
module "test_ec2_with_ebs" {
  source = "../../"

  # Required variables
  instance_name = "test-ebs-instance"
  ami_id        = "ami-0c55b159cbfafe1f0" # Example Amazon Linux 2023 AMI
  instance_type = "r6i.large"             # Memory-optimized for database workloads
  subnet_id     = "subnet-12345678"

  # Use existing security group (mock)
  vpc_security_group_ids = ["sg-12345678"]

  # Larger root volume for OS and application
  root_block_device = {
    volume_size = 50
    volume_type = "gp3"
    iops        = 3000
    throughput  = 125
    encrypted   = true
  }

  # Additional EBS volumes for data storage
  ebs_volumes = [
    {
      device_name = "/dev/sdf"
      volume_size = 100
      volume_type = "gp3"
      iops        = 3000
      throughput  = 125
      encrypted   = true
    },
    {
      device_name = "/dev/sdg"
      volume_size = 500
      volume_type = "io2"
      iops        = 10000
      encrypted   = true
    },
    {
      device_name = "/dev/sdh"
      volume_size = 1000
      volume_type = "st1" # Throughput optimized for big data
      encrypted   = true
    }
  ]

  # Enable detailed monitoring for production workloads
  monitoring = true

  # IMDSv2 required (security best practice)
  metadata_options = {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Purpose     = "database-server"
    TestType    = "with-ebs"
  }

  volume_tags = {
    VolumeManagement = "automated"
    BackupPolicy     = "daily"
  }
}

# Test outputs
output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.test_ec2_with_ebs.instance_id
}

output "private_ip" {
  description = "The private IP address of the instance"
  value       = module.test_ec2_with_ebs.private_ip
}

output "root_volume_id" {
  description = "The volume ID of the root block device"
  value       = module.test_ec2_with_ebs.root_block_device_volume_id
}

output "additional_volume_ids" {
  description = "Map of device names to volume IDs for additional EBS volumes"
  value       = module.test_ec2_with_ebs.ebs_volume_ids
}

output "additional_volume_arns" {
  description = "Map of device names to volume ARNs for additional EBS volumes"
  value       = module.test_ec2_with_ebs.ebs_volume_arns
}
