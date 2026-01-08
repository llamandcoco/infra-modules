# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "key_name" {
  description = "Name of the SSH key pair to create in AWS."
  type        = string

  validation {
    condition     = length(var.key_name) >= 1 && length(var.key_name) <= 255
    error_message = "Key name must be between 1 and 255 characters long."
  }
}

# -----------------------------------------------------------------------------
# Optional Variables
# -----------------------------------------------------------------------------

variable "public_key" {
  description = <<-EOT
    SSH public key material to use for the key pair. If not provided, a new key pair will be generated.
    Should be in OpenSSH format (starts with 'ssh-rsa', 'ssh-ed25519', etc.).
  EOT
  type        = string
  default     = null
}

variable "algorithm" {
  description = <<-EOT
    Algorithm to use for generating SSH keys when public_key is not provided.
    Valid values: RSA, ECDSA, ED25519
  EOT
  type        = string
  default     = "RSA"

  validation {
    condition     = contains(["RSA", "ECDSA", "ED25519"], var.algorithm)
    error_message = "Algorithm must be one of: RSA, ECDSA, ED25519."
  }
}

variable "rsa_bits" {
  description = "Number of bits for RSA key. Only used when algorithm is RSA and public_key is not provided."
  type        = number
  default     = 4096

  validation {
    condition     = var.rsa_bits >= 2048
    error_message = "RSA bits must be at least 2048 for security."
  }
}

variable "save_private_key" {
  description = <<-EOT
    Whether to save the generated private key to a local file.
    Only applies when public_key is not provided (key is generated).
    WARNING: Private keys will be stored in Terraform state!
  EOT
  type        = bool
  default     = true
}

variable "save_public_key" {
  description = <<-EOT
    Whether to save the generated public key to a local file.
    Only applies when public_key is not provided (key is generated).
  EOT
  type        = bool
  default     = true
}

variable "private_key_filename" {
  description = <<-EOT
    Path where the private key file should be saved.
    If not specified, will use '<key_name>.pem' in the current directory.
  EOT
  type        = string
  default     = null
}

variable "public_key_filename" {
  description = <<-EOT
    Path where the public key file should be saved.
    If not specified, will use '<key_name>.pub' in the current directory.
  EOT
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to the key pair resource."
  type        = map(string)
  default     = {}
}
