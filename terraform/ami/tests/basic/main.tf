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

# -----------------------------------------------------------------------------
# Test 1: Find Amazon Linux 2 AMI
# -----------------------------------------------------------------------------

module "amazon_linux_2" {
  source = "../../"

  owners = ["amazon"]

  filters = [
    {
      name   = "name"
      values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    },
    {
      name   = "virtualization-type"
      values = ["hvm"]
    },
    {
      name   = "root-device-type"
      values = ["ebs"]
    },
    {
      name   = "state"
      values = ["available"]
    }
  ]

  most_recent = true
}

# -----------------------------------------------------------------------------
# Test 2: Find Ubuntu 22.04 LTS AMI
# -----------------------------------------------------------------------------

module "ubuntu_2204" {
  source = "../../"

  owners = ["099720109477"] # Canonical

  filters = [
    {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    },
    {
      name   = "virtualization-type"
      values = ["hvm"]
    },
    {
      name   = "state"
      values = ["available"]
    }
  ]

  most_recent = true
}

# -----------------------------------------------------------------------------
# Test 3: Find ARM-based Amazon Linux 2 AMI
# -----------------------------------------------------------------------------

module "amazon_linux_2_arm" {
  source = "../../"

  owners = ["amazon"]

  filters = [
    {
      name   = "name"
      values = ["amzn2-ami-hvm-*-arm64-gp2"]
    },
    {
      name   = "architecture"
      values = ["arm64"]
    },
    {
      name   = "virtualization-type"
      values = ["hvm"]
    },
    {
      name   = "state"
      values = ["available"]
    }
  ]

  most_recent = true
}

# -----------------------------------------------------------------------------
# Test 4: Use specific AMI ID
# -----------------------------------------------------------------------------

module "specific_ami" {
  source = "../../"

  ami_id = "ami-0123456789abcdef0"
}

# -----------------------------------------------------------------------------
# Test Outputs
# -----------------------------------------------------------------------------

output "amazon_linux_2_ami_id" {
  description = "AMI ID for Amazon Linux 2"
  value       = module.amazon_linux_2.ami_id
}

output "amazon_linux_2_ami_name" {
  description = "AMI name for Amazon Linux 2"
  value       = module.amazon_linux_2.ami_name
}

output "ubuntu_ami_id" {
  description = "AMI ID for Ubuntu 22.04 LTS"
  value       = module.ubuntu_2204.ami_id
}

output "arm_ami_architecture" {
  description = "Architecture of ARM-based AMI"
  value       = module.amazon_linux_2_arm.ami_architecture
}

output "specific_ami_id" {
  description = "Specific AMI ID provided"
  value       = module.specific_ami.ami_id
}
