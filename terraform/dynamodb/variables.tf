# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "table_name" {
  description = "Name of the DynamoDB table."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]{3,255}$", var.table_name))
    error_message = "Table name must be between 3 and 255 characters long and can only contain letters, numbers, underscores, dots, and hyphens."
  }
}
