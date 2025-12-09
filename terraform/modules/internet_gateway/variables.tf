variable "name" {
  description = "Name tag for the Internet Gateway."
  type        = string
  default     = "igw"
}

variable "create" {
  description = "Whether to create the Internet Gateway."
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "VPC ID to attach the Internet Gateway. If null, the gateway is not created."
  type        = string
  default     = null

  validation {
    condition     = !var.create || var.vpc_id != null
    error_message = "vpc_id is required when create is true."
  }
}

variable "tags" {
  description = "Tags to apply to the Internet Gateway."
  type        = map(string)
  default     = {}
}
