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
# Test: Generate new key pair
# -----------------------------------------------------------------------------

module "generated_key" {
  source = "../.."

  key_name = "test-generated-key"

  # Generate new key pair
  public_key = null

  # Save keys to files
  save_private_key     = true
  save_public_key      = true
  private_key_filename = "${path.module}/test-key.pem"
  public_key_filename  = "${path.module}/test-key.pub"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
  }
}

# -----------------------------------------------------------------------------
# Test: Import existing public key
# -----------------------------------------------------------------------------

module "imported_key" {
  source = "../.."

  key_name = "test-imported-key"

  # Use existing public key (example - replace with real key)
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... your-key-here"

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
  }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "generated_key_name" {
  value = module.generated_key.key_name
}

output "generated_key_fingerprint" {
  value = module.generated_key.key_pair_fingerprint
}

output "generated_private_key_file" {
  value = module.generated_key.private_key_filename
}

output "imported_key_name" {
  value = module.imported_key.key_name
}
