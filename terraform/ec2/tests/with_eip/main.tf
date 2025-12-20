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

# Test the module with Elastic IP and custom security group
# This demonstrates a public-facing EC2 instance (e.g., web server, bastion host)
module "test_ec2_with_eip" {
  source = "../../"

  # Required variables
  instance_name = "test-public-instance"
  ami_id        = "ami-0c55b159cbfafe1f0" # Example Amazon Linux 2023 AMI
  instance_type = "t3.small"
  subnet_id     = "subnet-12345678" # Public subnet

  # Avoid real AWS calls in tests
  lookup_subnet_data         = false
  fallback_availability_zone = "us-east-1a"

  # VPC configuration for security group
  vpc_id = "vpc-12345678"

  # Create a custom security group
  create_security_group      = true
  security_group_name        = "test-web-server-sg"
  security_group_description = "Security group for web server - allows HTTP, HTTPS, and SSH"

  # Security group rules for web server
  security_group_rules = [
    {
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"] # SSH from internal network only
      description = "SSH access from internal network"
    },
    {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP access from internet"
    },
    {
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS access from internet"
    },
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["10.0.0.0/8"]
      description = "Restrict outbound traffic to internal network"
    }
  ]

  # Network configuration
  associate_public_ip_address = true
  create_eip                  = true # Associate Elastic IP for static IP

  # SSH key for instance access
  key_name = "my-ssh-key"

  # Root volume configuration
  root_block_device = {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  # IMDSv2 required (security best practice)
  metadata_options = {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Purpose     = "web-server"
    TestType    = "with-eip"
    Public      = "true"
  }
}

# Test outputs
output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.test_ec2_with_eip.instance_id
}

output "private_ip" {
  description = "The private IP address of the instance"
  value       = module.test_ec2_with_eip.private_ip
}

output "public_ip" {
  description = "The public IP address assigned by AWS"
  value       = module.test_ec2_with_eip.public_ip
}

output "eip_public_ip" {
  description = "The Elastic IP address"
  value       = module.test_ec2_with_eip.eip_public_ip
}

output "eip_allocation_id" {
  description = "The EIP allocation ID"
  value       = module.test_ec2_with_eip.eip_allocation_id
}

output "security_group_id" {
  description = "The ID of the created security group"
  value       = module.test_ec2_with_eip.security_group_id
}

output "security_group_name" {
  description = "The name of the created security group"
  value       = module.test_ec2_with_eip.security_group_name
}
