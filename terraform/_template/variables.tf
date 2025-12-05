variable "resource_name" {
  description = "Name of the resource"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# TODO: Add your module-specific variables here
