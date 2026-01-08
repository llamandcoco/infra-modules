# -----------------------------------------------------------------------------
# Key Pair Outputs
# -----------------------------------------------------------------------------

output "key_pair_id" {
  description = "The key pair ID"
  value       = aws_key_pair.this.id
}

output "key_pair_arn" {
  description = "The key pair ARN"
  value       = aws_key_pair.this.arn
}

output "key_name" {
  description = "The key pair name"
  value       = aws_key_pair.this.key_name
}

output "key_pair_fingerprint" {
  description = "The MD5 public key fingerprint as specified in section 4 of RFC 4716"
  value       = aws_key_pair.this.fingerprint
}

output "public_key_openssh" {
  description = "The public key data in OpenSSH authorized_keys format"
  value       = aws_key_pair.this.public_key
}

# -----------------------------------------------------------------------------
# Generated Key Outputs (Only available when key is generated)
# -----------------------------------------------------------------------------

output "private_key_pem" {
  description = "Private key data in PEM format. WARNING: Sensitive value, only available when key is generated."
  value       = var.public_key == null ? tls_private_key.this[0].private_key_pem : null
  sensitive   = true
}

output "private_key_openssh" {
  description = "Private key data in OpenSSH format. WARNING: Sensitive value, only available when key is generated."
  value       = var.public_key == null ? tls_private_key.this[0].private_key_openssh : null
  sensitive   = true
}

output "public_key_pem" {
  description = "Public key data in PEM format. Only available when key is generated."
  value       = var.public_key == null ? tls_private_key.this[0].public_key_pem : null
}

output "private_key_filename" {
  description = "Path to the saved private key file (if save_private_key is true)"
  value       = var.save_private_key && var.public_key == null ? local_file.private_key[0].filename : null
}

output "public_key_filename" {
  description = "Path to the saved public key file (if save_public_key is true)"
  value       = var.save_public_key && var.public_key == null ? local_file.public_key[0].filename : null
}
