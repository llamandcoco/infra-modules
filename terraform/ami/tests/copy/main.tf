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
  region                      = "us-west-2"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  access_key = "test"
  secret_key = "test"
}

# -----------------------------------------------------------------------------
# Test 1: Copy AMI from us-east-1 to us-west-2 (unencrypted)
# -----------------------------------------------------------------------------

module "copy_ami_basic" {
  source = "../../"

  copy_ami_config = {
    name              = "copied-amazon-linux-2-basic"
    description       = "Copied Amazon Linux 2 AMI for testing"
    source_ami_id     = "ami-0123456789abcdef0"
    source_ami_region = "us-east-1"
    encrypted         = false
  }

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "ami-copy-testing"
  }
}

# -----------------------------------------------------------------------------
# Test 2: Copy AMI with KMS encryption
# -----------------------------------------------------------------------------

module "copy_ami_encrypted" {
  source = "../../"

  copy_ami_config = {
    name              = "copied-amazon-linux-2-encrypted"
    description       = "Encrypted copy of Amazon Linux 2 AMI"
    source_ami_id     = "ami-0123456789abcdef0"
    source_ami_region = "us-east-1"
    encrypted         = true
    kms_key_id        = "arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012"
  }

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Purpose     = "encrypted-ami-copy"
    Compliance  = "required"
  }
}

# -----------------------------------------------------------------------------
# Test 3: Copy AMI with default encryption
# -----------------------------------------------------------------------------

module "copy_ami_default_encryption" {
  source = "../../"

  copy_ami_config = {
    name              = "copied-ubuntu-default-enc"
    description       = "Ubuntu AMI copy with default encryption"
    source_ami_id     = "ami-0fedcba9876543210"
    source_ami_region = "eu-west-1"
    encrypted         = true
  }

  tags = {
    Environment = "staging"
    OS          = "ubuntu"
  }
}

# -----------------------------------------------------------------------------
# Test Outputs
# -----------------------------------------------------------------------------

output "basic_copy_ami_id" {
  description = "ID of the basic copied AMI"
  value       = module.copy_ami_basic.ami_id
}

output "basic_copy_ami_name" {
  description = "Name of the basic copied AMI"
  value       = module.copy_ami_basic.ami_name
}

output "encrypted_copy_ami_id" {
  description = "ID of the encrypted copied AMI"
  value       = module.copy_ami_encrypted.ami_id
}

output "encrypted_copy_source_region" {
  description = "Source region of the encrypted copy"
  value       = module.copy_ami_encrypted.source_ami_region
}

output "default_enc_copy_ami_id" {
  description = "ID of the default encryption copied AMI"
  value       = module.copy_ami_default_encryption.ami_id
}
