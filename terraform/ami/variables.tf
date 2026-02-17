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
