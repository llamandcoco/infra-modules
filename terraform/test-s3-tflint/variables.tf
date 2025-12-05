# Wrong: camelCase variable names
# Wrong: missing descriptions
# Wrong: missing types

variable "bucketName" {
  # Missing description
  # Missing type
}

variable "Tags" {
  # Missing description
  default = {}
}

variable "enableVersioning" {
  # Missing description
  default = false
}
