# -----------------------------------------------------------------------------
# AMI Lookup Variables (Data Source)
# -----------------------------------------------------------------------------

variable "ami_id" {
  description = "Specific AMI ID to use. If provided, AMI lookup will be skipped. Use this when you already know the exact AMI ID."
  type        = string
  default     = null
}

variable "most_recent" {
  description = "Return the most recent AMI matching the filters. Recommended for automated deployments to get latest versions."
  type        = bool
  default     = true
}

variable "owners" {
  description = "List of AMI owner IDs or aliases (e.g., ['amazon', '099720109477'] or ['self', 'aws-marketplace']). Required for AMI lookup."
  type        = list(string)
  default     = []

  validation {
    condition     = var.ami_id != null || length(var.owners) > 0
    error_message = "Either ami_id must be provided or owners list must not be empty."
  }
}

variable "filters" {
  description = <<-EOT
    List of filters to narrow down AMI search results.
    Common filters:
    - name: AMI name pattern (e.g., 'amzn2-ami-hvm-*-x86_64-gp2')
    - architecture: Architecture type (e.g., 'x86_64', 'arm64')
    - virtualization-type: Virtualization type (e.g., 'hvm', 'paravirtual')
    - root-device-type: Root device type (e.g., 'ebs', 'instance-store')
    - state: AMI state (usually 'available')
  EOT
  type = list(object({
    name   = string
    values = list(string)
  }))
  default = []
}

variable "filter_tags" {
  description = "Map of tags to filter AMIs. Only AMIs with all specified tags will be returned."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# AMI Copy Configuration (Optional)
# -----------------------------------------------------------------------------

variable "copy_ami_config" {
  description = <<-EOT
    Configuration for copying an AMI from another region. If null, no copy will be created.
    Required fields:
    - name: Name for the copied AMI
    - source_ami_id: ID of the AMI to copy
    - source_ami_region: Region where the source AMI is located
    Optional fields:
    - description: Description for the copied AMI
    - encrypted: Whether to encrypt the copied AMI (default: true)
    - kms_key_id: KMS key ID for encryption (uses default key if not specified)
  EOT
  type = object({
    name              = string
    source_ami_id     = string
    source_ami_region = string
    description       = optional(string, "")
    encrypted         = optional(bool, true)
    kms_key_id        = optional(string)
  })
  default = null
}

# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to the copied AMI. Only applies when copy_ami_config is provided."
  type        = map(string)
  default     = {}
}
