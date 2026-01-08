terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Generate SSH Key Pair (Optional - only if public_key is not provided)
# -----------------------------------------------------------------------------

resource "tls_private_key" "this" {
  count = var.public_key == null ? 1 : 0

  algorithm   = var.algorithm
  rsa_bits    = var.algorithm == "RSA" ? var.rsa_bits : null
  ecdsa_curve = var.algorithm == "ECDSA" ? var.ecdsa_curve : null
}

# -----------------------------------------------------------------------------
# AWS Key Pair
# -----------------------------------------------------------------------------

resource "aws_key_pair" "this" {
  key_name   = var.key_name
  public_key = var.public_key != null ? var.public_key : tls_private_key.this[0].public_key_openssh

  tags = merge(
    var.tags,
    {
      Name = var.key_name
    }
  )
}

# -----------------------------------------------------------------------------
# Save Private Key to Local File (Optional)
# -----------------------------------------------------------------------------

resource "local_file" "private_key" {
  count = var.save_private_key && var.public_key == null ? 1 : 0

  content         = tls_private_key.this[0].private_key_pem
  filename        = var.private_key_filename != null ? var.private_key_filename : "${path.root}/${var.key_name}.pem"
  file_permission = "0400"
}

resource "local_file" "public_key" {
  count = var.save_public_key && var.public_key == null ? 1 : 0

  content         = tls_private_key.this[0].public_key_openssh
  filename        = var.public_key_filename != null ? var.public_key_filename : "${path.root}/${var.key_name}.pub"
  file_permission = "0644"
}
