variable "policy_name" {
  description = "Name of the Service Control Policy"
  type        = string
  default     = "region-restriction-policy"
}

variable "description" {
  description = "Description of the Service Control Policy"
  type        = string
  default     = "Restricts resource creation to allowed regions only"
}

variable "allowed_regions" {
  description = "List of AWS regions where resource creation is allowed"
  type        = list(string)
  default     = ["ca-central-1", "ap-northeast-2"]

  validation {
    condition     = length(var.allowed_regions) > 0
    error_message = "At least one region must be specified in allowed_regions."
  }
}

variable "allow_global_services" {
  description = "Whether to allow global AWS services (IAM, CloudFront, etc.) that don't operate in specific regions"
  type        = bool
  default     = true
}

variable "target_ids" {
  description = "List of organizational unit IDs or account IDs to attach the policy to. Leave empty to create policy without attachment."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to the SCP"
  type        = map(string)
  default     = {}
}
