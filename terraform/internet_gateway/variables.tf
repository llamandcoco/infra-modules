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
  description = "VPC ID to attach the Internet Gateway. Required if creating gateway."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the Internet Gateway."
  type        = map(string)
  default     = {}
}
